// Build a Regex Engine in Less than 40 Lines of Code

// Warning: This implementation can lead to catastrophic backtracking
// https://v8.dev/blog/non-backtracking-regexp

// Backtracking Regex Engine based on the blog post:
// https://nickdrane.com/build-your-own-regex/

// JS Implementation example:
// https://github.com/richardartoul/regex-engine/blob/master/regexEngine.js

// This is a simple regex engine that supports the following features:
// - Literal characters
// - Wildcard (.) matches any single character
// - Anchors (^ and $)
// - Optional character (?)
// - Kleene star (*) matches zero or more of the preceding character
// - Concatenation
// - Alternation (|)
// - Grouping (()) is not supported in this implementation
// - Character classes ([]) are not supported in this implementation
// - Backreferences (\1, \2, etc.) are not supported in this implementation
// - Lookahead and lookbehind assertions are not supported in this implementation
// - Unicode support is not implemented
// - Case-insensitive matching is not implemented
// - Multiline matching is not implemented
// - Dotall matching (.) is not implemented
// - Non-capturing groups (?:...) are not supported in this implementation
// - Named groups (?P<name>...) are not supported in this implementation
// - Possessive quantifiers (*+, ?+, ++, etc.) are not supported in this implementation

fn safe_substring(s: String, start: Int) -> String {
  if start <= s.length() {
    try {
      s[start:].to_string()
    } catch {
      _ => ""
    }
  } else {
    ""
  }
}

fn matchChar(pattern: Char, text: Char) -> Bool {
  match pattern {
    '.' => true
    _ if pattern == text => true
    _ => false
  }
}

fn matchRegex(pattern: String, text: String) -> Bool {
  match pattern {
    "" => true
    "$" if text.is_empty() => true
    _ => match pattern.get_char(1) {
      Some('?') => matchQuestionMark(pattern, text)
      Some('*') => matchStar(pattern, text)
      _ => match (pattern.get_char(0), text.get_char(0)) {
        (Some(pc), Some(tc)) if matchChar(pc, tc) =>
          matchRegex(safe_substring(pattern, 1), safe_substring(text, 1))
        _ => false
      }
    }
  }
}

fn matchQuestionMark(pattern: String, text: String) -> Bool {
  match (pattern.get_char(0), text.get_char(0)) {
    (Some(pc), Some(tc)) if matchChar(pc, tc) =>
      matchRegex(safe_substring(pattern, 2), safe_substring(text, 1))
    _ => matchRegex(safe_substring(pattern, 2), text)
  }
}

fn matchStar(pattern: String, text: String) -> Bool {
  match (pattern.get_char(0), text.get_char(0)) {
    (Some(pc), Some(tc)) if matchChar(pc, tc) =>
      matchRegex(safe_substring(pattern, 2), text) ||
      matchStar(pattern, safe_substring(text, 1))
    _ => matchRegex(safe_substring(pattern, 2), text)
  }
}

fn search(pattern: String, text: String) -> Bool {
  match pattern {
    // Empty string matches any string
    "" => true
    // Boolean "or": Check if the pattern contains choice (|)
    p if p.contains("|") => p.split("|")
      .to_array()
      .map(fn (p) -> Bool {
        search(p.to_string(), text)
      })
      .contains(true)
    p => match p.get_char(0) {
      // Quantifications
      Some('^') => matchRegex(safe_substring(p, 1), text)
      Some(_) if text.is_empty() => matchRegex(p, text)
      _ => {
        // Looping through the text to find a match
        // This is a naive implementation backtracking algorithm and can
        // lead to catastrophic backtracking in some cases, but it's simple
        // and works for basic regex patterns.
        text
          .to_array()[:]
          .mapi(fn (i, _) { matchRegex(p, safe_substring(text, i)) })
          .contains(true)
      }
    }
  }
}

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
