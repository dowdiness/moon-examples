// Build a Regex Engine in Less than 40 Lines of Code
// https://nickdrane.com/build-your-own-regex/

// This is a simple regex engine that supports the following features:
// - Literal characters
// - Wildcard (.) matches any single character
// - Anchors (^ and $)
// - Optional character (?)
// - Kleene star (*) matches zero or more of the preceding character
// - Concatenation
// - Alternation (|)

fn safe_char_at(s: String, i: Int) -> Option[Char] {
  if i < s.length() {
    Some(s.char_at(i))
  } else {
    None
  }
}

fn safe_substring(s: String, start: Int) -> String {
  if start <= s.length() {
    s.substring(start=start)
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
    _ => match safe_char_at(pattern, 1) {
      Some('?') => matchQuestionMark(pattern, text)
      Some('*') => matchStar(pattern, text)
      _ => match (safe_char_at(pattern, 0), safe_char_at(text, 0)) {
        (Some(pc), Some(tc)) if matchChar(pc, tc) =>
          matchRegex(safe_substring(pattern, 1), safe_substring(text, 1))
        _ => false
      }
    }
  }
}

fn matchQuestionMark(pattern: String, text: String) -> Bool {
  match (safe_char_at(pattern, 0), safe_char_at(text, 0)) {
    (Some(pc), Some(tc)) if matchChar(pc, tc) =>
      matchRegex(safe_substring(pattern, 2), safe_substring(text, 1))
    _ => matchRegex(safe_substring(pattern, 2), text)
  }
}

fn matchStar(pattern: String, text: String) -> Bool {
  match (safe_char_at(pattern, 0), safe_char_at(text, 0)) {
    (Some(pc), Some(tc)) if matchChar(pc, tc) =>
      matchRegex(safe_substring(pattern, 2), text) ||
      matchStar(pattern, safe_substring(text, 1))
    _ => matchRegex(safe_substring(pattern, 2), text)
  }
}

fn search(pattern: String, text: String) -> Bool {
  // Check if the pattern contains choice (|)
  if pattern.contains("|") {
    pattern.split("|")
      .to_array()
      .map(fn (p) -> Bool {
        search(p.to_string(), text)
      })
      .contains(true)
  } else {
    match pattern {
      "" => true
      _ => match safe_char_at(pattern, 0) {
        Some('^') => matchRegex(safe_substring(pattern, 1), text)
        _ if text.is_empty() => matchRegex(pattern, text)
        _ => {
          let mut r = false
          fn judge (i: Int, _: Char) -> Unit {
            if matchRegex(pattern, safe_substring(text, i)) {
              r = true
            }
          }
          text.to_array()[:].eachi(judge)
          r
        }
      }
    }
  }
}

test "MatchOneCharacter" {
  assert_eq!(search("a", "a"), true)
  assert_eq!(search("a", "b"), false)
  assert_eq!(search("aa", "aa"), true)
  assert_eq!(search("", "a"), true)
  assert_eq!(search("p", ""), false)
  assert_eq!(search(".", "a"), true)
}

test "Wildcard" {
  assert_eq!(search("h.llo", "hello"), true)
  assert_eq!(search("h.llo", "hallo"), true)
  assert_eq!(search("h.llo", "hllo"), false)
  assert_eq!(search(".", "A"), true)  // single dot matches any one char
  assert_eq!(search(".", ""), false)  // dot cannot match empty string
}

// $
test "$ anchor" {
  assert_eq!(search("$", "a"), false)
  assert_eq!(search("$", ""), true)
  assert_eq!(search("lo$", "hello"), true)
  assert_eq!(search("lo$", "lo!"), false)
}

// ^
test "^ anchor"{
  assert_eq!(search("^", "a"), true)
  assert_eq!(search("^abc", "abc"), true)
  assert_eq!(search("^abcd", "abcd"), true)
  assert_eq!(search("bc", "abcd"), true)
}

// ?
test "Optional ?" {
  assert_eq!(search("ab?c", "ac"), true)
  assert_eq!(search("ab?c", "abc"), true)
  assert_eq!(search("a?b?c?", "abc"), true)
  assert_eq!(search("a?b?c?", ""), true)
}

test "Kleene Star *" {
  // * means preceding char repeated 0 or more times
  assert_eq!(search("ab*c", "ac"), true)
  assert_eq!(search("ab*c", "abc"), true)
  assert_eq!(search("ab*c", "abbbbbc"), true)
  assert_eq!(search("ab*c", "abbxd"), false)
}

test "choice |" {
  assert_eq!(search("a|b", "a"), true)
  assert_eq!(search("a|b", "b"), true)
  assert_eq!(search("a|b", "c"), false)
  assert_eq!(search("a|b|c", "c"), true)
  assert_eq!(search("a|b|c", "d"), false)
  assert_eq!(search("abc|def", "abc"), true)
  assert_eq!(search("abc|def", "def"), true)
  assert_eq!(search("abc|def", "gh"), false)
}

test "General test" {
  // assert_eq!(search("hello", "hello"), true)
  // assert_eq!(search("hello", "hell"), false)
  // assert_eq!(search("h.llo", "hello"), true)
  // assert_eq!(search("h.llo", "hllo"), false)
  // assert_eq!(search("colou?r", "color"), true)
  // assert_eq!(search("colou?r", "colouur"), false)
  // assert_eq!(search("ab*c", "abbbc"), true)
  // assert_eq!(search("lo$", "hello"), true)
  // assert_eq!(search("^hi", "ahihi"), false)
  assert_eq!(search("foo*", "table football"), true)
}
