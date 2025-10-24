// 7. Imperative Programming
// https://moonbitlang.github.io/moonbit-textbook/imperative-programming

// Functional vs Imperative Programming
// 参照透過性が確保されている場合、関数の呼び出しとその関数の戻り値を置き換えても問題ありません。
// 例:
let _sample: Int = 1 + 1 // xを直接2に置き換えても問題ありません。
fn square(x: Int) -> Int { x * x }; // 参照透過性が確保されている関数
let _square: Int = square(x) // square(x)を{ 2 * 2 }に置き換えても同じ結果を得られます。

// Commands and Side Effects
// 副作用は参照透過性を損なってしまう。
// fn init {
//   let x: Int = {
//     println("hello moonbit") // Print once
//     1 + 1 // 2
//   }
//   let z: Int = square(x) // 4
// }

// The Unit Type
// Unit型は値を持たない型で、()で表現されます。Unit型は関数の戻り値がない場合や、return文がない場合に使われます。
// 命令的なプログラミング言語では副作用のある処理では文、値の返す処理では式を使うことが多いが、式志向であるMoonbitでは副作用のある値の返さない処理をUnitを返すことにより表現する。

fn do_nothing() -> Unit {
  let _x = 0 // The `let` statement is of type `Unit`
}

let _z: Unit = do_nothing() // The return value is `Unit`

// Mutable Variables

// Aliases

// Loops
