/// The semantic signature expressed by the declaration of an interface or implementation.
public struct SemanticSignature: Hashable {

  /// The set of types at each corresponding parameter position.
  public var parameters: [SemanticTypeSet]

  /// Creates an instance with the given properties.
  public init(parameters: [SemanticTypeSet]) {
    self.parameters = parameters
  }

  /// Indicates whether there exists a sequence of arguments that matches `self`.
  public var isInhabited: Bool {
    parameters.contains(where: { (p) in !p.isEmpty })
  }

  /// Returns a collection with the interfaces of the implementations that handle the sequences
  /// arguments that match `self` but are not handled by any of the given interfaces.
  public func isSatisfied(by implementations: [SemanticSignature]) -> Set<SemanticSignature> {
    var states: Set<SemanticSignature> = [self]
    var leaves: Set<SemanticSignature> = []

    while !states.isEmpty {
      if let (successors, newLeaves) = step(states: states, implementations: implementations) {
        states = successors
        leaves.formUnion(newLeaves)
      } else {
        break
      }
    }

    return leaves
  }

  /// Executes one step of the completion algorithm.
  private func step(
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

  /// Returns whether there exists a sequence of arguments that matches both `self` and `other`.
  public func overlaps(with other: Self) -> Bool {
    if parameters.count != other.parameters.count { return false }
    for i in 0 ..< parameters.count {
      if !parameters[i].intersects(with: other.parameters[i]) { return false }
    }
    return true
  }

  /// Returns a semantic signature matching all the sequences of arguments that are accepted by
  /// `lhs` and are not accepted by `rhs`.
  ///
  /// - Requires: `lhs` must overlap with `rhs`.
  public static func - (lhs: Self, rhs: Self) -> SemanticSignature {
    assert(lhs.overlaps(with: rhs))

    // Compute set of types only accepted by `lhs` at each parameter position.
    var result = SemanticSignature(
      parameters: zip(lhs.parameters, rhs.parameters).map({ (l, r) in l.subtracting(r) }))

    // If the resulting signature is inhabited, substitute empty sets by their original value in
    // `lhs`. Those correspond to the fully matched position.
    if result.isInhabited {
      for i in 0 ..< lhs.parameters.count where result.parameters[i].isEmpty {
        result.parameters[i] = lhs.parameters[i]
      }
    }

    return result
  }

}

extension SemanticSignature: CustomStringConvertible {

  public var description: String {
    "(\(list: parameters))"
  }

}
