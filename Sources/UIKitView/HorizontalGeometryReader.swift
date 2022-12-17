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

import SwiftUI

struct HorizontalGeometryReader<Content: View> : View {
    var content: (CGFloat) -> Content
    @State private var width: CGFloat = .zero

    init(@ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.content = content
    }

    var body: some View {
        content(width)
            // without explicitly setting frame, the view doesn't resize after rotation :shrug:
            .frame(minWidth: .zero)
            .background(
                GeometryReader { geometry in
                    Color
                        .clear
                        .preference(
                            key: WidthPreferenceKey.self,
                            value: geometry.size.width)
                }
            )
            .onPreferenceChange(WidthPreferenceKey.self) { newValue in
                self.width = newValue
            }
    }
}

private struct WidthPreferenceKey: PreferenceKey, Equatable {
    static var defaultValue: CGFloat = .zero

    // An empty reduce implementation takes the first value
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
