///|
test "Complex::to_string" {
  // Basic positive cases
  let c1 = @lib.Complex::new(3.5, 2.25)
  inspect(c1.to_string(), content="3.50000000+2.25000000i")

  // Negative imaginary part
  let c2 = @lib.Complex::new(1.0, -5.5)
  inspect(c2.to_string(), content="1.00000000-5.50000000i")

  // Zero values
  let c3 = @lib.Complex::new(0.0, 0.0)
  inspect(c3.to_string(), content="0.00000000+0.00000000i")

  // Pure real number (zero imaginary)
  let c4 = @lib.Complex::new(42.0, 0.0)
  inspect(c4.to_string(), content="42.00000000+0.00000000i")

  // Pure imaginary number (zero real)
  let c5 = @lib.Complex::new(0.0, 7.0)
  inspect(c5.to_string(), content="0.00000000+7.00000000i")
}

///|
test "Complex::to_string/boundary_values" {
  // Very small positive values
  let c1 = @lib.Complex::new(0.00000001, 0.00000001)
  inspect(c1.to_string(), content="0.00000001+0.00000001i")

  // Very small negative values
  let c2 = @lib.Complex::new(-0.00000001, -0.00000001)
  inspect(c2.to_string(), content="-0.00000001-0.00000001i")

  // Large values
  let c3 = @lib.Complex::new(999999.0, 888888.0)
  inspect(c3.to_string(), content="999999.00000000+888888.00000000i")

  // Mixed signs with large values
  let c4 = @lib.Complex::new(-123456.789, 987654.321)
  inspect(c4.to_string(), content="-123456.78900000+987654.32100000i")
}

///|
test "Complex::to_string/special_float_values" {
  // Infinity values
  let c1 = @lib.Complex::new(1.0 / 0.0, 2.0) // positive infinity real
  inspect(c1.to_string(), content="inf+2.00000000i")
  let c2 = @lib.Complex::new(1.0, -1.0 / 0.0) // negative infinity imaginary
  inspect(c2.to_string(), content="1.00000000-infi")

  // NaN values
  let c3 = @lib.Complex::new(0.0 / 0.0, 3.0) // NaN real
  inspect(c3.to_string(), content="nan+3.00000000i")
  let c4 = @lib.Complex::new(2.0, 0.0 / 0.0) // NaN imaginary
  inspect(c4.to_string(), content="2.00000000+nani")
}
