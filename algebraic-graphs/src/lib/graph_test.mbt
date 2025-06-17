test "graph" {
  if @lib.hello() != "Hello, world!" {
    fail!("@lib.hello() != \"Hello, world!\"")
  }
}
