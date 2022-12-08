/// A set of semantic types.
public struct SemanticTypeSet: Hashable {

  /// The elements in `self`.
  private var elements: Set<SemanticType>

  /// Creates an empty set.
  public init() {
    self.elements = []
  }

  /// Creates a copy of `other`.
  public init(_ other: Self) {
    self.elements = other.elements
  }

  /// Creates a set from a finite sequence of types.
  public init<S: Sequence>(_ elements: S) where S.Element == SemanticType {
    self.elements = []
    self.elements.reserveCapacity(elements.underestimatedCount)
    for e in elements { insert(e) }
  }

  /// Indicates whether `self` is empty.
  public var isEmpty: Bool { elements.isEmpty }

  /// Returns whether `self` contains `element`.
  public func contains(_ element: SemanticType) -> Bool {
    elements.contains(element)
  }

  /// Returns whether there exist elements that are common to both `self` and `other`.
  public func intersects(with other: Self) -> Bool {
    other.contains(where: contains(_:))
  }

  /// Returns a new set containing the elements of this set that do not occur in the given set.
  public func subtracting(_ other: Self) -> Self {
    var result = self
    result.elements.subtract(other.elements)
    return result
  }

  /// Inserts `newElement` in `self`.
  public mutating func insert(_ newElement: SemanticType) {
    if case .union(let types) = newElement {
      for e in types { insert(e) }
    } else {
      elements.insert(newElement)
    }
  }

}

extension SemanticTypeSet: Collection {

  public typealias Element = SemanticType

  public typealias Index = Set<SemanticType>.Index

  public var startIndex: Index { elements.startIndex }

  public var endIndex: Index { elements.endIndex }

  public func index(after i: Index) -> Index {
    elements.index(after: i)
  }

  public subscript(position: Index) -> SemanticType {
    elements[position]
  }

}

extension SemanticTypeSet: ExpressibleByArrayLiteral {

  public init(arrayLiteral elements: SemanticType...) {
    self.init(elements)
  }

}

extension SemanticTypeSet: CustomStringConvertible {

  public var description: String { String(describing: elements) }

}

extension SemanticTypeSet: CustomReflectable {

  public var customMirror: Mirror {
    Mirror(reflecting: elements)
  }

}
