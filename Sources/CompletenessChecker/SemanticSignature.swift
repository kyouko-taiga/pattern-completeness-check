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
  ///
  /// - Requires: All implementations must have the same number of parameters as `self`.
  public func isSatisfied(by implementations: [SemanticSignature]) -> Set<SemanticSignature> {
    precondition(implementations.allSatisfy({ (i) in i.parameters.count == parameters.count }))

    /// The set of signatures that have to be satisfied.
    var interfaces: Set<SemanticSignature> = [self]
    /// The set of signatures that are not satisfied.
    var leaves: Set<SemanticSignature> = []

    while !interfaces.isEmpty {
      if let (s, l) = step(interfaces: interfaces, implementations: implementations) {
        // Note: A step should only produce strictly smaller successors.
        assert(s.isDisjoint(with: interfaces))
        interfaces = s
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

      // Loop over the implementations.
      for i in implementations {
        // Check if `i` trivially satisfies `s`.
        if s == i {
          isComplete = true
          break
        }

        // Skip `i` if its intersection with `s` is uninhabited.
        let si = s.intersection(i)
        if !si.isInhabited { continue }

        // Compute the strict complement of `s` under `i`.
        let strictComplement = s.subtracting(i)

        // Filter the indices of the inhabited parameters.
        let indices = strictComplement.parameters.indices.filter({ (k) in
          !strictComplement.parameters[k].isEmpty
        })

        // Compute the complement set of `s` under `i`, that is the set of signatures covered by
        // `s` and not `i`.
        var completementSet: [SemanticSignature] = []
        for variant in indices.powerset where !variant.isEmpty {
          var t = si
          for k in variant {
            t.parameters[k] = strictComplement.parameters[k]
          }

          // Only add new inhabited signatures to the complement set.
          assert(t.isInhabited)
          if !interfaces.contains(t) { completementSet.append(t) }
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

  /// Returns the signature matching the sequence of arguments matched by both `self` and `other`.
  ///
  /// - Requires: `other` must the same number of parameters as `self`.
  public func intersection(_ other: Self) -> Self {
    var result = self
    for i in 0 ..< result.parameters.count {
      result.parameters[i].formIntersection(other.parameters[i])
    }
    return result
  }

  /// Returns the signature matching the sequences of arguments that matched by `self` and fully
  /// rejected by `other`.
  ///
  /// - Requires: `other` must the same number of parameters as `self`.
  public func subtracting(_ other: Self) -> Self {
    var result = self
    for i in 0 ..< result.parameters.count {
      result.parameters[i].subtract(other.parameters[i])
    }
    return result
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
