import Foundation

func isSatisfied(
  _ interface: SemanticSignature,
  by implementations: [SemanticSignature]
) {
  /// The state space.
  var states: Set<SemanticSignature> = [interface]
  /// The states representing the unmatched parts of the interface.
  var leaves: Set<SemanticSignature> = []

  while !states.isEmpty {
    if let (successors, newLeaves) = step(states: states, implementations: implementations) {
      states = successors
      leaves.formUnion(newLeaves)
    } else if leaves.isEmpty {
      print("complete")
      return
    } else {
      break
    }
  }

  print("incomplete: \(leaves)")
}

enum StepResult {

  case complete

  case incomplete(leaves: Set<SemanticSignature>)

  case partial(successors: Set<SemanticSignature>)

}

func step(
  states: Set<SemanticSignature>,
  implementations: [SemanticSignature]
) -> (successors: Set<SemanticSignature>, leaves: Set<SemanticSignature>)? {
  var successors: Set<SemanticSignature> = []
  var leaves: Set<SemanticSignature> = []

  // For all signature `s` in the state space and all implementations `i` that overlap with `s`,
  // add the complement signature `t = s - i` to the state space unless it is uninhabited.
  for s in states {
    var newSuccessors: Set<SemanticSignature> = []
    var isComplete = false

    // Loop over the implementations that overlap with `s`.
    for i in implementations where i.overlaps(with: s) {
      // Compute the complement signature `t`.
      let t = s - i

      // The given implementations satisfy `s` if `t` is unihnabited. Otherwise, `t` represent the
      // signatures left to satisfy.
      if !t.isInhabited {
        isComplete = true
        break
      } else {
        newSuccessors.insert(t)
      }
    }

    // If `s` is completely implemented, move to the next signature.
    if isComplete { continue }

    // If we didn't find any successor, `s` is unimplemented. Otherwise, the successors represent
    // the signatures to check next.
    if newSuccessors.isEmpty {
      // Note: we could stop the algorithm here rather than moving to the next signature if we
      // weren't interested in building the set of unimplemented signatures.
      leaves.insert(s)
    } else {
      successors.formUnion(newSuccessors)
    }
  }

  return (successors, leaves)
}

// -- Example

func main() {
  let x = SemanticType.tag(name: "X", arguments: [])
  let y = SemanticType.tag(name: "Y", arguments: [])
  let z = SemanticType.tag(name: "Z", arguments: [])

  // Define the interface.
  let interface = SemanticSignature(parameters: [[x, y, z], [x, y, z]])

  // Define the implementations.
  let implementations: [SemanticSignature] = [
    SemanticSignature(parameters: [[x], [x, y]]),
    SemanticSignature(parameters: [[x, y], [x]]),
    SemanticSignature(parameters: [[z], [z]]),
    SemanticSignature(parameters: [[y], [y]]),
    SemanticSignature(parameters: [[x, z], [y]]),
  ]

  // Run the algorithm.
  isSatisfied(interface, by: implementations)
}

main()
