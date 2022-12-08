extension Collection {

  /// Returns the powerset of `self`.
  var powerset: [[Element]] {
    if isEmpty { return [[]] }

    return suffix(from: index(after: startIndex))
      .powerset
      .flatMap({ subset in [subset, [self[startIndex]] + subset] })
  }

}
