// WebAssemblyのサブセットを作ります

// https://moonbitlang.github.io/moonbit-textbook/stack-machine

// WebAssemblyで扱う値を表す型
pub enum Value { I32(Int) } derive(Show, Eq) // 簡単にするため扱う値はIntのみ

// WebAssemblyの命令を表す型
pub(all) enum Instruction {
  Const(Value)
  Add; Sub; Mul; Div;
  // Modulo;
  Equal;
  Call(String)
  Local_Get(String);
  Local_Set(String);
  If(Int, @list.List[Instruction], @list.List[Instruction])
} derive (Show, Eq)

pub struct Function {
  name: String // 関数名
  params: @list.List[String]
  result: Int // 関数の戻り値 今回はIntのみ扱う
  locals: @list.List[String]
  instructions: @list.List[Instruction] // 関数本体
} derive(Show)

pub struct Program {
  functions: @list.List[Function] // 関数定義のリスト
  start: Option[String] // プログラムが最初に実行するメイン関数
} derive(Show)

pub enum Expression {
  Number(Int)
  Plus(Expression, Expression)
  Minus(Expression, Expression)
  Multiply(Expression, Expression)
  Divide(Expression, Expression)
} derive(Show)

fn Expression::to_instructions(self : Expression) -> @list.List[Instruction] {
  match self {
      Number(i) => @list.of([Const(I32(i))])
      Plus(a, b) => a.to_instructions() + b.to_instructions() + @list.of([Add])
      Minus(a, b) => a.to_instructions() + b.to_instructions() + @list.of([Sub])
      Multiply(a, b) => a.to_instructions() + b.to_instructions() + @list.of([Mul])
      Divide(a, b) => a.to_instructions() + b.to_instructions() + @list.of([Div])
  }
}

test {
  let expr: Expression = Plus(
    Minus(Number(4), Number(1)),
    Multiply(Number(2), Divide(Number(4), Number(2)))
  )
  let instructions: @list.List[Instruction] = expr.to_instructions()
  assert_eq(instructions, @list.of([
    Const(I32(4)), Const(I32(1)), Sub,
    Const(I32(2)),
    Const(I32(4)), Const(I32(2)), Div, Mul,
    Add
  ]))
}

test {
  // Basic Arithmetic Calculations
  // Stackを使った 1 + 2 の実装例
  let _oneplustwo: @list.List[Instruction] = @list.of([
    Const(I32(1)),
    Const(I32(2)),
    Add
  ])
  println(_oneplustwo)

  // Functions and Local Variables
  // add(a : Int, b : Int) { a + b }
  let _local: @list.List[Instruction] = @list.of([ Local_Get("a"), Local_Get("b"), Add ])
  println(_local)

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
  println(_program)
}

// ;; Multiple functions
// ;; Wasm itself only defines operations; interaction depends on external functions
// (func $print_int (import "spectest" "print_int") (param i32))

// (func $add (export "add") ;; Export function to be directly used by runtime
//   (param $a i32) (param $b i32) (result i32 ) ;; (a : Int, b : Int) -> Int
//   local.get $a local.get $b i32.add ;;
// )

// (func $test_add (export "test_add") (result ) ;; Entry function with no input or output
//   i32.const 0 i32.const 1 call $add call $print_int
// )

// (start $test_add)

// Implementing a Compiler
fn Program::to_wasm(self : Program, buffer : @buffer.Buffer) -> @buffer.Buffer {
  buffer.write_string("(module\n  ")
  // Import print_int function
  // buffer.write_string("(import \"spectest\" \"print_int\" (func $print_int (param i32))) ")
  // Function definitions
  for func in self.functions {
    func.to_wasm(buffer)
  }
  // Start function
  match self.start {
    Some(name) => {
      buffer.write_string("  (start $")
      buffer.write_string(name)
      buffer.write_string(")\n")
    }
    None => ()
  }
  buffer.write_string(")") // End of module
  buffer
}

fn Function::to_wasm(self : Function, buffer : @buffer.Buffer) -> Unit {
  buffer.write_string("(func $")
  buffer.write_string(self.name)
  // Parameters
  for param in self.params {
    buffer.write_string(" (param $")
    buffer.write_string(param)
    buffer.write_string(" i32)")
  }
  // Return type
  if self.result == 1 {
    buffer.write_string(" (result i32)\n   ")
  } else {
    buffer.write_string(" (result )\n   ")
  }
  // Local variables
  for local_var in self.locals {
    buffer.write_string("(local.get $")
    buffer.write_string(local_var)
    buffer.write_string(")")
  }
  // Instructions
  for instr in self.instructions {
    instr.to_wasm(buffer)
  }
  buffer.write_string(")\n") // End of function
}

fn Instruction::to_wasm(self : Instruction, buffer : @buffer.Buffer) -> Unit {
  match self {
    Const(I32(val)) => buffer.write_string(" i32.const $\{val}")
    Add => buffer.write_string(" i32.add")
    Equal => buffer.write_string(" i32.eq")
    Call(name) => {
      buffer.write_string(" call $\{name}")
    }
    Local_Get(val) => buffer.write_string(" local.get $\{val}")
    Local_Set(val) => buffer.write_string(" local.set $\{val}")
    _ => buffer.write_string("not implemented yet!")
  }
}

test {
  let _program: Program = Program::{

    start: Some("test_add"), // Program entry point

    functions: @list.of([
      Function::{
        name: "add", // Addition function
        params: @list.of(["a", "b"]), result: 1, locals: @list.of([]),
        instructions: @list.of([Local_Get("a"), Local_Get("b"), Add]),
      },
    ]),
  }

  println(_program.to_wasm(@buffer.new()))
}

// Implementing an Interpreter

pub(all) enum StackValue {
  Val(Value) // Ordinary value
  Func(@hashmap.HashMap[String, Value]) // Function stack, stores previous local variables
}

pub(all) enum AdministrativeInstruction {
  Plain(Instruction) // Ordinary instruction
  EndOfFrame(Int) // Function end instruction
}
pub(all) struct State {
  program : Program
  stack : @list.List[StackValue]
  locals : @hashmap.HashMap[String, Value]
  instructions : @list.List[AdministrativeInstruction]
}

fn evaluate(state : State, stdout: @buffer.Buffer) -> State? {
  match (state.instructions, state.stack) {
    (More(Plain(Add), tail=tl), More(Val(I32(b)), tail=More(Val(I32(a)), tail=rest))) =>
      Some(
        State::{ ..state, instructions: tl, stack: @list.cons(Val(I32(a + b)), rest) },
      )
    (More(Plain(Sub), tail=tl), More(Val(I32(b)), tail=More(Val(I32(a)), tail=rest))) =>
      Some(
        State::{ ..state, instructions: tl, stack: @list.cons(Val(I32(a - b)), rest) },
      )
    (More(Plain(Const(v)), tail=tl), stack) =>
      Some(State::{ ..state, instructions: tl, stack: @list.cons(Val(v), stack) })
    (More(Plain(If(_, then_, else_)), tail=tl), More(Val(I32(cond)), ..)) => {
      Some(State::{
        ..state,
        instructions: (if cond != 0 { then_ } else { else_ }).map(
            AdministrativeInstruction::Plain(_),
          ).concat(tl)
        })
    }
    (More(Plain(Call("print_int")), tail=instructions), More(Val(I32(i)), tail=stack)) => {
      stdout.write_string(i.to_string())
      Some(State::{ ..state, stack, instructions })
    }
    _ => None
    }
}

test {
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

  let initial_state = State::{
    program: _program,
    stack: @list.of([]),
    locals: @hashmap.new(),
    instructions: @list.of([AdministrativeInstruction::Plain(Call("test_add"))]),
  }
  let state = initial_state
  let stdout = @buffer.new()
  loop evaluate(state, stdout) {
    Some(new_state) => continue(evaluate(new_state, stdout))
    None => break
  }
  assert_eq(stdout.to_string(), "1")
}
