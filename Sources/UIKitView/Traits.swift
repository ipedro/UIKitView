// MIT License
//
// Copyright (c) 2022 Pedro Almeida
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

extension UIKitView {
    /// Defines the sizing strategy of a view object.
    public struct Traits: Equatable {
        var layoutPriority: UILayoutPriority
        var isHorizontalSizeFixed: Bool = false
        var isVerticalSizeFixed: Bool = false
        
        /// Adapts the view to fit the available space.
        ///
        /// This is the default system behavior.
        public static func flexible(priority: UILayoutPriority = .init(950)) -> Self { .init(layoutPriority: priority) }
        
        /// Fixes the view at its ideal size in the specified dimensions.
        ///
        /// The fixing of the axes can be optionally specified in one or both dimensions. For example, if you horizontally fix a text view before wrapping it in the frame view, you’re telling the text view to maintain its ideal width. The view calculates this to be the space needed to represent the entire string.
        ///
        /// This can result in the view exceeding the parent’s bounds, which may or may not be the effect you want.
        public static func fixedSize(horizontal: Bool = true,
                                     vertical: Bool = true) -> Self {
            .init(
                layoutPriority: .fittingSizeLevel,
                isHorizontalSizeFixed: horizontal,
                isVerticalSizeFixed: vertical)
        }
    }
}
