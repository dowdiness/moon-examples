# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a MoonBit implementation of algebraic graphs, based on the paper "Algebraic Graphs with Class (Functional Pearl)". The codebase demonstrates both trait-based and generic approaches to graph representation and manipulation.

## Common Commands

- `moon build` - Build the project
- `moon test` - Run all tests
- `moon run` - Run the main program
- `moon check` - Type check without building
- `moon fmt` - Format code
- `moon clean` - Clean build artifacts

## Architecture

The implementation provides two complementary approaches:

1. **Trait-based approach**: `IntGraph` trait with `AdjacencyGraph` struct for integer vertices
2. **Generic approach**: `Graph[V]` struct with generic functions for any vertex type

Core graph operations:
- `empty()` - Create empty graph
- `vertex(v)` - Single vertex graph
- `overlay(g1, g2)` - Union of two graphs
- `connect(g1, g2)` - Connect all vertices in g1 to all vertices in g2

The main module (`src/main/`) demonstrates usage, while the library (`src/lib/`) contains the core implementation and comprehensive tests.