// Lambda Calculus Term definition using enum
pub(all) enum Term {
  // variable with Lambda Calculus index and depth
  Var(Int, Int)
  // lambda abstraction
  Abs(String, Term)
  // application
  App(Term, Term)
} derive(Show, Eq)

// PrettyPrinter
fn printTerm(ctx : Array[(String, Binding)], t : Term) -> String raise EvalError {
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
        raise VarIndexError("[" + ctx.length().to_string() + " " + n.to_string() + " bad index]")
      }
    }
  }
}
