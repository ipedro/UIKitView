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

/// Responsible for managing a UIKit view lifecycle and interfacing with SwiftUI.
public final class _UIKitViewCoordinator<UIViewType: UIView> {
    typealias LayoutContainer = _UIKitViewLayoutContainer<UIViewType>

    private(set) var layoutContainer: LayoutContainer?
    private let content: UIKitView<UIViewType>.Content
    let onStart: UIKitView<UIViewType>.Callback?
    let onFinish: UIKitView<UIViewType>.Callback?

    init(content: @escaping UIKitView<UIViewType>.Content,
         onStart: UIKitView<UIViewType>.Callback?,
         onFinish: UIKitView<UIViewType>.Callback?) {
        self.content = content
        self.onStart = onStart
        self.onFinish = onFinish
    }

    func makeUIView() -> LayoutContainer {
        guard let cached = layoutContainer else {
            let view = LayoutContainer(content())
            onStart?(view.content)
            layoutContainer = view
            return view
        }
        return cached
    }
    
    func finish() {
        guard let content = layoutContainer?.content else { return }
        onFinish?(content)
        layoutContainer = nil
    }
}
