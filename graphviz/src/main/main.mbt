///|
fn main {
  let simple =
    #|  digraph {
    #|    a -> b
    #|  }
  println(@lib.parse_dot(simple))
}
