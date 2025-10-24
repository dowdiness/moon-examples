test "MatchOneCharacter" {
  assert_eq(search("a", "a"), true)
  assert_eq(search("a", "b"), false)
  assert_eq(search("aa", "aa"), true)
  assert_eq(search("", "a"), true)
  assert_eq(search("p", ""), false)
  assert_eq(search(".", "a"), true)
}

test "Wildcard" {
  assert_eq(search("h.llo", "hello"), true)
  assert_eq(search("h.llo", "hallo"), true)
  assert_eq(search("h.llo", "hllo"), false)
  assert_eq(search(".", "A"), true)  // single dot matches any one char
  assert_eq(search(".", ""), false)  // dot cannot match empty string
}

// $
test "$ anchor" {
  assert_eq(search("$", "a"), false)
  assert_eq(search("$", ""), true)
  assert_eq(search("lo$", "hello"), true)
  assert_eq(search("lo$", "lo!"), false)
}

// ^
test "^ anchor"{
  assert_eq(search("^", "a"), true)
  assert_eq(search("^abc", "abc"), true)
  assert_eq(search("^abcd", "abcd"), true)
  assert_eq(search("bc", "abcd"), true)
}

// ?
test "Optional ?" {
  assert_eq(search("ab?c", "ac"), true)
  assert_eq(search("ab?c", "abc"), true)
  assert_eq(search("a?b?c?", "abc"), true)
  assert_eq(search("a?b?c?", ""), true)
}

test "Kleene Star *" {
  // * means preceding char repeated 0 or more times
  assert_eq(search("ab*c", "ac"), true)
  assert_eq(search("ab*c", "abc"), true)
  assert_eq(search("ab*c", "abbbbbc"), true)
  assert_eq(search("ab*c", "abbxd"), false)
}

test "choice |" {
  assert_eq(search("a|b", "a"), true)
  assert_eq(search("a|b", "b"), true)
  assert_eq(search("a|b", "c"), false)
  assert_eq(search("a|b|c", "c"), true)
  assert_eq(search("a|b|c", "d"), false)
  assert_eq(search("abc|def", "abc"), true)
  assert_eq(search("abc|def", "def"), true)
  assert_eq(search("abc|def", "gh"), false)
}

test "General test" {
  assert_eq(search("hello", "hello"), true)
  assert_eq(search("hello", "hell"), false)
  assert_eq(search("h.llo", "hello"), true)
  assert_eq(search("h.llo", "hllo"), false)
  assert_eq(search("colou?r", "color"), true)
  assert_eq(search("colou?r", "colouur"), false)
  assert_eq(search("ab*c", "abbbc"), true)
  assert_eq(search("lo$", "hello"), true)
  assert_eq(search("^hi", "ahihi"), false)
  assert_eq(search("foo*", "table football"), true)
}

// fn random_string(chars: String, len: Int) -> String {
//   let mut result = ""
//   let arr = chars.to_array()[:]
//   let max = arr.length().reinterpret_as_uint()
//   let r = @random.new()
//   for _ in 0..=len {
//     let i = (r.uint() % max).reinterpret_as_int()
//     result = result + arr[i].to_string()
//   }
//   result
// }

// fn fuzz_regex_engine(iterations: Int) -> Unit {
//   let charset = "abc.*?$^"
//   for i in 0..=iterations {
//     let pattern = random_string(charset, 5)
//     let text = random_string(charset, 5)

//     let _ = search(pattern, text)  // Panic = test failure

//     if i % 500 == 0 {
//       println("Fuzz \{i}: pattern = \{pattern}, text = \{text}")
//     }
//   }
// }

// test "Fuzzing test" {
//   fuzz_regex_engine(5000)
//   assert_eq(true, true)
// }
