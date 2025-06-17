pub fn hello() -> String {
  "Hello, world!"
}
// https://docs.moonbitlang.com/en/latest/example/gmachine/gmachine-1.html#g-machine-overview

priv enum Stream[T] {
  Empty
  Cons(T, () -> Stream[T]) // (redex, thunk) thunk部分の無名関数により遅延評価を実現している
}

fn Stream::from_list[T](l: @immut/list.T[T]) -> Stream[T] {
  match l {
    @immut/list.Nil => Empty
    @immut/list.Cons(head, tail) => Cons(head, fn () { Stream::from_list(tail) })
  }
}

fn map[X, Y](self: Stream[X], f: (X) -> Y) -> Stream[Y] {
  match self {
    Empty => Empty
    Cons(head, tail) => Cons(f(head), fn () { tail().map(f) })
  }
}

fn take[T](self: Stream[T], n: Int) -> @immut/list.T[T] {
  if n <= 0 {
    @immut/list.Nil
  } else {
    match self {
      Empty => @immut/list.Nil
      Cons(head, tail) => @immut/list.Cons(head, tail().take(n - 1))
    }
  }
}

priv enum RawExprs[T] {
  Var(T);
  Num(Int);
  Constructor(tag~:Int, arity~:Int);
  App(RawExprs[T], RawExprs[T]);
  Let(Bool, @immut/list.T[(T, RawExprs[T])], RawExprs[T]); // isRec, Defs, Body
  Case(RawExprs[T], @immut/list.T[(Int, @immut/list.T[T], RawExprs[T])]); // Expr, Cases
} derive(Show)

struct ScDef[T] {
  name:String
  args:@immut/list.T[T]
  body:RawExprs[T]
} derive(Show)

priv struct BoxedInt { value : Int }

fn BoxedInt::default() -> BoxedInt {
  { value : Int::default() }
  // The default value can be defined by boxing the default value of `Int`.
}

fn init {
  let _array: BoxedInt = BoxedInt::default()
  ignore(_array.value)
}
