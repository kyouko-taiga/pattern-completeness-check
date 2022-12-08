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
    parameters.allSatisfy({ (p) in !p.isEmpty })
  }

  /// Indicates whether there exists a sequence of arguments that partially matches `self`.
  public var isPartiallyInhabited: Bool {
    parameters.contains(where: { (p) in !p.isEmpty })
  }

  /// Returns a collection with the interfaces of the implementations that handle the sequences
  /// arguments that match `self` but are not handled by any of the given interfaces.
  public func isSatisfied(by implementations: [SemanticSignature]) -> Set<SemanticSignature> {
    var states: Set<SemanticSignature> = [self]
    var leaves: Set<SemanticSignature> = []

    var successors = states
    while !successors.isEmpty {
      if let (s, l) = step(interfaces: successors, implementations: implementations) {
        successors = s.subtracting(states)
        states.formUnion(s)
        leaves.formUnion(l)
      } else {
        break
      }
    }

    return leaves
  }

  /// Executes one step of the completion algorithm.
  private func step(
    interfaces: Set<SemanticSignature>,
    implementations: [SemanticSignature]
  ) -> (successors: Set<SemanticSignature>, leaves: Set<SemanticSignature>)? {
    var successors: Set<SemanticSignature> = []
    var leaves: Set<SemanticSignature> = []

    // For all interface signatures `s` and all implementations `i` that overlap with `s`, compute
    // the complement signature set of `s` under `i`.
    for s in interfaces {
      var newSuccessors: Set<SemanticSignature> = []
      var isComplete = false

      // Loop over the implementations that overlap with `s`.
      for i in implementations where i.overlaps(with: s) {
        // Compute the strict complement of `s` under `i`.
        let strictComplement = s - i

        // If all the parameters of the strict complement are uninhabited, conclude that the given
        // implementations satisfy `t` as the complement set of `s` under `i` is empty.
        if !strictComplement.isPartiallyInhabited {
          isComplete = true
          break
        }

        // Compute the complement set of `s` under `i`, containing the strict complement as well as
        // the signatures of all possible partial matches of `i`, excluding uninhabited elements.
        var completementSet: [SemanticSignature] = []
        for indices in (0 ..< i.parameters.count).powerset.dropLast() {
          var t = strictComplement
          for k in indices {
            t.parameters[k] = s.parameters[k].intersection(i.parameters[k])
          }

          // Only add inhabited signatures to the complement set.
          if t.isInhabited { completementSet.append(t) }
        }

        // If the complement set is empty, conclude that the given implementations satisfy `t`.
        // Otherwise, add its contents to the set of successors.
        if completementSet.isEmpty {
          isComplete = true
          break
        } else {
          newSuccessors.formUnion(completementSet)
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

  /// Returns the signature matching the sequences of arguments that are fully rejected by `self`.
  ///
  /// - Requires: `lhs` must overlap with `rhs`.
  public static func - (lhs: Self, rhs: Self) -> SemanticSignature {
    assert(lhs.overlaps(with: rhs))
    return SemanticSignature(
      parameters: zip(lhs.parameters, rhs.parameters).map({ (l, r) in l.subtracting(r) }))
  }

}

extension SemanticSignature: CustomStringConvertible {

  public var description: String {
    "(\(list: parameters))"
  }

}

extension SemanticSignature: CustomReflectable {

  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: parameters)
  }

}
