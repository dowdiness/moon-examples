// WebAssemblyのサブセットを作ります

// https://moonbitlang.github.io/moonbit-textbook/stack-machine

// WebAssemblyで扱う値を表す型
pub enum Value { I32(Int) } // 簡単にするため扱う値はIntのみ

// WebAssemblyの命令を表す型
pub enum Instruction {
  Const(Value)
  Add;
  // Sub; Modulo;
  Equal;
  Call(String)
  Local_Get(String);
  // Local_Set(String);
  If(Int, @list.List[Instruction], @list.List[Instruction])
}

pub struct Function {
  name: String // 関数名
  params: @list.List[String]
  result: Int // 関数の戻り値 今回はIntのみ扱う
  locals: @list.List[String]
  instructions: @list.List[Instruction] // 関数本体
}

pub struct Program {
  functions: @list.List[Function] // 関数定義のリスト
  start: Option[String] // プログラムが最初に実行するメイン関数
}

// Basic Arithmetic Calculations
// Stackを使った 1 + 2 の実装例
let _oneplustwo: @list.List[Instruction] = @list.of([
  Const(I32(1)),
  Const(I32(2)),
  Add
])

// Functions and Local Variables
// add(a : Int, b : Int) { a + b }
let _local: @list.List[Instruction] = @list.of([ Local_Get("a"), Local_Get("b"), Add ])

// Conditional Statements
let _ifStatement: @list.List[Instruction] = @list.of([
  Const(I32(1)), Const(I32(0)), Equal,
  If(1, @list.of([Const(I32(1))]), @list.of([Const(I32(0))]))
])

let _program: Program = Program::{

  start: Some("test_add"), // Program entry point

  functions: @list.of([
    Function::{
      name: "add", // Addition function
      params: @list.of(["a", "b"]), result: 1, locals: @list.of([]),
      instructions: @list.of([Local_Get("a"), Local_Get("b"), Add]),
    },
    Function::{
      name: "test_add", // calculate add and output
      params: @list.of([]), result: 0, locals: @list.of([]), // no input or output
      // "print_int" is a special function
      instructions: @list.of([Const(I32(0)), Const(I32(1)), Call("add"), Call("print_int")]),
    },
  ]),
}

// Implementing a Compiler
