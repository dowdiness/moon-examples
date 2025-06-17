// Based on Algebraic Graphs with Class (Functional Pearl)
// https://eprints.ncl.ac.uk/file_store/production/239461/EF82F5FE-66E3-4F64-A1AC-A366D1961738.pdf

// Core algebraic graph data type
pub enum AlgebraicGraph[A] {
  Empty
  Vertex(A)
  Overlay(AlgebraicGraph[A], AlgebraicGraph[A])
  Connect(AlgebraicGraph[A], AlgebraicGraph[A])
} derive(Show, Eq)

// Convenience functions for algebraic graphs
pub fn ag_empty[A]() -> AlgebraicGraph[A] {
  Empty
}

pub fn ag_vertex[A](v : A) -> AlgebraicGraph[A] {
  Vertex(v)
}

pub fn ag_overlay[A](x : AlgebraicGraph[A], y : AlgebraicGraph[A]) -> AlgebraicGraph[A] {
  Overlay(x, y)
}

pub fn ag_connect[A](x : AlgebraicGraph[A], y : AlgebraicGraph[A]) -> AlgebraicGraph[A] {
  Connect(x, y)
}

// Derived operations for algebraic graphs
pub fn ag_vertices[A](vs : Array[A]) -> AlgebraicGraph[A] {
  vs.fold(init=ag_empty(), fn(acc, v) { ag_overlay(acc, ag_vertex(v)) })
}

pub fn ag_edges[A](es : Array[(A, A)]) -> AlgebraicGraph[A] {
  es.fold(init=ag_empty(), fn(acc, edge) {
    let (u, v) = edge
    ag_overlay(acc, ag_connect(ag_vertex(u), ag_vertex(v)))
  })
}

pub fn ag_clique[A](vs : Array[A]) -> AlgebraicGraph[A] {
  let vertex_graph = ag_vertices(vs)
  ag_connect_all(vertex_graph)
}

fn ag_connect_all[A](g : AlgebraicGraph[A]) -> AlgebraicGraph[A] {
  match g {
    Empty => Empty
    Vertex(v) => Vertex(v)
    Overlay(x, y) => ag_connect(ag_connect_all(x), ag_connect_all(y))
    Connect(x, y) => Connect(ag_connect_all(x), ag_connect_all(y))
  }
}

pub fn ag_star[A](center : A, satellites : Array[A]) -> AlgebraicGraph[A] {
  let center_vertex = ag_vertex(center)
  satellites.fold(init=center_vertex, fn(acc, s) {
    ag_overlay(acc, ag_connect(center_vertex, ag_vertex(s)))
  })
}

pub fn ag_path[A](vs : Array[A]) -> AlgebraicGraph[A] {
  if vs.length() <= 1 {
    ag_vertices(vs)
  } else {
    let mut result = ag_empty()
    for i = 0; i < vs.length(); i = i + 1 {
      if i == 0 {
        result = ag_vertex(vs[i])
      } else {
        result = ag_overlay(result, ag_connect(ag_vertex(vs[i - 1]), ag_vertex(vs[i])))
      }
    }
    result
  }
}

pub fn ag_circuit[A](vs : Array[A]) -> AlgebraicGraph[A] {
  if vs.length() <= 1 {
    ag_vertices(vs)
  } else {
    let p = ag_path(vs)
    ag_overlay(p, ag_connect(ag_vertex(vs[vs.length() - 1]), ag_vertex(vs[0])))
  }
}

// Graph properties and algorithms for algebraic graphs
pub fn ag_is_empty[A](g : AlgebraicGraph[A]) -> Bool {
  match g {
    Empty => true
    _ => false
  }
}

pub fn ag_has_vertex[A : Eq](g : AlgebraicGraph[A], v : A) -> Bool {
  match g {
    Empty => false
    Vertex(u) => u == v
    Overlay(x, y) => ag_has_vertex(x, v) || ag_has_vertex(y, v)
    Connect(x, y) => ag_has_vertex(x, v) || ag_has_vertex(y, v)
  }
}

pub fn ag_vertex_count[A : Eq](g : AlgebraicGraph[A]) -> Int {
  ag_vertex_set(g).length()
}

pub fn ag_vertex_set[A : Eq](g : AlgebraicGraph[A]) -> Array[A] {
  match g {
    Empty => []
    Vertex(v) => [v]
    Overlay(x, y) => merge_unique(ag_vertex_set(x), ag_vertex_set(y))
    Connect(x, y) => merge_unique(ag_vertex_set(x), ag_vertex_set(y))
  }
}

fn merge_unique[A : Eq](xs : Array[A], ys : Array[A]) -> Array[A] {
  let result = []
  for x in xs {
    result.push(x)
  }
  for y in ys {
    if not(result.contains(y)) {
      result.push(y)
    }
  }
  result
}

pub fn ag_edge_set[A : Eq](g : AlgebraicGraph[A]) -> Array[(A, A)] {
  match g {
    Empty => []
    Vertex(_) => []
    Overlay(x, y) => {
      let result = []
      for e in ag_edge_set(x) {
        result.push(e)
      }
      for e in ag_edge_set(y) {
        result.push(e)
      }
      result
    }
    Connect(x, y) => {
      let result = []
      for e in ag_edge_set(x) {
        result.push(e)
      }
      for e in ag_edge_set(y) {
        result.push(e)
      }
      let x_vertices = ag_vertex_set(x)
      let y_vertices = ag_vertex_set(y)
      for u in x_vertices {
        for v in y_vertices {
          result.push((u, v))
        }
      }
      result
    }
  }
}

pub fn ag_edge_count[A : Eq](g : AlgebraicGraph[A]) -> Int {
  ag_edge_set(g).length()
}

pub fn ag_has_edge[A : Eq](g : AlgebraicGraph[A], u : A, v : A) -> Bool {
  ag_edge_set(g).contains((u, v))
}

// Graph transformation for algebraic graphs
pub fn ag_remove_vertex[A : Eq](g : AlgebraicGraph[A], v : A) -> AlgebraicGraph[A] {
  match g {
    Empty => Empty
    Vertex(u) => if u == v { Empty } else { Vertex(u) }
    Overlay(x, y) => ag_overlay(ag_remove_vertex(x, v), ag_remove_vertex(y, v))
    Connect(x, y) => ag_connect(ag_remove_vertex(x, v), ag_remove_vertex(y, v))
  }
}

pub fn ag_remove_edge[A : Eq](g : AlgebraicGraph[A], u : A, v : A) -> AlgebraicGraph[A] {
  match g {
    Empty => Empty
    Vertex(w) => Vertex(w)
    Overlay(x, y) => ag_overlay(ag_remove_edge(x, u, v), ag_remove_edge(y, u, v))
    Connect(x, y) => {
      if ag_has_vertex(x, u) && ag_has_vertex(y, v) {
        ag_overlay(ag_overlay(x, y), ag_connect(ag_remove_vertex(x, u), ag_remove_vertex(y, v)))
      } else {
        ag_connect(ag_remove_edge(x, u, v), ag_remove_edge(y, u, v))
      }
    }
  }
}

// Map function for algebraic graphs
pub fn ag_map[A, B](g : AlgebraicGraph[A], f : (A) -> B) -> AlgebraicGraph[B] {
  match g {
    Empty => Empty
    Vertex(v) => Vertex(f(v))
    Overlay(x, y) => Overlay(ag_map(x, f), ag_map(y, f))
    Connect(x, y) => Connect(ag_map(x, f), ag_map(y, f))
  }
}


test "algebraic graphs" {
  // Test basic algebraic graph operations
  let empty_graph : AlgebraicGraph[Int] = ag_empty()
  let v1 = ag_vertex(1)
  let v2 = ag_vertex(2)
  let _v3 = ag_vertex(3)

  let overlaid = ag_overlay(v1, v2)
  let connected = ag_connect(v1, v2)

  println("Empty graph: \{empty_graph}")
  println("Vertex 1: \{v1}")
  println("Overlaid (1,2): \{overlaid}")
  println("Connected (1->2): \{connected}")

  // Test derived operations
  let vertex_list = ag_vertices([1, 2, 3])
  let edge_list = ag_edges([(1, 2), (2, 3)])
  let triangle = ag_clique([1, 2, 3])
  let star_graph = ag_star(0, [1, 2, 3])
  let path_graph = ag_path([1, 2, 3, 4])
  let circuit_graph = ag_circuit([1, 2, 3])

  println("Vertices [1,2,3]: \{vertex_list}")
  println("Edges [(1,2),(2,3)]: \{edge_list}")
  println("Triangle clique: \{triangle}")
  println("Star with center 0: \{star_graph}")
  println("Path 1->2->3->4: \{path_graph}")
  println("Circuit 1->2->3->1: \{circuit_graph}")

  // Test graph properties
  println("Has vertex 2 in overlaid: \{ag_has_vertex(overlaid, 2)}")
  println("Has vertex 3 in overlaid: \{ag_has_vertex(overlaid, 3)}")
  println("Vertex count of triangle: \{ag_vertex_count(triangle)}")
  println("Edge count of triangle: \{ag_edge_count(triangle)}")
  println("Has edge 1->2 in connected: \{ag_has_edge(connected, 1, 2)}")
  println("Has edge 2->1 in connected: \{ag_has_edge(connected, 2, 1)}")

  // Test graph transformation
  let removed_vertex = ag_remove_vertex(triangle, 2)
  println("Triangle with vertex 2 removed: \{removed_vertex}")

  // Test map function
  let string_graph = ag_map(v1, fn(x) { "vertex_\{x}" })
  println("Mapped to string: \{string_graph}")
}

