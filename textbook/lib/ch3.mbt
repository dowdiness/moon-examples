// 3. Functions, Lists & Recursion
// https://moonbitlang.github.io/moonbit-textbook/functions-lists-recursion

// Functions
// 繰り返し出てくる処理を関数として定義することで、
// コードの重複を避けたり、可読性を上げたりすることが出来ます。

let pi: Double = 3.141592653589793
fn circle() -> (Double, Double, Double) {
  let surface_r_1: Double = { let r = 1.0; pi * r * r }
  let surface_r_2: Double = { let r = 2.0; pi * r * r }
  let surface_r_3: Double = { let r = 3.0; pi * r * r }
  (surface_r_1, surface_r_2, surface_r_3)
}

fn area(radius: Double) -> Double { pi * radius * radius }

test {
  assert_eq(circle(), (3.141592653589793, 12.566370614359172, 28.274333882308138))
  assert_eq(
    (area(1.0), area(2.0), area(3.0)),
    (3.141592653589793, 12.566370614359172, 28.274333882308138)
  )
}

// Definition of Top-Level Functions
// 式ブロックの外側で定義された関数はトップレベル関数と呼ばれ、下記の構文によって定義出来ます。
// fn <func name> (<param name>: <type>, <param name>: <type>, ...) -> <type> <expr block>

fn _one () -> Int {
  1
}

fn _add_char(ch: Char, str: String) -> String {
    ch.to_string() + str
}

// Function Application and Evaluation
// 関数の適用は下記の構文によって行えます。
// <func name>(<arg>, <arg>, ...)
// 例: one(), add_char('m', "oonbit")

// 引数の型は関数定義時に指定した型と一致する必要があり、引数の数と順番は変えられません。
// 関数の適用は下記の手順に従います。
// 1. 左側の引数から順番に評価する
// 2. 引数の出現箇所を評価された値に置き換える
// 3. 関数本体の式をreduce(還元)する

// 例: add_char(Char::from_int(109), "oonbit")の評価手順
// 1. 引数の評価: Char::from_int(109) -> 'm', "oonbit" -> "oonbit"
// 2. 引数の置き換え: 'm'.to_string() + "oonbit"
// 3. 関数本体の式の還元: 'm'.to_string() + "oonbit" -> "m" + "oonbit" -> "moonbit"
// 4. 最終的な評価: "moonbit"

fn add_char(ch: Char, str: String) -> String {
  ch.to_string() + str
}
let moonbit: String = add_char(Int::unsafe_to_char(109), "oonbit")

test {
  assert_eq(moonbit, "moonbit")
}

// Partial Functions
// 引数の取りうる値全てには対応していない関数を部分関数(partial functions)と呼びます。
// もし、部分関数を適用した時に、定義されていない引数が渡された場合、
// MoonbitはRuntime Errorを発生させます。

// 例
// Char::from_intは部分関数になっていて、-1に対応するcharacterは存在しないのでエラーになります。
// let ch: Char = Char::from_int(-1)

// 0で割ることは出来ません。
// let nan: Int = 1 / 0

// 部分関数とは違い、全ての入力に対して出力の持っている関数のことを全域関数(total functions）といいます。
// Option[T]型を使うことで、部分関数を全域関数にすることが出来ます。
// Option[T]型は、値がある場合はSome(value)を、
// 値がない場合はNoneを返す型です。

// 例: 0で割ることは出来ませんが、Option[Int]型を使うことで、
// 0で割った場合はNoneを返すようにすることが出来ます。
fn div(a: Int, b: Int) -> Option[Int] {
  if b == 0 { None } else { Some(a / b) }
}

// Option[T]型はT?型に省略出来る。
let _x: Int? = Some(1)

test {
  assert_eq(div(1, 0), None)
  assert_eq(div(10, 2), Some(5))
}

// Definition of Local Functions
// 式ブロック内で定義した関数はローカル関数(local function)です。
// ローカル関数は定義のされた式ブロック内でしか使えません。
// ローカル関数の名前は省略することが出来、anonymous function(無名関数)と呼ばれます。
// Moonbitの関数は第一級関数(first-class function)です。
// つまり、関数を引数に渡したり、関数を返すことが出来ます。

// 下記の例では無名関数を作って、answerに束縛しています。
let answer: () -> Int = fn () {
  // _iの型は指定されていませんが下記の関数の呼び出し real_answer("Ultimate Question") にてStringの値が渡されているので型推論によりString型に推論出来ます。
  fn real_answer(_i) {
    42
  }
  real_answer("Ultimate Question")
}

let x: Int = answer() // 42

test {
  assert_eq(x, 42)
}

// Function Types
// Moonbitの関数は型を持ち、下記の構文で表現出来ます。
// (<param type>, <param type>, <param type>, ...) -> <return type>
// 例
// () -> Int
// (Int, String, Char) -> Int
// ((Int, Int, Int)) -> (Int, Int, Int)
// ->は右結合なので、上記のタプルの例での返り値の型は括弧で囲む必要はありません。

// Labeled Arguments and Optional Arguments
// 引数の呼び出し順番を変えたい場合には、ラベル付き引数(labeled arguments)を使うことが出来ます。

fn greeting1(name~: String, location~: String) -> Unit {
  println("Hi, \{name} from \{location}!")
}

test {
  assert_eq(greeting1(name="somebody", location="some city"), ())
  let name = "someone else"
  let location = "another city"
  // `label=label` can be abbreviated as `label~`
  assert_eq(greeting1(name=name, location~), ())
}

fn greeting2(name~: String, location~: Option[String] = None) -> Unit {
  match location {
    Some(location) => println("Hi, \{name} from \{location}!")
    None => println("Hi, \{name}!")
  }
}

test {
  assert_eq(greeting2(name="A"), ()) // Hi, A!
  assert_eq(greeting2(name="B", location=Some("X")), ()) // Hi, B from X!
}

// Lists
// チュートリアルで使われているリストは無くなっているので、core/immut/listを使う必要があります。
// https://mooncakes.io/docs/moonbitlang/core/immut/list
let int_list: @list.List[Int] = @list.from_array([1, 2, 3])
// let string_list: @immut/list.T[String] = @immut/list.of(["This", "is", "a", "sentence."])

// Construction
test {
    let list0 : @list.List[Int] = @list.default() // 空リストを作る
    assert_eq(list0.length(), 0)
    let list1 = @list.from_array([1, 2, 3, 4, 5]) // 配列からリストを作る
    assert_eq(list1.length(), 5)
    let list2 = list0.add(3).add(2).add(1) // リストの先頭に要素を追加
    assert_eq(list2.to_array(), [1, 2, 3])
    assert_eq(@list.repeat(3, 1).to_array(), [1, 1, 1]) // 繰り返し
}
// Deconstruction
test {
  let head: Option[Int] = int_list.head() // 最初の要素を取得します。全域関数でOption[T]を返します。
  let tail: @list.List[Int] = int_list.unsafe_tail() // 最初以外の要素を取得します。
  assert_eq(head, Some(1))
  assert_eq(tail, @list.from_array([2, 3]))
}
// Pattern Matching
// match <expr> {
//   <pattern 1> => <expr>
//   <pattern 2> => <expr>
// }

fn[T] head_opt(list: @list.List[T]) -> T? {
  list.head()
}

fn get_or_else(option_int: Int64?, default: Int64) -> Int64 {
  match option_int {
    None        => default
    Some(value) => value
  }
}

test {
  // let int_list = @list.empty()
  let arr = match int_list.head() {
    Some(head) => [head]
    None => []
  }
  assert_eq(arr, [1])
  let first_elem: Int? = head_opt(@list.from_array([1, 2]))
  assert_eq(first_elem, Some(1))
  assert_eq(get_or_else(Some(1), 0), 1)
  assert_eq(get_or_else(None, 0), 0)
}

// Recursion

// 再帰関数を使ってフィボナッチ数列を計算する関数を作れます。
fn fib(n: Int) -> Int {
  if n == 1 || n == 2 { 1 } else { fib (n-1) + fib (n-2) }
}

// 再帰関数により奇数と偶数を判定する関数を定義出来ますが、現在のMoonbitでは
// 末尾再帰最適化が行われていないのか？エラーになります。
// failed: RangeError: Maximum call stack size exceeded
// fn even(n: Int) -> Bool {
//   n == 0 || odd(n - 1)
// }
// fn odd(n: Int) -> Bool {
//   n == 1 || even(n - 1)
// }

test {
  assert_eq(fib(1), 1)
  assert_eq(fib(2), 1)
  assert_eq(fib(3), 2)
  assert_eq(fib(4), 3)
  assert_eq(fib(5), 5)
  assert_eq(fib(6), 8)
  assert_eq(fib(7), 13)
  assert_eq(fib(8), 21)
  assert_eq(fib(9), 34)
  assert_eq(fib(10), 55)
}

// Recursion on Lists

fn[T] length(list: @list.List[T]) -> Int {
  list.length()
}

test {
  assert_eq(length(@list.from_array([1, 2])), 2)
}

// Structural Recursion

fn[T] tail(list: @list.List[T]) -> @list.List[T] {
  list.unsafe_tail()
}

test {
  assert_eq(tail(@list.from_array([1, 2])), @list.from_array([2]))
}

// Dynamic Programming

fn fib2(num : Int) -> Int {
  fn aux(n, acc1, acc2) {
    match n {
      0 => acc1
      1 => acc2
      _ => aux(n - 1, acc2, acc1 + acc2)
    }
  }
  aux(num, 0, 1)
}

test {
  assert_eq(fib2(1), 1)
  assert_eq(fib2(2), 1)
  assert_eq(fib2(3), 2)
  assert_eq(fib2(4), 3)
  assert_eq(fib2(5), 5)
  assert_eq(fib2(6), 8)
  assert_eq(fib2(7), 13)
  assert_eq(fib2(8), 21)
  assert_eq(fib2(9), 34)
  assert_eq(fib2(10), 55)
}
