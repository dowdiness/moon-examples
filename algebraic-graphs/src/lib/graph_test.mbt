///|
test "algebraic graphs" {
  // Test basic algebraic graph operations
  let empty_graph : Graph[Int] = empty()
  let v1 = vertex(1)
  let v2 = vertex(2)
  let _v3 = vertex(3)
  let overlaid = overlay(v1, v2)
  let connected = connect(v1, v2)
  println("Empty graph: \{empty_graph}")
  println("Vertex 1: \{v1}")
  println("Overlaid (1,2): \{overlaid}")
  println("Connected (1->2): \{connected}")

  // Test derived operations
  let vertex_list = vertices([1, 2, 3])
  let edge_list = edges([(1, 2), (2, 3)])
  let triangle = clique([1, 2, 3])
  let star_graph = star(0, [1, 2, 3])
  let path_graph = path([1, 2, 3, 4])
  let circuit_graph = circuit([1, 2, 3])
  println("Vertices [1,2,3]: \{vertex_list}")
  println("Edges [(1,2),(2,3)]: \{edge_list}")
  println("Triangle clique: \{triangle}")
  println("Star with center 0: \{star_graph}")
  println("Path 1->2->3->4: \{path_graph}")
  println("Circuit 1->2->3->1: \{circuit_graph}")

  // Test graph properties
  println("Has vertex 2 in overlaid: \{has_vertex(overlaid, 2)}")
  println("Has vertex 3 in overlaid: \{has_vertex(overlaid, 3)}")
  println("Vertex count of triangle: \{vertex_count(triangle)}")
  println("Edge count of triangle: \{edge_count(triangle)}")
  println("Has edge 1->2 in connected: \{has_edge(connected, 1, 2)}")
  println("Has edge 2->1 in connected: \{has_edge(connected, 2, 1)}")

  // Test graph transformation
  let removed_vertex = remove_vertex(triangle, 2)
  println("Triangle with vertex 2 removed: \{removed_vertex}")

  // Test map function
  let string_graph = map(v1, fn(x) { "vertex_\{x}" })
  println("Mapped to string: \{string_graph}")
}
