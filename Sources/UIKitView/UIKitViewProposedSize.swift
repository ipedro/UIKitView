import Foundation

/// Defines the sizing strategy of a view object.
public struct UIKitViewProposedSize {
    var isHorizontalSizeFixed: Bool = false
    var isVerticalSizeFixed: Bool = false
    
    /// Adapts the view to fit the available space.
    ///
    /// This is the default system behavior.
    public static func flexible() -> Self { .init() }
    
    /// Fixes the view at its ideal size in the specified dimensions.
    ///
    /// The fixing of the axes can be optionally specified in one or both dimensions. For example, if you horizontally fix a text view before wrapping it in the frame view, you’re telling the text view to maintain its ideal width. The view calculates this to be the space needed to represent the entire string.
    ///
    /// This can result in the view exceeding the parent’s bounds, which may or may not be the effect you want.
    public static func fixedSize(horizontal: Bool = true,
                                 vertical: Bool = true) -> Self {
        .init(
            isHorizontalSizeFixed: horizontal,
            isVerticalSizeFixed: vertical)
    }
}
