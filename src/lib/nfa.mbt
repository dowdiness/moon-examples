// Regular expression implementation
// Supports only ( | ) * + ?
// Regex Grammer
// r ::= .            (match any character)
//       rr           (sequencing)
//       r|r          (alternation)
//       r?           (zero or one)
//       r*           (zero or more)
//       r+           (one or more)
//       c            (literal character)

// https://swtch.com/~rsc/regexp/nfa.c.txt

priv enum ReToken {
  ANY // any character
  ALT // '|''
  QUESTION // '?' zero or one
  STAR // '*' zero or more
  PLUS // '+' one or more
  CHARA(Char) // literal
} derive (Eq, Show)
fn re2tokens(input: String) -> @immut/list.T[ReToken] {
  loop (input[:], @immut/list.default()) {
    (['.', ..rest], acc) => continue (rest, acc.add(ANY))
    (['|', ..rest], acc) => continue (rest, acc.add(ALT))
    (['*', ..rest], acc) => continue (rest, acc.add(STAR))
    (['+', ..rest], acc) => continue (rest, acc.add(PLUS))
    (['?', ..rest], acc) => continue (rest, acc.add(QUESTION))
    ([c, ..rest], acc) => continue (rest, acc.add(CHARA(c)))
    ([], acc) => acc.rev()
  }
}

pub(all) enum Instruct {
  Eps(Int)
  Branch(Int, Int)
  Character(Char, Int)
  Match
} derive (Show)

priv type Transition (Int, Instruct) derive(Show)

priv struct NFA {
  start: Int // Start state
  transitions: @immut/list.T[Transition] // Final state
} derive(Show)

test {
  let example: NFA = {
    start: 0,
    transitions: @immut/list.of([
      (0, Branch(1, 3)),
      (1, Character('a', 3)),
      (2, Eps(0)),
      (3, Match)
    ])}
  println(example.transitions)
}
// fn tokens2re(tokens: @immut/list.T[ReToken]) -> String {
//   loop tokens {{
//     Nil => ...
//     Cons(_) => ...
//   }
// }

test "re2token" {
  assert_eq!(re2tokens("a"), @immut/list.of([CHARA('a')]))
  assert_eq!(re2tokens("a.c"), @immut/list.of([CHARA('a'), ANY, CHARA('c')]))
  assert_eq!(re2tokens("ab+|c"), @immut/list.of([CHARA('a'), CHARA('b'), PLUS, ALT, CHARA('c')]))
  assert_eq!(re2tokens("z*p?"), @immut/list.of([CHARA('z'), STAR, CHARA('p'), QUESTION]))
}
