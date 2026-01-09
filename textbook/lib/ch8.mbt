// 8. Queues
// https://moonbitlang.github.io/moonbit-textbook/queues/

// First-In-First-Out (FIFO)先入れ先出しのデータ構造のQueueを作ります。

// これから作るもの

// Queueのデータ構造
// struct Queue { .. }

// Queueの関数たち
// 空のqueueを作る関数.
// fn make() -> Queue
// Int要素をqueueに追加する関数.
// fn push(self: Queue, t: Int) -> Queue
// 要素をqueueから取り出す関数.
// fn pop(self: Queue) -> Queue
// 先頭の要素を取り出す関数.
// fn peek(self: Queue) -> Int
// queueの要素数を取得する関数.
// fn length(self: Queue) -> Int

// Circular Queues

// priv struct QueueInt {
//   array: Array[Int] // 要素を格納する配列
//   mut start: Int // 最初の要素のインデックス
//   mut end: Int // 最後の要素のインデックス
//   mut length: Int // queueの要素数
// }

// fn pushInt(self: QueueInt, t: Int) -> QueueInt {
//   self.array[self.end] = t
//   self.end = (self.end + 1) % self.array.length() // 配列の持てる要素数を超えたら最初に戻る
//   self.length += 1
//   self
// }

// fn lengthInt(self: QueueInt) -> Int {
//   self.length
// }

// Generic Circular Queues

struct Queue[T] {
  array: Array[T] // 要素を格納する配列
  mut start: Int // 最初の要素のインデックス
  mut end: Int // 最後の要素のインデックス
  mut length: Int // queueの要素数
}

// make関数の初期値を決めるにはOption::Noneを使うかTraitを使う方法がある。
// ch9.mbt のmakeを使う
// fn make[T](size: Int, default: T) -> Queue[T] {
//   {
//     array: Array::make(size, default), // 配列の初期化
//     start: 0,
//     end: 0,
//     length: 0
//   }
// }

fn[T] Queue::push(self: Self[T], t: T) -> Self[T] {
  self.array[self.end] = t
  self.start = self.start
  self.end = (self.end + 1) % self.array.length() // 配列の持てる要素数を超えたら最初に戻る
  self.length = self.length + 1
  self
}

test {
  let mut q: Queue[Int] = {
    array: Array::make(5, 0), // 配列の初期化
    start: 0,
    end: 0,
    length: 0
  }
  q = q.push(1)
  q = q.push(2)
  assert_eq(q.length, 2)
}

// fn length[T](self: Queue[T]) -> Int {
//   self.length
// }

// Singly Linked Lists

struct Node[T] {
  val : T
  mut next : Option[Node[T]]
} derive(Show, Eq)

pub struct LinkedList[T] {
  mut head : Option[Node[T]]
  mut tail : Option[Node[T]]
} derive(Show, Eq)

pub impl[T] Default for LinkedList[T] with default() -> LinkedList[T] {
  { head: None, tail: None }
}

pub fn[T] LinkedList::make() -> LinkedList[T] {
  LinkedList::default()
}

pub fn[T] LinkedList::push(self: LinkedList[T], val: T) -> LinkedList[T] {
  let node = { val, next: None }
  match self.tail {
    None => {
      self.head = Some(node)
      self.tail = Some(node)
    }
    Some(n) => {
      n.next = Some(node)
      self.tail = Some(node)
    }
  }
  self
}

pub fn[T] LinkedList::length(self: LinkedList[T]) -> Int {
  // 末尾再帰が行われておらずスタックオーバーフローになる可能性のある再帰関数の例
  // エラー文
  // RangeError: Maximum call stack size exceeded
  //  at wasm://wasm/516810b2:wasm-function[5]:0x233
  //  at wasm://wasm/516810b2:wasm-function[5]:0x251
  //  at wasm://wasm/516810b2:wasm-function[5]:0x251
  //  at wasm://wasm/516810b2:wasm-function[5]:0x251
  //  ...
  // fn aux(node: Option[Node[T]]) -> Int {
  //   match node {
  //     None => 0
  //     Some(n) => 1 + aux(n.next)
  //   }
  // }
  // aux(self.head)

  // auxが呼ばれる度に評価の終わっていない部分式の`1 + ...`がスタックに積まれていってしまうので、メモリーが足らなくなりスタックオーバーフローになってしまう。
  // 関数を呼ぶ度にメモリースタック上にstack frame(環境)を積んでいく必要性があるとメモリーの使用量が増えてしまい、スタックオーバーフローの可能性が出てくる。再帰関数の最後の式をその再帰関数自身の呼び出しにすると、環境を積む必要が無くなりスタックオーバーフローにならなくなる。これを末尾再帰最適化と呼ぶ。
  // https://en.wikipedia.org/wiki/Tail_call

  // アキュムレーター(cumul)を使った末尾再帰最適化が行われている場合
  fn aux(node: Option[Node[T]], cumul: Int) -> Int {
    match node {
      None => cumul
      Some(n) => aux(n.next, cumul + 1)
    }
  }
  aux(self.head, 0)
}

// LinkedListのテスト
test {
  let list = LinkedList::default()
  let mut i = 0
  // 末尾最適化を行うとスタックオーバーフローにならない
  while i < 100000 {
    let _ = list.push(i)
    i += 1
  }
  assert_eq(list.length(), 100000)
}
