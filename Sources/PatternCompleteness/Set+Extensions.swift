extension Set {

  /// Returns whether there exist elements that are common to both `self` and `other`.
  func intersects<S: Sequence>(with other: S) -> Bool where S.Element == Element {
    other.contains(where: contains(_:))
  }

}
