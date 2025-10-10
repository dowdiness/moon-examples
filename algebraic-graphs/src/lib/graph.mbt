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
pub fn[A] ag_empty() -> AlgebraicGraph[A] {
  Empty
}

pub fn[A] ag_vertex(v : A) -> AlgebraicGraph[A] {
  Vertex(v)
}

pub fn[A] ag_overlay(x : AlgebraicGraph[A], y : AlgebraicGraph[A]) -> AlgebraicGraph[A] {
  Overlay(x, y)
}

pub fn[A] ag_connect(x : AlgebraicGraph[A], y : AlgebraicGraph[A]) -> AlgebraicGraph[A] {
  Connect(x, y)
}

// Derived operations for algebraic graphs
pub fn[A] ag_vertices(vs : Array[A]) -> AlgebraicGraph[A] {
  vs.fold(init=ag_empty(), fn(acc, v) { ag_overlay(acc, ag_vertex(v)) })
}

pub fn[A] ag_edges(es : Array[(A, A)]) -> AlgebraicGraph[A] {
  es.fold(init=ag_empty(), fn(acc, edge) {
    let (u, v) = edge
    ag_overlay(acc, ag_connect(ag_vertex(u), ag_vertex(v)))
  })
}

pub fn[A] ag_clique(vs : Array[A]) -> AlgebraicGraph[A] {
  let vertex_graph = ag_vertices(vs)
  ag_connect_all(vertex_graph)
}

fn[A] ag_connect_all(g : AlgebraicGraph[A]) -> AlgebraicGraph[A] {
  match g {
    Empty => Empty
    Vertex(v) => Vertex(v)
    Overlay(x, y) => ag_connect(ag_connect_all(x), ag_connect_all(y))
    Connect(x, y) => Connect(ag_connect_all(x), ag_connect_all(y))
  }
}

pub fn[A] ag_star(center : A, satellites : Array[A]) -> AlgebraicGraph[A] {
  let center_vertex = ag_vertex(center)
  satellites.fold(init=center_vertex, fn(acc, s) {
    ag_overlay(acc, ag_connect(center_vertex, ag_vertex(s)))
  })
}

pub fn[A] ag_path(vs : Array[A]) -> AlgebraicGraph[A] {
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

pub fn[A] ag_circuit(vs : Array[A]) -> AlgebraicGraph[A] {
  if vs.length() <= 1 {
    ag_vertices(vs)
  } else {
    let p = ag_path(vs)
    ag_overlay(p, ag_connect(ag_vertex(vs[vs.length() - 1]), ag_vertex(vs[0])))
  }
}

// Graph properties and algorithms for algebraic graphs
pub fn[A] ag_is_empty(g : AlgebraicGraph[A]) -> Bool {
  match g {
    Empty => true
    _ => false
  }
}

pub fn[A : Eq] ag_has_vertex(g : AlgebraicGraph[A], v : A) -> Bool {
  match g {
    Empty => false
    Vertex(u) => u == v
    Overlay(x, y) => ag_has_vertex(x, v) || ag_has_vertex(y, v)
    Connect(x, y) => ag_has_vertex(x, v) || ag_has_vertex(y, v)
  }
}

pub fn[A : Eq] ag_vertex_count(g : AlgebraicGraph[A]) -> Int {
  ag_vertex_set(g).length()
}

pub fn[A : Eq] ag_vertex_set(g : AlgebraicGraph[A]) -> Array[A] {
  match g {
    Empty => []
    Vertex(v) => [v]
    Overlay(x, y) => merge_unique(ag_vertex_set(x), ag_vertex_set(y))
    Connect(x, y) => merge_unique(ag_vertex_set(x), ag_vertex_set(y))
  }
}

fn[A : Eq] merge_unique(xs : Array[A], ys : Array[A]) -> Array[A] {
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

pub fn[A : Eq] ag_edge_set(g : AlgebraicGraph[A]) -> Array[(A, A)] {
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

pub fn[A : Eq] ag_edge_count(g : AlgebraicGraph[A]) -> Int {
  ag_edge_set(g).length()
}

pub fn[A : Eq] ag_has_edge(g : AlgebraicGraph[A], u : A, v : A) -> Bool {
  ag_edge_set(g).contains((u, v))
}

// Graph transformation for algebraic graphs
pub fn[A : Eq] ag_remove_vertex(g : AlgebraicGraph[A], v : A) -> AlgebraicGraph[A] {
  match g {
    Empty => Empty
    Vertex(u) => if u == v { Empty } else { Vertex(u) }
    Overlay(x, y) => ag_overlay(ag_remove_vertex(x, v), ag_remove_vertex(y, v))
    Connect(x, y) => ag_connect(ag_remove_vertex(x, v), ag_remove_vertex(y, v))
  }
}

pub fn[A : Eq] ag_remove_edge(g : AlgebraicGraph[A], u : A, v : A) -> AlgebraicGraph[A] {
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
pub fn[A, B] ag_map(g : AlgebraicGraph[A], f : (A) -> B) -> AlgebraicGraph[B] {
  match g {
    Empty => Empty
    Vertex(v) => Vertex(f(v))
    Overlay(x, y) => Overlay(ag_map(x, f), ag_map(y, f))
    Connect(x, y) => Connect(ag_map(x, f), ag_map(y, f))
  }
}
