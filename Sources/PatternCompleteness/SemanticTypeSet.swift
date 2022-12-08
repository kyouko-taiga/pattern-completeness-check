/// A set of semantic types.
struct SemanticTypeSet: Hashable {

  /// The elements in `self`.
  private var elements: Set<SemanticType>

  /// Creates an empty set.
  init() {
    self.elements = []
  }

  /// Creates a copy of `other`.
  init(_ other: Self) {
    self.elements = other.elements
  }

  /// Creates a set from a finite sequence of types.
  init<S: Sequence>(_ elements: S) where S.Element == SemanticType {
    self.elements = []
    self.elements.reserveCapacity(elements.underestimatedCount)
    for e in elements { insert(e) }
  }

  /// Indicates whether `self` is empty.
  var isEmpty: Bool { elements.isEmpty }

  /// Returns whether `self` contains `element`.
  func contains(_ element: SemanticType) -> Bool {
    elements.contains(element)
  }

  /// Returns whether there exist elements that are common to both `self` and `other`.
  func intersects(with other: Self) -> Bool {
    other.contains(where: contains(_:))
  }

  /// Returns a new set containing the elements of this set that do not occur in the given set.
  func subtracting(_ other: Self) -> Self {
    var result = self
    result.elements.subtract(other.elements)
    return result
  }

  /// Inserts `newElement` in `self`.
  mutating func insert(_ newElement: SemanticType) {
    if case .union(let types) = newElement {
      for e in types { insert(e) }
    } else {
      elements.insert(newElement)
    }
  }

}

extension SemanticTypeSet: Collection {

  typealias Element = SemanticType

  typealias Index = Set<SemanticType>.Index

  var startIndex: Index { elements.startIndex }

  var endIndex: Index { elements.endIndex }

  func index(after i: Index) -> Index {
    elements.index(after: i)
  }

  subscript(position: Index) -> SemanticType {
    elements[position]
  }

}

extension SemanticTypeSet: ExpressibleByArrayLiteral {

  init(arrayLiteral elements: SemanticType...) {
    self.init(elements)
  }

}

extension SemanticTypeSet: CustomStringConvertible {

  var description: String { String(describing: elements) }

}
