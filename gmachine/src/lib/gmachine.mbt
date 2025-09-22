pub fn hello() -> String {
  "Hello, world!"
}
// https://docs.moonbitlang.com/en/latest/example/gmachine/gmachine-1.html#g-machine-overview

pub(all) enum RawExprs[T] {
  Var(T);
  Num(Int);
  Constructor(tag~:Int, arity~:Int);
  App(RawExprs[T], RawExprs[T]);
  Let(Bool, @list.List[(T, RawExprs[T])], RawExprs[T]); // isRec, Defs, Body
  Case(RawExprs[T], @list.List[(Int, @list.List[T], RawExprs[T])]); // Expr, Cases
} derive(Show)

pub(all) struct ScDef[T] {
  name:String
  args:@list.List[T]
  body:RawExprs[T]
} derive(Show)

pub struct BoxedInt { value : Int }

fn BoxedInt::default() -> BoxedInt {
  { value : Int::default() }
  // The default value can be defined by boxing the default value of `Int`.
}

fn init {
  let _array: BoxedInt = BoxedInt::default()
  ignore(_array.value)
}
