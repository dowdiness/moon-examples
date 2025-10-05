// A simple CEK machine implementation in Moon
// https://youtu.be/O6s8_4agu4c?si=e5MJu6MU1vqvPHY5

typealias @env.Env

pub(all) suberror EvalError String

/// lambda calculus
///  <expr> ::= (λ (<var>) <expr>)
///      |  <var>
///      |  (<expr> <expr>)
pub enum Term {
  App(Term, Term)
  Lam(String, Term)
  Var(String)
} derive(Show, Eq)

/// Identity function
pub fn identity() -> Term {
  Lam("x", Var("x"))
}

pub fn example() -> Term {
  App(identity(), identity())
}

pub enum Value {
  Closure(Env[Value], String, Term)
} derive(Show, Eq)

// CE for Control, E for Environment
pub fn eval(term: Term, env: Env[Value]) -> Value raise EvalError {
  match term {
    Var(x) => match env.get(x) {
      Some(v) => v
      None => raise EvalError("Unbound variable: " + x)
    }
    Lam(x, body) => Closure(env, x, body)
    App(e1, e2) => {
      // Evaluate the function and argument
      let Closure(e1_env, name, body) = eval(e1, env)
      let evaled_e2 = eval(e2, env)
      // Create a new environment with the argument bound to the parameter name
      let new_env = e1_env.add(name, evaled_e2)
      // Evaluate the body of the function in the new environment
      eval(body, new_env)
    }
  }
}

/// Continuation-passing style evaluator
pub fn[R] eval_cps(term: Term, env: Env[Value], kont: (Value) -> R?) -> R? {
  match term {
    Var(x) => match env.get(x) {
      Some(v) => kont(v)
      None => None
    }
    Lam(x, body) => kont(Closure(env, x, body))
    App(func, arg) => {
      eval_cps(func, env, (v) => {
        let Closure(func_env, name, body) = v
        eval_cps(arg, env, (evaled_arg) =>  {
          let new_env = func_env.add(name, evaled_arg)
          eval_cps(body, new_env, kont)
        })
      })
    }
  }
}

pub(all) enum Kont[R] {
  Mt((Value) -> R?)
  Fn(Env[Value], Term, Kont[R])
  Ar(Env[Value], String, Term, Kont[R])
} derive(Show)

// Defunctionalized version of eval_cps
pub fn[R] eval_k(term: Term, env: Env[Value], kont: Kont[R]) -> R? {
  match term {
    Var(x) => match env.get(x) {
      Some(v) => apply_k(kont, v)
      None => return None
    }
    Lam(x, body) => apply_k(kont, Closure(env, x, body))
    App(func, arg) => {
      let evaled_arg = Fn(env, arg, kont)
      eval_k(func, env, evaled_arg)
    }
  }
}

pub fn[R] apply_k(kont: Kont[R], value: Value) -> R? {
  match kont {
    Mt(rest) => rest(value)
    Fn(arg_env, body, rest) => match value {
      Closure(v_env, v_name, v_term) => {
        let arg = Ar(v_env, v_name, v_term, rest)
        eval_k(body, arg_env, arg)
      }
    }
    Ar(func_env, arg, body, rest) => {
      let new_env = func_env.add(arg, value)
      eval_k(body, new_env, rest)
    }
  }
}
