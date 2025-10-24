// Based on Algebraic Graphs with Class (Functional Pearl)
// https://eprints.ncl.ac.uk/file_store/production/239461/EF82F5FE-66E3-4F64-A1AC-A366D1961738.pdf

// Core algebraic graph data type
///|
pub enum Graph[A] {
  Empty
  Vertex(A)
  Overlay(Graph[A], Graph[A])
  Connect(Graph[A], Graph[A])
} derive(Show, Eq)

pub impl [A] Add for Graph[A] with add(self: Graph[A], other: Graph[A]) {
  Overlay(self, other)
}

pub impl [A] Mul for Graph[A] with mul(self, other) {
  Connect(self, other)
}

pub fn[A, B] foldg(
  e: B,
  v: (A) -> B,
  o: (B, B) -> B,
  c: (B, B) -> B
) -> (Graph[A]) -> B {
  fn go(input: Graph[A]) -> B {
    match input {
      Empty => e
      Vertex(x) => v(x)
      Overlay(x, y) => o(go(x), go(y))
      Connect(x, y) => c(go(x), go(y))
    }
  }
  go
}

// Convenience functions for algebraic graphs

///|
pub fn[A] empty() -> Graph[A] {
  Empty
}

///|
pub fn[A] vertex(v : A) -> Graph[A] {
  Vertex(v)
}

///|
pub fn[A] egde(x : A, y : A) -> Graph[A] {
  Connect(vertex(x), vertex(y))
}

///|
pub fn[A] overlay(x : Graph[A], y : Graph[A]) -> Graph[A] {
  Overlay(x, y)
}

///|
pub fn[A] connect(x : Graph[A], y : Graph[A]) -> Graph[A] {
  Connect(x, y)
}

// Derived operations for algebraic graphs

///|
pub fn[A] vertices(vs : Array[A]) -> Graph[A] {
  vs.fold(init=empty(), fn(acc, v) { overlay(acc, vertex(v)) })
}

///|
pub fn[A] edges(es : Array[(A, A)]) -> Graph[A] {
  es.fold(init=empty(), fn(acc, edge) {
    let (u, v) = edge
    overlay(acc, connect(vertex(u), vertex(v)))
  })
}

///|
pub fn[A] clique(vs : Array[A]) -> Graph[A] {
  let vertex_graph = vertices(vs)
  connect_all(vertex_graph)
}

///|
fn[A] connect_all(g : Graph[A]) -> Graph[A] {
  match g {
    Empty => Empty
    Vertex(v) => Vertex(v)
    Overlay(x, y) => connect(connect_all(x), connect_all(y))
    Connect(x, y) => Connect(connect_all(x), connect_all(y))
  }
}

///|
pub fn[A] star(center : A, satellites : Array[A]) -> Graph[A] {
  let center_vertex = vertex(center)
  satellites.fold(init=center_vertex, fn(acc, s) {
    overlay(acc, connect(center_vertex, vertex(s)))
  })
}

///|
pub fn[A] path(vs : Array[A]) -> Graph[A] {
  if vs.length() <= 1 {
    vertices(vs)
  } else {
    let mut result = empty()
    for i = 0; i < vs.length(); i = i + 1 {
      if i == 0 {
        result = vertex(vs[i])
      } else {
        result = overlay(result, connect(vertex(vs[i - 1]), vertex(vs[i])))
      }
    }
    result
  }
}

///|
pub fn[A] circuit(vs : Array[A]) -> Graph[A] {
  if vs.length() <= 1 {
    vertices(vs)
  } else {
    let p = path(vs)
    overlay(p, connect(vertex(vs[vs.length() - 1]), vertex(vs[0])))
  }
}

// Graph properties and algorithms for algebraic graphs

///|
pub fn[A] is_empty(g : Graph[A]) -> Bool {
  match g {
    Empty => true
    _ => false
  }
}

///|
pub fn[A : Eq] has_vertex(g : Graph[A], v : A) -> Bool {
  match g {
    Empty => false
    Vertex(u) => u == v
    Overlay(x, y) => has_vertex(x, v) || has_vertex(y, v)
    Connect(x, y) => has_vertex(x, v) || has_vertex(y, v)
  }
}

///|
pub fn[A : Eq] vertex_count(g : Graph[A]) -> Int {
  vertex_set(g).length()
}

///|
pub fn[A : Eq] vertex_set(g : Graph[A]) -> Array[A] {
  match g {
    Empty => []
    Vertex(v) => [v]
    Overlay(x, y) => merge_unique(vertex_set(x), vertex_set(y))
    Connect(x, y) => merge_unique(vertex_set(x), vertex_set(y))
  }
}

///|
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

///|
pub fn[A : Eq] edge_set(g : Graph[A]) -> Array[(A, A)] {
  match g {
    Empty => []
    Vertex(_) => []
    Overlay(x, y) => {
      let result = []
      for e in edge_set(x) {
        result.push(e)
      }
      for e in edge_set(y) {
        result.push(e)
      }
      result
    }
    Connect(x, y) => {
      let result = []
      for e in edge_set(x) {
        result.push(e)
      }
      for e in edge_set(y) {
        result.push(e)
      }
      let x_vertices = vertex_set(x)
      let y_vertices = vertex_set(y)
      for u in x_vertices {
        for v in y_vertices {
          result.push((u, v))
        }
      }
      result
    }
  }
}

///|
pub fn[A : Eq] edge_count(g : Graph[A]) -> Int {
  edge_set(g).length()
}

///|
pub fn[A : Eq] has_edge(g : Graph[A], u : A, v : A) -> Bool {
  edge_set(g).contains((u, v))
}

// Graph transformation for algebraic graphs

///|
pub fn[A : Eq] remove_vertex(g : Graph[A], v : A) -> Graph[A] {
  match g {
    Empty => Empty
    Vertex(u) => if u == v { Empty } else { Vertex(u) }
    Overlay(x, y) => overlay(remove_vertex(x, v), remove_vertex(y, v))
    Connect(x, y) => connect(remove_vertex(x, v), remove_vertex(y, v))
  }
}

///|
pub fn[A : Eq] remove_edge(g : Graph[A], u : A, v : A) -> Graph[A] {
  match g {
    Empty => Empty
    Vertex(w) => Vertex(w)
    Overlay(x, y) => overlay(remove_edge(x, u, v), remove_edge(y, u, v))
    Connect(x, y) =>
      if has_vertex(x, u) && has_vertex(y, v) {
        overlay(
          overlay(x, y),
          connect(remove_vertex(x, u), remove_vertex(y, v)),
        )
      } else {
        connect(remove_edge(x, u, v), remove_edge(y, u, v))
      }
  }
}

// Map function for algebraic graphs

///|
pub fn[A, B] map(g : Graph[A], f : (A) -> B) -> Graph[B] {
  match g {
    Empty => Empty
    Vertex(v) => Vertex(f(v))
    Overlay(x, y) => Overlay(map(x, f), map(y, f))
    Connect(x, y) => Connect(map(x, f), map(y, f))
  }
}
