fn main {
  println(@lib.version())
  println(@lib.tan_c(120))

  // Test creating a complex number directly
  let c = @lib.Complex::new(3.5, 2.25)
  println("Created complex: \{c}")

  // Test init_n
  let arr = @lib.init_n(3)
  println("init_n result: \{arr}")

  // Create an array with non-default values
  let test_arr = FixedArray::make(3, @lib.Complex::new(0, 0))
  test_arr[0] = @lib.Complex::new(1.0, 2.0)
  test_arr[1] = @lib.Complex::new(3.0, 4.0)
  test_arr[2] = @lib.Complex::new(5.0, 6.0)

  println("Testing print_complex_iter:")
  @lib.print_complex_iter(test_arr)
}
