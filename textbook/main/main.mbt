fn main {
  let list = @lib.LinkedList::make()
  let mut i = 0
  while i < 100000 {
    let _ = list.push(i)
    i += 1
  }
  println(list.length())
}
