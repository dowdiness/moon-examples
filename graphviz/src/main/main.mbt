///|
fn test_layout(name : String, dot : String) -> Unit {
  println("=== \{name} ===\n")

  match @lib.parse_dot(dot) {
    Some(graph) => {
      let layout = @antisatori/graphviz/lib/layout.compute_layout(graph)

      println("Layout Results:")
      println("  Nodes: \{layout.nodes.length()}")
      println("  Edges: \{layout.edges.length()}")
      println("  Layers: \{layout.layers.length()}")
      println("  Bounds: \{layout.bounds}\n")

      println("Node Positions:")
      layout.nodes.each(fn(id, node) {
        println(
          "  \{id}: layer=\{node.layer}, pos=(\{node.position.x}, \{node.position.y})",
        )
      })

      println("\nEdge Routes:")
      for edge in layout.edges {
        let rev = if edge.reversed { " (reversed)" } else { "" }
        println("  \{edge.from} -> \{edge.to}\{rev}")
      }
      println("")
    }
    None => println("Parse error\n")
  }
}

///|
fn main {
  // Test 1: Simple
  test_layout("Simple", "digraph { a -> b }")

  // Test 2: Automaton (from parser tests)
  let automaton =
    #|digraph {
    #|  0 -> 1
    #|  0 -> 2
    #|  2 -> 3
    #|  2 -> 4
    #|  3 -> 5
    #|  4 -> 6
    #|  4 -> 4
    #|  6 -> 7
    #|}
  test_layout("Automaton", automaton)
}
