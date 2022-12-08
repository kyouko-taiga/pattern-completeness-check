import XCTest
import CompletenessChecker

final class CompletenessCheckerTests: XCTestCase {

  func testTriviallyComplete() {
    let interface = SemanticSignature(parameters: [["A"], ["B"]])
    let leaves = interface.isSatisfied(by: [interface])

    // An interface should be satisfied by an implementation with the same signature.
    XCTAssert(leaves.isEmpty)
  }

  func testEnumeration() {
    let interface = SemanticSignature(parameters: [["A", "B"], ["A", "B"]])
    let leaves = interface.isSatisfied(by: [
      .init(parameters: [["A"], ["A"]]),
      .init(parameters: [["A"], ["B"]]),
      .init(parameters: [["B"], ["A"]]),
      .init(parameters: [["B"], ["B"]]),
    ])
    XCTAssert(leaves.isEmpty)
  }

  func testPartialMatch() {
    let interface = SemanticSignature(parameters: [["A", "B"], ["A", "B"]])
    let leaves = interface.isSatisfied(by: [
      .init(parameters: [["A", "B"], ["A"]]),
      .init(parameters: [["A", "B"], ["B"]]),
    ])
    XCTAssert(leaves.isEmpty)
  }

  func testTriviallyIncomplete() {
    let interface = SemanticSignature(parameters: [["A", "B"], ["A", "B"]])
    let leaves = interface.isSatisfied(by: [
      .init(parameters: [["A"], ["A"]]),
      .init(parameters: [["A"], ["B"]]),
      .init(parameters: [["B"], ["A"]]),
    ])
    XCTAssert(leaves.contains(.init(parameters: [["B"], ["B"]])))
  }

  func testParameterDependencyTracking() {
    let interface = SemanticSignature(parameters: [["A", "B", "C"], ["A", "B", "C"]])
    let leaves = interface.isSatisfied(by: [
      .init(parameters: [["A"], ["A", "B"]]),
      .init(parameters: [["A", "B"], ["A"]]),
      .init(parameters: [["C"], ["C"]]),
    ])
    XCTAssertFalse(leaves.isEmpty)
  }

}
