/// The semantic representation of a type.
public enum SemanticType: Hashable {

  /// A type tag with its arguments, if any (e.g., `A<B, C>`).
  case tag(name: String, arguments: [SemanticType])

  /// A union of semantic types (e.g., `A | B<C>`).
  case union([SemanticType])

}

extension SemanticType: ExpressibleByStringLiteral {

  public init(stringLiteral expression: String) {
    self.init(expression)!
  }

}

extension SemanticType: LosslessStringConvertible {

  public init?(_ expression: String) {
    // TODO: Parse the expression.
    self = .tag(name: expression, arguments: [])
  }

  public var description: String {
    switch self {
    case .tag(let name, let arguments):
      return arguments.isEmpty ? name : "\(name)<\(list: arguments)>"

    case .union(let types):
      return types.isEmpty ? "⊥" : "\(list: types)"
    }
  }

}
