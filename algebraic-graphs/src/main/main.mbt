fn main {
  println("=== Algebraic Graphs Library Demo ===")

  // Basic algebraic graph operations
  let v1 = @lib.ag_vertex(1)
  let v2 = @lib.ag_vertex(2)

  println("\\nBasic Operations:")
  println("Vertex 1: \{v1}")
  println("Vertex 2: \{v2}")

  let overlaid = @lib.ag_overlay(v1, v2)
  let connected = @lib.ag_connect(v1, v2)

  println("Overlay (1,2): \{overlaid}")
  println("Connect (1->2): \{connected}")

  // Derived graph constructions
  println("\\nDerived Constructions:")
  let triangle = @lib.ag_clique([1, 2, 3])
  let star_graph = @lib.ag_star(0, [1, 2, 3])
  let path_graph = @lib.ag_path([1, 2, 3, 4])
  let circuit_graph = @lib.ag_circuit([1, 2, 3])

  println("Triangle (clique): \{triangle}")
  println("Star graph: \{star_graph}")
  println("Path graph: \{path_graph}")
  println("Circuit graph: \{circuit_graph}")

  // Graph properties
  println("\\nGraph Properties:")
  println("Has vertex 2 in triangle: \{@lib.ag_has_vertex(triangle, 2)}")
  println("Vertex count of triangle: \{@lib.ag_vertex_count(triangle)}")
  println("Edge count of triangle: \{@lib.ag_edge_count(triangle)}")
  println("Has edge 1->2 in triangle: \{@lib.ag_has_edge(triangle, 1, 2)}")

  // Graph transformations
  println("\\nGraph Transformations:")
  let removed = @lib.ag_remove_vertex(triangle, 2)
  println("Triangle with vertex 2 removed: \{removed}")

  let mapped = @lib.ag_map(v1, fn(_x) { "node_1" })
  println("Mapped to strings: \{mapped}")

  println("\\n=== Demo Complete ===")
}
