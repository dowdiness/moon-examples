///|
pub extern "C" fn version_major() -> Int = "version_major"

///|
pub extern "C" fn print_version() -> Unit = "print_version"

///| The return value is semantically a boolean, using MoonBit's Bool type is clearer
pub extern "C" fn is_normal(input : Double) -> Bool = "is_normal"

///|
pub extern "C" fn sinf(input : Float) -> Float = "sinf"
///|
pub extern "C" fn cosf(input : Float) -> Float = "cosf"
///|
pub extern "C" fn tanf(input : Float) -> Float = "tanf"

///|
pub extern "C" fn sin(input : Double) -> Double = "sin"
///|
pub extern "C" fn cos(input : Double) -> Double = "cos"
///|
pub extern "C" fn tan(input : Double) -> Double = "tan"

///| A helper function to convert a MoonBit String to the null-terminated byte array expected by C
fn string_to_c_bytes(s : String) -> Bytes {
  let arr = @encoding/utf8.encode(s).to_array()
  // Ensure it's null-terminated
  if arr.last() != Some(0) {
    arr.push(0)
  }
  Bytes::from_array(arr)
}

///| FFI declaration, note the parameter type is Bytes
/// #borrow(s) Tell the compiler we are just borrowing s, don't increase its reference count
#borrow(s)
extern "C" fn __parse_int(s: Bytes) -> Int = "parse_int"

///| Wrap it in a user-friendly MoonBit function
pub fn parse_int(str: String) -> Int {
  let s = string_to_c_bytes(str)
  __parse_int(s)
}

///| 1. Declare an external type to represent the C string pointer
#external
priv type CStr

///| 2. Declare an FFI function that calls the C wrapper
#borrow(self)
extern "C" fn CStr::to_string(self: Self) -> String = "cstr_to_moonbit_str"

///| 3. Declare the original C function, which returns our opaque type
extern "C" fn __version() -> CStr = "version"

// 4. Wrap it in a safe MoonBit function
pub fn version() -> String {
  __version().to_string()
}

#borrow(output)
extern "C" fn tan_with_errcode(input: Double, output: Ref[Double]) -> Int = "tan_with_errcode"

pub fn tan_c(input: Double) -> String {
  let output = { val: 0.0 }
  match tan_with_errcode(input, output) {
    0 => output.val.to_string()
    _ => "Error in C FFI!"
  }
}

#borrow(inputs, outputs)
pub extern "C" fn sin_array(len: Int, inputs: FixedArray[Double], outputs: FixedArray[Double]) -> Int = "sin_array"
#borrow(inputs, outputs)
pub extern "C" fn cos_array(len: Int, inputs: FixedArray[Double], outputs: FixedArray[Double]) -> Int = "cos_array"

#borrow(inputs, outputs)
pub extern "C" fn tan_array(len: Int, inputs: FixedArray[Double], outputs: FixedArray[Double]) -> Int = "tan_array"

#external
priv type C_Complex

struct Complex(C_Complex)

// https://www.moonbitlang.com/pearls/moonbit-cffi#41-the-simple-case
// Simple GC management by treating Complex as a MoonBit object and letting Compiler automatically manage its memory and add a GC header.

// struct Complex {
//   r: Double
//   i: Double
// } derive(Show)

///| FFI declaration pointing to our C wrapper function
// Note: No #borrow here because new_mbt_complex takes ownership of the pointer
extern "C" fn __new_managed_complex(c_complex: C_Complex) -> Complex = "new_mbt_complex"

// C: Complex* new_complex(double r, double i);
// The original C new_complex function returns a raw pointer
extern "C" fn __new_unmanaged_complex(r: Double, i: Double) -> C_Complex = "new_complex"

// The final, safe, GC-friendly new function provided to the user
pub fn Complex::new(r: Double, i: Double) -> Complex {
  let c_ptr = __new_unmanaged_complex(r, i)
  __new_managed_complex(c_ptr)
}

pub impl Default for Complex with default() {
  Complex::new(0, 0)
}

// Assume there is a C function `double length(Complex*);`
extern "C" fn length(c_complex: C_Complex) -> Double = "length"

pub fn Complex::length(self: Self) -> Double {
  // deprecated!: self.inner() returns the internal C_Complex (i.e., the C pointer)
  // use `.0` access the underlying type instead.
  length(self.0)
}

// C: void multiply(Complex* a, Complex* b, Complex** result);
// Complex* corresponds to Complex, and Complex** corresponds to Ref[Complex]
#borrow(res)
extern "C" fn multiply(a: Complex, b: Complex, res: Ref[Complex]) -> Unit = "multiply"

// C: void init_n_moonbit_complexes(int n, Complex** complex_array);
// Complex** is used as an array here, corresponding to FixedArray[Complex]
#borrow(complex_array)
extern "C" fn init_n_moonbit_complexes(n: Int, complex_array: FixedArray[Complex]) -> Unit = "init_n_moonbit_complexes"

// Define methods on the Complex type to hide FFI details
pub fn Complex::mul(self: Complex, other: Complex) -> Complex {
  // Create a temporary Ref to receive the result
  let res: Ref[Complex] = Ref::{ val: Complex::new(0, 0) }
  multiply(self, other, res)
  res.val // Return the result
}

extern "C" fn C_Complex::to_string(self: Self) -> String = "ccomplex_to_moonbit_str"

pub impl Show for Complex with output(self: Complex, logger: &Logger) {
  logger.write_string(self.0.to_string())
}

pub impl Show for Complex with to_string(self) {
  self.0.to_string()
}

pub fn init_n(n: Int) -> Array[Complex] {
  // Use FixedArray::make to create the array
  let arr = FixedArray::make(n, Complex::new(0, 0))
  init_n_moonbit_complexes(n, arr)
  // Convert FixedArray to the more user-friendly Array
  Array::from_fixed_array(arr)
}

#borrow(arr)
extern "C" fn for_each_complex(
  n: Int,
  arr: FixedArray[Complex],
  call_back: FuncRef[(Complex) -> Int] // Use FuncRef to wrap the function type
) -> Unit = "for_each_moonbit_complex"

pub fn print_complex(c: Complex) -> Int {
  println(c)
  0
}

pub fn print_complex_iter(arr: FixedArray[Complex]) -> Unit {
  let print_complex : FuncRef[(Complex) -> Int] = (c) => print_complex(c)
  let n = arr.length()
  for_each_complex(n, arr, print_complex)
}
