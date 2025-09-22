pub(all) struct Env[V] {
  vars: Map[String, V]
} derive(Show, Eq)

pub fn[V] Env::new() -> Env[V] {
  Env::{ vars: Map::new() }
}

pub fn[V] Env::get(self : Env[V], name : String) -> V? {
  self.vars.get(name)
}

pub fn[V] Env::set(self : Env[V], name : String, value : V) -> Unit {
  self.vars.set(name, value)
}

pub fn[V] Env::add(self : Env[V], name: String, val : V) -> Env[V] {
  let new_env = Env::new()
  self.vars.each(fn(k, v) { new_env.set(k, v) })
  new_env.set(name, val)
  new_env
}
