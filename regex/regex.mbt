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

pub fn search(pattern: String, text: String) -> Bool {
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
