// 9. Traits
// https://moonbitlang.github.io/moonbit-textbook/traits/

// Methods

enum Tree[T] {
  Empty
  Node(T, Tree[T], Tree[T])
}

// We need a comparison function to determine the order of values
// -1: less than; 0: equal to; 1: greater than
// fn insert[T](self: Tree[T], value: T, compare: (T, T) -> Int) -> Tree[T]
// fn delete[T](self: Tree[T], value: T, compare: (T, T) -> Int) -> Tree[T]

// Traits
// トレイトにより型が実装するべきメソッドのリストを定義出来ます。
// メソッドの型を定義する際には型自体を示すSelfを使えます。
// Moonbitのトレイトシステムは構造的で、明示的にトレイトを実装する必要はありません。
// 型がトレイトの要求するメソッドのシグネチャを持っていればトレイトは自動的に実装されます。
// trait Compare {
//   compare(Self, Self) -> Int
// }
trait Default {
  default() -> Self
}

// Bounded Generics

pub fn make[T: Default]() -> Queue[T] { // `T` should support the `default` method.
  {
    array: Array::make(5, T::default()), // The return type of `default` is `T`.
    start: 0,  end: 0,  length: 0
  }
}

// Implementation of Traits

// Implicit Implementation
// 注: 暗黙的なトレイトの実装は将来的には削除される予定らしい。
// https://www.moonbitlang.com/weekly-updates/2025/05/06/index
// struct BoxedInt { value : Int }

// fn init {
//   let _array: BoxedInt = make()
//   ignore(_array.value)
// }
// Explicit Implementation

// Automatic Derivation
