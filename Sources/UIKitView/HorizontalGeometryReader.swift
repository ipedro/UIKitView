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
