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

fn re2tokens(input: String) -> @list.List[ReToken] {
  loop (input[:], @list.default()) {
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

priv struct Transition (Int, Instruct) derive(Show)

priv struct NFA {
  start: Int // Start state
  transitions: @list.List[Transition] // Final state
} derive(Show)

test {
  let example: NFA = {
    start: 0,
    transitions: @list.of([
      Transition(0, Branch(1, 3)),
      Transition(1, Character('a', 3)),
      Transition(2, Eps(0)),
      Transition(3, Match)
    ])
  }
  println(example)
}
// fn tokens2re(tokens: @immut/list.T[ReToken]) -> String {
//   loop tokens {{
//     Nil => ...
//     Cons(_) => ...
//   }
// }

test "re2token" {
  assert_eq(re2tokens("a"), @list.of([CHARA('a')]))
  assert_eq(re2tokens("a.c"), @list.of([CHARA('a'), ANY, CHARA('c')]))
  assert_eq(re2tokens("ab+|c"), @list.of([CHARA('a'), CHARA('b'), PLUS, ALT, CHARA('c')]))
  assert_eq(re2tokens("z*p?"), @list.of([CHARA('z'), STAR, CHARA('p'), QUESTION]))
}
