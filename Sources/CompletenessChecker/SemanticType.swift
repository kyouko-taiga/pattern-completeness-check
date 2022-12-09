/// The semantic representation of a type.
public enum SemanticType: Hashable {

  /// A type tag with its arguments, if any (e.g., `A<B, C>`).
  case tag(name: String, arguments: [SemanticType])


}

extension SemanticType: ExpressibleByStringLiteral {

  public init(stringLiteral expression: String) {
    self = .tag(name: expression, arguments: [])
  }

}

extension SemanticType: CustomStringConvertible {

  public var description: String {
    switch self {
    case .tag(let name, let arguments):
      return arguments.isEmpty ? name : "\(name)<\(list: arguments)>"

    }
  }

}
