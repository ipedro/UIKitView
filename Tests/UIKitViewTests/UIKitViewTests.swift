import XCTest
@testable import UIKitView
import SwiftUI
import SnapshotTesting

final class UIKitViewTests: XCTestCase {
    func testExample() throws {
        let someView = UIKitView {
            UILabel()
        } then: {
            $0.text = "My text"
        }
        
        assertSnapshot(matching: UIHostingController(rootView: someView), as: .image(on: .iPhone13))
    }
}
