// A simple CEK machine implementation in Moon
// https://youtu.be/O6s8_4agu4c?si=e5MJu6MU1vqvPHY5

typealias @env.Env

pub enum Term {
  App(Term, Term)
  Lam(String, Term)
  Var(String)
} derive(Show, Eq)

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
pub fn eval(term: Term, env: Env[Value]) -> Value? {
  match term {
    Var(x) => env.get(x)
    Lam(x, body) => Some(Closure(env, x, body))
    App(func, arg) => {
      // Evaluate the function and argument
      let (func_env, name, body) = match eval(func, env) {
        Some(Closure(func_env, name, body)) => (func_env, name, body)
        _ => return None
      }
      let evaled_arg = match eval(arg, env) {
        Some(v) => v
        None => return None
      };
      // Create a new environment with the argument bound to the parameter name
      let new_env = func_env.add(name, evaled_arg)
      // Evaluate the body of the function in the new environment
      eval(body, new_env)
    }
  }
}

pub(all) enum Kont[R] {
  Mt((Value) -> R?)
  Fn(Env[Value], Term, Kont[R])
  Ar(Env[Value], String, Term, Kont[R])
} derive(Show)

// CEK for Control, Environment, Kontinuation
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
