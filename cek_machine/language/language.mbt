pub(all) struct Position {
  line: Int
  column: Int
} derive(Show, Eq)

pub(all) enum Location {
  Location(Position, Position)
  NoLocation
} derive(Show, Eq)

pub(all) struct Language[Term, Value] {
  name: String
  env : @env.Env[Value]
  term: Term
  value: Value
}

pub(open) trait Compiler {
  eval(Self) -> String
}

pub impl[T, V] Compiler for Language[T, V] with eval(self) -> String {
  self.name
}
