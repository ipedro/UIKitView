import XCTest
@testable import UIKitView
import SwiftUI
import SnapshotTesting

final class UIKitViewTests: XCTestCase {
    func testExample() throws {
        let vc1 = UIHostingController(
            rootView: UIKitView {
                UILabel()
            } then: {
                $0.text = "My text"
            })
        
        let vc2 = UIViewController()
        let label = UILabel()
        label.text = "My text"
        vc2.view = label
        label.backgroundColor = .systemBackground
        
        for vc in [vc1, vc2].shuffled() {
            assertSnapshot(matching: vc, as: .image(on: .iPhone13, perceptualPrecision: 0.97))
        }
    }
}
