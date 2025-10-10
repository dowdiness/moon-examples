// Implementation of Chapter 7 on Types and Programming Languages
// Moonbit equivalent of DeBruijn.res

// value is lambda abstraction
fn isVal(_ctx : Array[(String, Binding)], t : Term) -> Bool {
  match t {
    Abs(_, _) => true
    _ => false
  }
}

// one step evaluation using Option for error handling
fn eval1(ctx : Array[(String, Binding)], t : Term) -> Term raise EvalError {
  match t {
    App(Abs(var_name, t12), v2) => {
      if isVal(ctx, v2) {
        substTop(v2, t12)
      } else { App(Abs(var_name, t12), eval1(ctx, v2))
      }
    }
    App(v1, t2) => {
      if isVal(ctx, v1) { App(v1, eval1(ctx, t2))
      } else {
        App(eval1(ctx, v1), t2)
      }
    }
    // No rule applies
    term => raise NoRuleApplies(term)
  }
}

pub fn eval(ctx : Array[(String, Binding)], t : Term) -> Term raise EvalError {
  // print terms at each step of the evaluation
  println(printTerm(ctx, t))
  if isVal(ctx, t) {
    t
  } else {
    eval(ctx, eval1(ctx, t))
  }
}

// Test cases
pub fn test_debruijn() -> Unit {
  println("=== DeBruijn Index Lambda Calculus Tests ===")

  // ((λ x. x) (λ y. y))
  println("\nTest 1: ((λ x. x) (λ y. y))")
  let empty_ctx : Array[(String, Binding)] = []
  let _ = try? eval(empty_ctx, App(Abs("x", Var(0, 1)), Abs("x", Var(0, 1))))

  // ((λ x. (λ y. x)) (λ z. z))
  println("\nTest 2: ((λ x. (λ y. x)) (λ z. z))")
  let empty_ctx2 : Array[(String, Binding)] = []
  let _ = try? eval(empty_ctx2, App(Abs("x", Abs("y", Var(1, 2))), Abs("z", Var(0, 1))))

  // if terms have same name variable, create fresh name variable
  // ((λ x. (λ x. (λ x. x))) (λ x. x)) -> ((λ x. (λ x'. (λ x''. x))) (λ x. x))
  // (λ x. (λ x. (λ x. x))) -> (λ x. (λ x'. (λ x''. x'')))
  println("\nTest 3: ((λ x. (λ x. (λ x. x))) (λ x. x))")
  let empty_ctx3 : Array[(String, Binding)] = []
  let _ = try? eval(empty_ctx3, App(Abs("x", Abs("x", Abs("x", Var(2, 3)))), Abs("x", Var(0, 1))))
}
