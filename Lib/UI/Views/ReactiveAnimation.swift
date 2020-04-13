//
//  ReactiveAnimation.swift
//  Vidacle
//
//  Created by Jacco Taal on 12/02/2020.
//  Copyright © 2020 Vidacle B.V. All rights reserved.

import Foundation


#if os(OSX)
import AppKit

public typealias AnimationCurveRawValue = Int
#elseif os(iOS)
import UIKit

public typealias AnimationCurveRawValue = UIView.AnimationCurve.RawValue
#endif

import ReactiveSwift
import ReactiveCocoa

/// Creates an animated SignalProducer for each value that arrives on
/// `producer`.
///
/// The `JoinStrategy` used on the inner producers will hint to
/// ReactiveAnimation whether the animations should be interruptible:
///
///  - `Concat` will result in new animations only beginning after all previous
///    animations have completed.
///  - `Merge` or `Latest` will start new animations as soon as possible, and
///    use the current (in progress) UI state for animating.
///
/// These animation behaviors are only a hint, and the framework may not be able
/// to satisfy them.
///
/// However the inner producers are joined, binding the resulting stream of
/// values to a view property will result in those value changes being
/// automatically animated.
///
/// To delay an animation, use delay() or throttle() _before_ this function.
/// Because the aforementioned operators delay delivery of `Next` events,
/// applying them _after_ this function may cause values to be delivered outside
/// of any animation block.
///
/// Examples
///
/// RAN(self.textField).alpha <~ alphaValues
///                              |> animateEach(duration: 0.2)
///                                 /* Animate alpha without interruption. */
///                              |> join(.Concat)
///
///    RAN(self.button).alpha <~ alphaValues
///                           /* Delay animations by 0.1 seconds. */
///                           |> delay(0.1)
///                           |> animateEach(curve: .Linear)
///                           /* Animate alpha, and interrupt for new animations. */
///                           |> join(.Latest)
///
/// Returns a producer of producers, where each inner producer sends one `next`
/// that corresponds to a value from the receiver, then completes when the
/// animation corresponding to that value has finished. Deferring the events of
/// the returned producer or having them delivered on another thread is considered
/// undefined behavior.


extension Signal {
    /// wraps the returned signal into a UIView animation
    public func animateEach(duration: TimeInterval? = nil, curve: AnimationCurve = .default) -> Signal<SignalProducer<Value, Never>, Error> {
        return self.map { value in
            return SignalProducer { observer, lifetime in
                OSAtomicIncrement32(&runningInAnimationCount)
                lifetime.observeEnded {
                    OSAtomicDecrement32(&runningInAnimationCount)
                }

                #if os(OSX)
                NSAnimationContext.runAnimationGroup({ context in
                    if let duration = duration {
                        context.duration = duration
                    }

                    if curve != .Default {
                        context.timingFunction = CAMediaTimingFunction(name: curve.mediaTimingFunction)
                    }

                    observer.send(value: value) // TODO: Why is the downcast necessary?
                }, completionHandler: {
                    // Avoids weird AppKit deadlocks when interrupting an
                    // existing animation.
                    UIScheduler().schedule {
                        observer.sendCompleted()
                    }
                })
                #elseif os(iOS)
                var options: UIView.AnimationOptions = [
                    UIView.AnimationOptions(rawValue: UInt(curve.rawValue)),
                    .layoutSubviews,
                    .beginFromCurrentState]

                if curve != .default {
                    options.formUnion(.overrideInheritedCurve)
                }

                UIView.animate(withDuration: duration ?? 0.2, delay: 0, options: options, animations: {
                    observer.send(value: value) // TODO: Why is the downcast necessary?
                }, completion: { finished in
                    if(finished) {
                        observer.sendCompleted()
                    } else {
                        observer.sendInterrupted()
                    }
                })
                #endif
            }
        }
    }
}


extension SignalProducer {
    /// wraps the returned signal producer into a UIView animation
    public func animateEach(duration: TimeInterval? = nil, curve: AnimationCurve = .default) -> SignalProducer<SignalProducer<Value, Never>, Error> {
        return self.lift { $0.animateEach(duration: duration, curve: curve) }
    }
}


/// The number of animated signals in the call stack.
///
/// This variable should be manipulated with OSAtomic functions.
private var runningInAnimationCount: Int32 = 0

/// Determines whether the calling code is running from within an animation
/// definition.
///
/// This can be used to conditionalize behavior based on whether a signal
/// somewhere in the chain is supposed to be animated.
///
/// This property is thread-safe.
public var runningInAnimation: Bool {
    return runningInAnimationCount > 0
}

/// Describes the curve (timing function) for an animation.
public enum AnimationCurve: AnimationCurveRawValue, Equatable {
    /// The default or inherited animation curve.
    case `default` = 0

    /// Begins the animation slowly, speeds up in the middle, then slows to
    /// a stop.
    case easeInOut
    case easeIn
    case easeOut
    case linear
    //  #if os(iOS)
    //    case EaseInOut = UIViewAnimationCurve.EaseInOut.rawValue
    //  #else
    //    case EaseInOut
    //  #endif
    //
    //  /// Begins the animation slowly and speeds up to a stop.
    //  case EaseIn
    //    #if os(iOS)
    //      = UIViewAnimationCurve.EaseIn
    //    #endif
    //
    //  /// Begins the animation quickly and slows down to a stop.
    //  case EaseOut
    //    #if os(iOS)
    //      = UIViewAnimationCurve.EaseOut
    //    #endif
    //
    //  /// Animates with the same pace over the duration of the animation.
    //  case Linear
    //    #if os(iOS)
    //      = UIViewAnimationCurve.Linear
    //    #endif

    /// The name of the CAMediaTimingFunction corresponding to this curve.
    public var mediaTimingFunction: CAMediaTimingFunctionName {

        switch self {
        case .default:
            return CAMediaTimingFunctionName.default

        case .easeInOut:
            return CAMediaTimingFunctionName.easeInEaseOut

        case .easeIn:
            return CAMediaTimingFunctionName.easeIn

        case .easeOut:
            return CAMediaTimingFunctionName.easeOut

        case .linear:
            return CAMediaTimingFunctionName.linear
        }
    }
}

public func == (lhs: AnimationCurve, rhs: AnimationCurve) -> Bool {
    switch (lhs, rhs) {
    case (.default, .default), (.easeInOut, .easeInOut), (.easeIn, .easeIn), (.easeOut, .easeOut), (.linear, .linear):
        return true

    default:
        return false
    }
}

extension AnimationCurve: CustomStringConvertible {
    public var description: String {
        switch self {
        case .default:
            return "Default"

        case .easeInOut:
            return "EaseInOut"

        case .easeIn:
            return "EaseIn"

        case .easeOut:
            return "EaseOut"

        case .linear:
            return "Linear"
        }
    }
}
