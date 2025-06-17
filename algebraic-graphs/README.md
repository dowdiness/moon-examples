# Algebraic Graphs Library

A MoonBit implementation of algebraic graphs based on the paper "Algebraic Graphs with Class (Functional Pearl)" by Andrey Mokhov.

## Overview

This library provides a purely functional approach to graph representation and manipulation using algebraic data types. The core idea is to represent graphs as algebraic expressions using four basic operations:

- `Empty` - The empty graph
- `Vertex(v)` - A single vertex graph
- `Overlay(x, y)` - Union of two graphs
- `Connect(x, y)` - Connect all vertices in x to all vertices in y

## Features

### Core Operations
- **Basic constructors**: `ag_empty()`, `ag_vertex()`, `ag_overlay()`, `ag_connect()`
- **Derived operations**: `ag_vertices()`, `ag_edges()`, `ag_clique()`, `ag_star()`, `ag_path()`, `ag_circuit()`
- **Graph properties**: `ag_has_vertex()`, `ag_has_edge()`, `ag_vertex_count()`, `ag_edge_count()`
- **Graph queries**: `ag_vertex_set()`, `ag_edge_set()`, `ag_is_empty()`
- **Transformations**: `ag_remove_vertex()`, `ag_remove_edge()`, `ag_map()`

### Graph Types Supported
- **Cliques**: Complete graphs where every vertex connects to every other vertex
- **Stars**: A central vertex connected to satellite vertices
- **Paths**: Linear sequences of connected vertices
- **Circuits**: Circular paths (cycles)
- **Custom graphs**: Build any graph using the algebraic operations

## Usage

```moonbit
// Create basic graphs
let v1 = ag_vertex(1)
let v2 = ag_vertex(2)
let empty = ag_empty()

// Combine graphs
let union_graph = ag_overlay(v1, v2)        // Vertices 1 and 2, no edges
let connected_graph = ag_connect(v1, v2)    // Edge from 1 to 2

// Build complex graphs
let triangle = ag_clique([1, 2, 3])         // Complete graph on 3 vertices
let star = ag_star(0, [1, 2, 3])           // Star with center 0
let path = ag_path([1, 2, 3, 4])           // Path 1->2->3->4
let cycle = ag_circuit([1, 2, 3])          // Cycle 1->2->3->1

// Query graph properties
ag_has_vertex(triangle, 2)                  // true
ag_vertex_count(triangle)                   // 3
ag_edge_count(triangle)                     // 3
ag_has_edge(triangle, 1, 2)                // true

// Transform graphs
let modified = ag_remove_vertex(triangle, 2) // Remove vertex 2
let mapped = ag_map(v1, fn(x) { "node_\{x}" }) // Map vertices to strings
```

## Building and Testing

```bash
# Build the library
moon build

# Run tests
moon test

# Run the demo
moon run
```

## Implementation Details

The library uses **Algebraic graphs** (`AlgebraicGraph[A]`) - a pure functional representation that offers several advantages:
- Compositional: Complex graphs built from simple operations
- Generic: Works with any vertex type
- Functional: Immutable data structures
- Expressive: Natural mathematical representation

## References

- [Algebraic Graphs with Class (Functional Pearl)](https://eprints.ncl.ac.uk/file_store/production/239461/EF82F5FE-66E3-4F64-A1AC-A366D1961738.pdf) by Andrey Mokhov
