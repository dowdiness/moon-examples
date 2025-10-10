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
fn indexToName(ctx : Array[(String, Binding)], x : Int) -> String raise EvalError {
  if x < ctx.length() {
    let (name, _) = ctx[x]
    name
  } else {
    raise VarIndexError("[" + x.to_string() + " bad index]")
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
