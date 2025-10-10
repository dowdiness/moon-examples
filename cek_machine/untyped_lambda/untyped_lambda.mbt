// Implementation of Chapter 7 on Types and Programming Languages
// Moonbit equivalent of DeBruijn.res

// DeBruijn Term definition using enum (different from existing Term)
pub(all) enum Term {
  // variable with DeBruijn index and depth
  Var(Int, Int)
  // lambda abstraction
  Abs(String, Term)
  // application
  App(Term, Term)
} derive(Show, Eq)

pub enum Binding {
  NameBind
}

// generate new name
fn pickFreshName(ctx : Array[(String, Binding)], name : String) -> (Array[(String, Binding)], String) {
  let mut found = false
  for i = 0; i < ctx.length(); i = i + 1 {
    let (varName, _) = ctx[i]
    if name == varName {
      found = true
      break
    }
  }
  if found {
    pickFreshName(ctx, name + "'")
  } else {
    let new_ctx = Array::new(capacity=ctx.length() + 1)
    for i = 0; i < ctx.length(); i = i + 1 {
      new_ctx.push(ctx[i])
    }
    new_ctx.push((name, NameBind))
    (new_ctx, name)
  }
}

// find variable name by deBruijnIndex
fn indexToName(ctx : Array[(String, Binding)], x : Int) -> String {
  if x < ctx.length() {
    let (name, _) = ctx[x]
    name
  } else {
    "[" + x.to_string() + " bad index]"
  }
}

// PrettyPrinter
fn printTerm(ctx : Array[(String, Binding)], t : Term) -> String {
  match t {
    Abs(k, t1) => {
      let (ctx_prime, k_prime) = pickFreshName(ctx, k)
      "(λ" + k_prime + ". " + printTerm(ctx_prime, t1) + ")"
    }
    App(t1, t2) => {
      "(" + printTerm(ctx, t1) + " " + printTerm(ctx, t2) + ")"
    }
    Var(x, n) => {
      if ctx.length() == n {
        indexToName(ctx, x)
      } else {
        "[" + ctx.length().to_string() + " " + n.to_string() + " bad index]"
      }
    }
  }
}

fn shift(d : Int, t : Term) -> Term {
  fn walk(c : Int, t : Term) -> Term {
    match t {
      Var(k, n) => {
        if k >= c {
          // shift it because it's a free variable
          Var(k + d, n + d)
        } else {
          // don't shift it because it's a bound variable
          Var(k, n + d)
        }
      }
      Abs(x, t1) => Abs(x, walk(c + 1, t1))
      App(t1, t2) => App(walk(c, t1), walk(c, t2))
    }
  }
  walk(0, t)
}

// [j -> s]t
fn subst(j : Int, s : Term, t : Term) -> Term {
  fn walk(c : Int, t : Term) -> Term {
    match t {
      Var(k, n) => {
        if k == j + c {
          shift(c, s)
        } else {
          Var(k, n)
        }
      }
      Abs(x, t1) => Abs(x, walk(c + 1, t1))
      App(t1, t2) => App(walk(c, t1), walk(c, t2))
    }
  }
  walk(0, t)
}

// α-reduction
fn substTop(s : Term, t : Term) -> Term {
  shift(-1, subst(0, shift(1, s), t))
}

// value is lambda abstraction
fn isVal(_ctx : Array[(String, Binding)], t : Term) -> Bool {
  match t {
    Abs(_, _) => true
    _ => false
  }
}

// one step evaluation using Option for error handling
fn eval1(ctx : Array[(String, Binding)], t : Term) -> Option[Term] {
  match t {
    App(Abs(var_name, t12), v2) => {
      if isVal(ctx, v2) {
        Some(substTop(v2, t12))
      } else {
        match eval1(ctx, v2) {
          Some(t2_prime) => Some(App(Abs(var_name, t12), t2_prime))
          None => None
        }
      }
    }
    App(v1, t2) => {
      if isVal(ctx, v1) {
        match eval1(ctx, t2) {
          Some(t2_prime) => Some(App(v1, t2_prime))
          None => None
        }
      } else {
        match eval1(ctx, v1) {
          Some(t1_prime) => Some(App(t1_prime, t2))
          None => None
        }
      }
    }
    _ => None // No rule applies
  }
}

pub fn eval(ctx : Array[(String, Binding)], t : Term) -> Term {
  // print terms at each step of the evaluation
  println(printTerm(ctx, t))
  if isVal(ctx, t) {
    t
  } else {
    match eval1(ctx, t) {
      Some(t_prime) => eval(ctx, t_prime)
      None => {
        println("No rule applies - evaluation stopped")
        t
      }
    }
  }
}

// Test cases
pub fn test_debruijn() -> Unit {
  println("=== DeBruijn Index Lambda Calculus Tests ===")

  // ((λ x. x) (λ y. y))
  println("\nTest 1: ((λ x. x) (λ y. y))")
  let empty_ctx : Array[(String, Binding)] = []
  let _ = eval(empty_ctx, App(Abs("x", Var(0, 1)), Abs("x", Var(0, 1))))

  // ((λ x. (λ y. x)) (λ z. z))
  println("\nTest 2: ((λ x. (λ y. x)) (λ z. z))")
  let empty_ctx2 : Array[(String, Binding)] = []
  let _ = eval(empty_ctx2, App(Abs("x", Abs("y", Var(1, 2))), Abs("z", Var(0, 1))))

  // if terms have same name variable, create fresh name variable
  // ((λ x. (λ x. (λ x. x))) (λ x. x)) -> ((λ x. (λ x'. (λ x''. x))) (λ x. x))
  // (λ x. (λ x. (λ x. x))) -> (λ x. (λ x'. (λ x''. x'')))
  println("\nTest 3: ((λ x. (λ x. (λ x. x))) (λ x. x))")
  let empty_ctx3 : Array[(String, Binding)] = []
  let _ = eval(empty_ctx3, App(Abs("x", Abs("x", Abs("x", Var(2, 3)))), Abs("x", Var(0, 1))))
}
