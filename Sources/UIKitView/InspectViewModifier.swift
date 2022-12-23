import SwiftUI

public extension View  {
    #if DEBUG
    /// Shows the view frame
    @ViewBuilder func inspectView(_ inspect: Bool = true,
                                  name: String? = nil,
                                  opacity: Double = 0.5) -> some View {
        if inspect {
            modifier(
                InspectViewModifier(
                    name: name ?? String(describing: type(of: self)),
                    opacity: opacity))
        } else {
            self
        }
    }
    #else
    /// Returns the view itself.
    func inspectView(_ inspect: Bool = true,
                     name: String? = nil,
                     opacity: Double = 1) -> Self {
        return self
    }
    #endif
}

struct InspectViewModifier: ViewModifier {
    var name: String?
    var opacity: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .overlay(
                GeometryReader { proxy in
                    VStack {
                        if let name = name {
                            Text(name)
                                .bold()
                                .font(.caption2)
                                .lineLimit(4)
                                .applyBackground()
                        }
                        
                        let frame = proxy.frame(in: .global)
                        
                        Text(String(
                            format: "X:%.1f Y:%.1f W:%.1f, H:%.1f",
                            frame.minX, frame.minY, frame.width, frame.height))
                        .applyBackground()
                        
                    }
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .font(.caption2.monospacedDigit())
                    .frame(
                        minWidth: .zero,
                        maxWidth: .infinity,
                        minHeight: .zero,
                        maxHeight: .infinity)
                    .border(.black, width: 1 / UIScreen.main.scale)
                }
            )
    }
    
}

private extension View {
    @ViewBuilder func applyBackground() -> some View {
        if #available(iOS 15.0, *) {
            self.background(Material.thick)
        } else {
            // Fallback on earlier versions
            self.background(Color.black.opacity(0.5))
        }
    }
}
