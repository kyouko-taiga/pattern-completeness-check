/// The semantic representation of a type.
enum SemanticType: Hashable {

  /// A type tag with its arguments, if any (e.g., `A<B, C>`).
  case tag(name: String, arguments: [SemanticType])

}

extension SemanticType: CustomStringConvertible {

  var description: String {
    switch self {
    case .tag(let name, let arguments):
      return arguments.isEmpty ? name : "\(name)<\(list: arguments)>"
    }
  }

}
