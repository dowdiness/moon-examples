// https://docs.moonbitlang.com/en/latest/example/gmachine/gmachine-1.html#g-machine-overview

pub enum Stream[T] {
  Nil
  Cons(T, () -> Stream[T]) // (redex, thunk) thunk部分の無名関数により遅延評価を実現している
}

pub fn[T] Stream::from_list(l: @list.List[T]) -> Stream[T] {
  match l {
    @list.Empty => Nil
    @list.More(head, tail~) => Cons(head, fn () { Stream::from_list(tail) })
  }
}

pub fn[X, Y] Stream::map(self: Self[X], f: (X) -> Y) -> Self[Y] {
  match self {
    Nil => Nil
    Cons(head, tail) => Cons(f(head), fn () { tail().map(f) })
  }
}

pub fn[T] Stream::take(self: Self[T], n: Int) -> @list.List[T] {
  if n <= 0 {
    @list.new()
  } else {
    match self {
      Nil => @list.new()
      Cons(head, tail) => @list.cons(head, tail().take(n - 1))
    }
  }
}
