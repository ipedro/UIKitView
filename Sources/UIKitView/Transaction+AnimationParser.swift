import Foundation
import SwiftUI

// MARK: - Transaction Extension

extension Transaction {
    /// Perform the body with animation, matching animations in UIKit and SwiftUI.
    ///
    /// If the animation cannot be matched, no animation is performed and
    /// the closure returns false as the argument.
    func animateChanges(_ changes: @escaping (_ animated: Bool) -> Void) {
        guard let propertyAnimator = parsedAnimation?.propertyAnimator() else {
            return changes(false)
        }
        propertyAnimator.addAnimations {
            changes(true)
        }
        withAnimation(animation) {
            propertyAnimator.startAnimation()
        }
    }
    
    var parsedAnimation: ParsedAnimation? {
        guard !disablesAnimations, let animation = animation else { return nil }
        return AnimationParser(animation)?.parsedAnimation()
    }
    
}

// MARK: - ParsedAnimation

struct ParsedAnimation {
    private var animation: (any ParsableAnimation)?
    
    init(animation: (any ParsableAnimation)?) {
        self.animation = animation
    }
    func propertyAnimator() -> UIViewPropertyAnimator? {
        animation?.propertyAnimator(speedMultiplier: nil)
    }
}

// MARK: - AnimationParser

private struct AnimationParser {
    var mirror: Mirror
    
    init?(_ animation: Animation) {
        guard let base = Mirror(reflecting: animation).children.first else { return nil }
        let mirror = Mirror(reflecting: base.value)
        self.mirror = mirror
    }
    
    init(_ mirror: Mirror) {
        self.mirror = mirror
    }
    
    func parsedAnimation() -> ParsedAnimation {
        ParsedAnimation(animation: animation())
    }
    
    func animation() -> (any ParsableAnimation)? {
        let labels = mirror.children.map(\.label)
        switch labels {
        case ["duration", "curve"]:
            return BezierPathAnimation(mirror: mirror)
        case ["response", "dampingFraction", "blendDuration"]:
            return FluidSpringAnimation(mirror: mirror)
        case ["animation", "speed"]:
            return SpeedAnimation(mirror: mirror)
        case ["mass", "stiffness", "damping", "_initialVelocity"]:
            return SpringAnimation(duration: 0.5, mirror: mirror)
        default:
            return nil
        }
    }
}

// MARK: - PropertyAnimating Protocol

protocol ParsableAnimation {
    func propertyAnimator(speedMultiplier: CGFloat?) -> UIViewPropertyAnimator
}

// MARK: - SpringAnimation

/// Result of [interpolatingSpring(mass:stiffness:damping:initialVelocity:)](https://developer.apple.com/documentation/swiftui/animation/interpolatingspring(mass:stiffness:damping:initialvelocity:))
private struct SpringAnimation: ParsableAnimation {
    var duration: TimeInterval
    var mass: Double
    var stiffness: Double
    var damping: Double
    var initialVelocity: CGVector
    
    init?(duration: TimeInterval, mirror: Mirror) {
        var mass: Double?
        var stiffness: Double?
        var damping: Double?
        var initialVelocity: CGVector?
        
        for child in mirror.children {
            switch child.label {
            case "mass": mass = child.value as? Double
            case "stiffness": stiffness = child.value as? Double
            case "damping": damping = child.value as? Double
            case "_initialVelocity": initialVelocity = .zero // TODO: add support for parsing initial velocity
            default:
                break
            }
        }
        
        if let mass = mass, let stiffness = stiffness, let damping = damping, let initialVelocity = initialVelocity {
            self.duration = duration
            self.mass = mass
            self.stiffness = stiffness
            self.damping = damping
            self.initialVelocity = initialVelocity
        } else {
            return nil
        }
    }
    
    func propertyAnimator(speedMultiplier: CGFloat?) -> UIViewPropertyAnimator {
        .init(
            duration: duration * (speedMultiplier ?? 1),
            timingParameters: UISpringTimingParameters(
                mass: mass,
                stiffness: stiffness,
                damping: damping,
                initialVelocity: initialVelocity))
    }
}

// MARK: - BezierPathAnimation

/// Result of bezier animations like [.easeIn](https://developer.apple.com/documentation/swiftui/animation/easein), [.easeOut](https://developer.apple.com/documentation/swiftui/animation/easeout), [.linear](https://developer.apple.com/documentation/swiftui/animation/linear), etc.
private struct BezierPathAnimation: ParsableAnimation {
    /// The duration of the animation, in seconds.
    var duration: TimeInterval
    /// Quadradic bezier is how SwiftUI.Animation represents itself internally.
    var quadratic: QuadraticBezier
    /// Cubic bezier is how we convert to CoreGraphics, UIKit, and AppKit animations.
    var cubic: CubicBezier
    
    init?(mirror: Mirror) {
        var duration: TimeInterval?
        var quadratic: QuadraticBezier?
        
        for child in mirror.children {
            switch child.label {
            case "duration": duration = child.value as? Double
            case "curve": quadratic = QuadraticBezier(mirror: Mirror(reflecting: child.value))
            default:
                break
            }
        }
        if let duration = duration, let quadratic = quadratic {
            self.duration = duration
            self.quadratic = quadratic
            self.cubic = quadratic.convertToCubic()
        } else {
            return nil
        }
    }
    
    func propertyAnimator(speedMultiplier: CGFloat?) -> UIViewPropertyAnimator {
        .init(
            duration: duration * (speedMultiplier ?? 1),
            controlPoint1: cubic.point1,
            controlPoint2: cubic.point2)
    }
    
    /// Cubic bezier: how we convert to CoreGraphics, UIKit, and AppKit animations.
    struct CubicBezier: Equatable {
        var point1: CGPoint
        var point2: CGPoint
    }
    
    /// Quadradic bezier; how Animation represents itself internally.
    struct QuadraticBezier {
        var ax: Double
        var ay: Double
        var bx: Double
        var by: Double
        var cx: Double
        var cy: Double
        
        init?(mirror: Mirror) {
            var ax, ay, bx, by, cx, cy: Double?
            for child in mirror.children {
                switch child.label {
                case "ax": ax = child.value as? Double
                case "ay": ay = child.value as? Double
                case "bx": bx = child.value as? Double
                case "by": by = child.value as? Double
                case "cx": cx = child.value as? Double
                case "cy": cy = child.value as? Double
                default:
                    break
                }
            }
            if let ax = ax, let ay = ay, let bx = bx, let by = by, let cx = cx, let cy = cy {
                self.ax = ax
                self.ay = ay
                self.bx = bx
                self.by = by
                self.cx = cx
                self.cy = cy
            } else {
                return nil
            }
        }
        
        func convertToCubic() -> CubicBezier {
            let point1 = CGPoint(
                x: ((2 * cx) - ax) / 3,
                y: ((2 * cy) - ay) / 3
            )
            let point2 = CGPoint(
                x: ((2 * cx) + bx) / 3,
                y: ((2 * cy) + by) / 3
            )
            return CubicBezier(point1: point1, point2: point2)
        }
    }

}

// MARK: - FluidSpringAnimation

/// Result of [spring(response:dampingFraction:blendDuration:)](https://developer.apple.com/documentation/swiftui/animation/spring(response:dampingfraction:blendduration:)) and [interactiveSpring(response:dampingFraction:blendDuration:)](https://developer.apple.com/documentation/swiftui/animation/interactivespring(response:dampingfraction:blendduration:)).
private struct FluidSpringAnimation: ParsableAnimation {
    var duration: Double
    var dampingFraction: Double
    
    init?(mirror: Mirror) {
        var response: Double?
        var dampingFraction: Double?
        
        for child in mirror.children {
            switch child.label {
            case "response": response = child.value as? Double
            case "dampingFraction": dampingFraction = child.value as? Double
            default:
                break
            }
        }
        
        if let response = response, let dampingFraction = dampingFraction {
            self.duration = response
            self.dampingFraction = dampingFraction
        } else {
            return nil
        }
    }
    
    func propertyAnimator(speedMultiplier: CGFloat?) -> UIViewPropertyAnimator {
        .init(duration: duration * (speedMultiplier ?? 1), dampingRatio: dampingFraction)
    }
}

// MARK: - Speed Modififer

/// An animation wrapped with the [speed(_:)](https://developer.apple.com/documentation/swiftui/animation/speed(_:)) modififer.
private struct SpeedAnimation: ParsableAnimation {
    var speed: Double
    var base: any ParsableAnimation
    
    init?(mirror: Mirror) {
        var speed: Double?
        var animation: ParsableAnimation?
        
        for child in mirror.children {
            switch child.label {
            case "speed": speed = child.value as? Double
            case "animation": animation = AnimationParser(Mirror(reflecting: child.value)).animation()
            default:
                break
            }
        }
        
        if let speed = speed, let animation = animation {
            self.speed = speed
            self.base = animation
        } else {
            return nil
        }
    }
    
    func propertyAnimator(speedMultiplier: CGFloat?) -> UIViewPropertyAnimator {
        base.propertyAnimator(speedMultiplier: speedMultiplier ?? speed)
    }
}

// MARK: - Previews

struct AnimationParser_Previews: PreviewProvider {
    static var previews: some View {
        AnimationParsingDemo()
    }
}

struct AnimationParsingDemo: View {
    @State var count = 1
    @State var showFrames = true
    
    var body: some View {
        ScrollView {
            VStack {
                comparison(group: "spring()")
                    .background(Color.red)
                    .animation(.spring(), value: count)
                
                comparison(group: "interactiveSpring()")
                    .background(Color.purple)
                    .animation(.interactiveSpring(), value: count)
                
                comparison(group: "linear")
                    .background(Color.blue)
                    .animation(.linear, value: count)
                
                comparison(group: "interpolatingSpring()")
                    .background(Color.gray)
                    .animation(.interpolatingSpring(stiffness: 0.5, damping: 0.825), value: count)
                
                comparison(group: "default")
                    .background(Color.green)
                    .animation(.default, value: count)
                
                comparison(group: "default.speed(0.2)")
                    .background(Color.pink)
                    .animation(.default.speed(0.2), value: count)
                
                Spacer(minLength: 40)
                
                HStack(spacing: 24) {
                    Button {
                        count += 1
                    } label: {
                        Text("Animate")
                    }
                    
                    Button {
                        showFrames.toggle()
                    } label: {
                        Text(showFrames ? "Hide frames" : "Show frames")
                    }
                }
                .padding()
            }
            .padding()
        }
    }
    
    @ViewBuilder private func comparison(group title: String) -> some View {
        applyStyle {
            UIKitView {
                UILabel()
            } onChange: {
                $0.text = title
            }
        }
        .inspectView(showFrames, name: "UILabel")
        
        applyStyle {
            Text(title)
        }
        .inspectView(showFrames, name: "SwiftUI.Text")
        
        Divider()
            .background(Color.gray)
    }
    
    func applyStyle<V: View>(view: () -> V) -> some View {
        view()
            .fixedSize()
            .padding(4)
            .frame(width: count % 2 == 0 ? 350 : nil)
    }
}
