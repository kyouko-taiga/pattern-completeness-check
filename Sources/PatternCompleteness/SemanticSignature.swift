/// The semantic signature expressed by the declaration of an interface or implementation.
struct SemanticSignature: Hashable {

  /// The set of types at each corresponding parameter position.
  var parameters: [SemanticTypeSet]

  /// Indicates whether there exists a sequence of arguments that matches `self`.
  var isInhabited: Bool {
    parameters.contains(where: { (p) in !p.isEmpty })
  }

  /// Returns whether there exists a sequence of arguments that matches both `self` and `other`.
  func overlaps(with other: Self) -> Bool {
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
  static func - (lhs: Self, rhs: Self) -> SemanticSignature {
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

  var description: String {
    "(\(list: parameters))"
  }

}
