import CompletenessChecker

// -- Example

func main() {
  let x = SemanticType.tag(name: "X", arguments: [])
  let y = SemanticType.tag(name: "Y", arguments: [])
  let z = SemanticType.tag(name: "Z", arguments: [])

  let xz = SemanticType.union([x, z])

  // Define the interface.
  let interface = SemanticSignature(parameters: [[x, y, z], [x, y, z]])

  // Define the implementations.
  let implementations: [SemanticSignature] = [
    SemanticSignature(parameters: [[x], [x, y]]),
    SemanticSignature(parameters: [[x, y], [x]]),
    SemanticSignature(parameters: [[z], [z]]),
    SemanticSignature(parameters: [[y], [y]]),
    SemanticSignature(parameters: [[xz], [y]]),
  ]

  // Run the algorithm.
  print(interface.isSatisfied(by: implementations))
}

main()
