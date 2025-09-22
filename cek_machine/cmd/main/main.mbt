typealias @env.Env

///|
fn main {
  println(@lib.eval(@lib.example(), Env::new()))
}
