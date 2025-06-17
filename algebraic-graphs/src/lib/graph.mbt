// Based on Algebraic Graphs with Class (Functional Pearl)
// https://eprints.ncl.ac.uk/file_store/production/239461/EF82F5FE-66E3-4F64-A1AC-A366D1961738.pdf

pub fn hello() -> String {
  "Hello, world!"
}

pub(all) enum Graph[A] {
  Empty;
  Vertex(A);
  Overlay(Graph[A], Graph[A]);
  Connect(Graph[A], Graph[A]);
}
