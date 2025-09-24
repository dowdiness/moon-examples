typealias @env.Env

///|
fn main {
  try @lib.eval(@lib.example(), Env::new()) catch {
    @lib.EvalError(msg) => println("Error: " + msg)
  } noraise {
    v => println(v)
  }
}
