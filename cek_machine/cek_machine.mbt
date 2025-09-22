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
