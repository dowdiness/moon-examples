typealias @env.Env

///|
test "identity function" {
  let term = example()
  let result = eval(term, Env::new())
  // `inspect` is used to check the output of the function
  // Just write `inspect(value)` and execute `moon test --update`
  // to update the expected output, and verify them afterwards
  inspect(result, content="Closure({vars: {}}, \"x\", Var(\"x\"))")
}

///| Defunctionalized CPS evaluator
test "Defunctionalized CPS identity function" {
  let term = example()
  let result = eval_k(
    term,
    Env::new(),
    Kont::Mt(Some(_))
  )
  // `inspect` is used to check the output of the function
  // Just write `inspect(value)` and execute `moon test --update`
  // to update the expected output, and verify them afterwards
  inspect(result, content="Some(Closure({vars: {}}, \"x\", Var(\"x\")))")
}
