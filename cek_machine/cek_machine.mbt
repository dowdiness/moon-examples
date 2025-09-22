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

pub(all) struct Env {
  vars: Map[String, Value]
} derive(Show, Eq)

pub fn Env::new() -> Env {
  Env::{ vars: Map::new() }
}

pub fn Env::get(self : Env, name : String) -> Value? {
  self.vars.get(name)
}

pub fn Env::set(self : Env, name : String, value : Value) -> Unit {
  self.vars.set(name, value)
}

pub fn Env::add(self : Env, name: String, val : Value) -> Env {
  let new_env = Env::new()
  self.vars.each(fn(k, v) { new_env.set(k, v) })
  new_env.set(name, val)
  new_env
}

pub fn Env::contains(self : Env, name : String) -> Bool {
  self.vars.contains(name)
}

pub enum Value {
  Closure(Env, String, Term)
} derive(Show, Eq)

pub fn eval(term: Term, env: Env) -> Value? {
  match term {
    Var(x) => env.get(x)
    Lam(x, body) => Some(Closure(env, x, body))
    App(func, arg) => {
      let (func_env, name, body) = match eval(func, env) {
        Some(Closure(func_env, name, body)) => (func_env, name, body)
        _ => return None
      }
      let evaled_arg = match eval(arg, env) {
        Some(v) => v
        None => return None
      };
      let new_env = func_env.add(name, evaled_arg)
      eval(body, new_env)
    }
  }
}
