// SVG Renderer Tests

///|
test "save_svg_creates_file" {
  let dot = "digraph { a -> b }"
  match @parser.parse_dot(dot) {
    Some(graph) => {
      let layout = @layout.compute_layout(graph)
      let filename = "test_output.svg"

      // Save to file
      match save_svg(layout, filename) {
        Ok(_) =>
          // File should be created successfully
          inspect(true, content="true")
        Err(e) => {
          println("Error saving file: \{e}")
          inspect(false, content="true")
        }
      }
    }
    None => {
      println("Parse failed")
      inspect(false, content="true")
    }
  }
}

///|
test "render_svg_produces_valid_xml_header" {
  let dot = "digraph { x -> y }"
  match @parser.parse_dot(dot) {
    Some(graph) => {
      let layout = @layout.compute_layout(graph)
      let svg = render_svg(layout)

      // Check for XML declaration
      let has_xml_header = svg.contains(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
      )
      inspect(has_xml_header, content="true")

      // Check for SVG root element
      let has_svg_element = svg.contains(
        "<svg xmlns=\"http://www.w3.org/2000/svg\"",
      )
      inspect(has_svg_element, content="true")
    }
    None => {
      println("Parse failed")
      inspect(false, content="true")
    }
  }
}

///|
test "render_svg_includes_arrowhead_for_directed_graph" {
  let dot = "digraph { a -> b }"
  match @parser.parse_dot(dot) {
    Some(graph) => {
      let layout = @layout.compute_layout(graph)
      let svg = render_svg(layout)

      // Should have arrow marker definition
      let has_arrowhead = svg.contains("<marker id=\"arrowhead\"")
      inspect(has_arrowhead, content="true")
    }
    None => {
      println("Parse failed")
      inspect(false, content="true")
    }
  }
}

///|
test "render_svg_no_arrowhead_for_undirected_graph" {
  let dot = "graph { a -- b }"
  match @parser.parse_dot(dot) {
    Some(graph) => {
      let layout = @layout.compute_layout(graph)
      let svg = render_svg(layout)

      // Should NOT have arrow marker definition
      let has_arrowhead = svg.contains("<marker id=\"arrowhead\"")
      inspect(has_arrowhead, content="false")
    }
    None => {
      println("Parse failed")
      inspect(false, content="true")
    }
  }
}
