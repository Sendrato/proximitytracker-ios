//
//  Theme.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 19-06-18.
//  Copyright © 2018 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit



public protocol Themeable: UIView {
    init(theme: Theme)
}

@objc
public protocol Theme {
    @objc var fontFamily: String { get }
    @objc var defaultFontSize: CGFloat { get }

    @objc var backgroundColor: UIColor { get }
    @objc var foregroundColor: UIColor { get }
    @objc var inactiveForegroundColor: UIColor { get }

    @objc var textInputColor: UIColor { get }
    @objc var tintColor: UIColor { get }
    @objc var barTintColor: UIColor { get }
    @objc var barStyle: UIBarStyle { get }
    @objc var statusBarStyle: UIStatusBarStyle { get }
    @objc var tableSeparatorColor: UIColor { get }

    @objc var placeHolderTextColor: UIColor { get }
    @objc var textFieldBackgroundColor: UIColor { get }
    @objc var privateTextColor: UIColor { get }
    @objc var privateColor: UIColor { get }

    @objc var positiveColor: UIColor { get }
    @objc var negativeColor: UIColor { get }
    @objc var neutralColor: UIColor { get }

    @objc var keyboardAppearance: UIKeyboardAppearance { get }

    @objc var primaryControlColor: UIColor { get set }
    @objc var primaryControlTextColor: UIColor { get set }
    @objc var secondaryControlColor: UIColor { get set }
    @objc var secondaryControlTextColor: UIColor { get set }

    var decorativeCornerRadius: CGFloat { get set }

    func defaultFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont

    var inverse: Theme { get }
}

public enum ThemeableSize {
    case small
    case regular
    case large
}

public extension UIColor {

    convenience init?(hex: String) {
        var hex = hex
        if hex.first == "#" {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 1) ..< hex.endIndex])
        }

        guard hex.count == 6 || hex.count == 8 else {
            return nil
        }

        let r = Int(String(hex[hex.index(hex.startIndex, offsetBy: 0) ..< hex.index(hex.startIndex, offsetBy: 2)]), radix: 16)
        let g = Int(String(hex[hex.index(hex.startIndex, offsetBy: 2) ..< hex.index(hex.startIndex, offsetBy: 4)]), radix: 16)
        let b = Int(String(hex[hex.index(hex.startIndex, offsetBy: 4) ..< hex.index(hex.startIndex, offsetBy: 6)]), radix: 16)
        let a: Int?
        if hex.count == 8 {
            a = Int(String(hex[hex.index(hex.startIndex, offsetBy: 6) ..< hex.index(hex.startIndex, offsetBy: 8)]), radix: 16)
        } else {
            a = 255
        }
        if let r = r,
            let g = g,
            let b = b,
            let a = a {
            self.init(red: CGFloat(r) / 256.0,
                      green: CGFloat(g) / 256.0,
                      blue: CGFloat(b) / 256.0,
                      alpha: CGFloat(a) / 256.0)
            return
        }
        return nil
    }

    func lighter(_ factor: CGFloat = 0.4) -> UIColor {
        let factor = 1 + factor
        var (r, g, b, a) = (CGFloat(1.0), CGFloat(1.0), CGFloat(1.0), CGFloat(1.0))

        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: r * factor, green: g * factor, blue: b * factor, alpha: a)
        }
        return self
    }

    func darker(_ factor: CGFloat = 0.2) -> UIColor {
        return lighter(-factor)
    }
}

@objc
open class DefaultTheme: NSObject, Theme {

    open var fontFamily: String
    public var defaultFontSize: CGFloat

    open var backgroundColor: UIColor
    open var foregroundColor: UIColor
    open var textInputColor: UIColor
    open var inactiveForegroundColor: UIColor

    public var tintColor: UIColor
    public var barTintColor: UIColor
    public var barStyle: UIBarStyle
    public var statusBarStyle: UIStatusBarStyle
    public var tableSeparatorColor: UIColor

    public var placeHolderTextColor: UIColor
    public var textFieldBackgroundColor: UIColor
    public var privateTextColor: UIColor
    public var privateColor: UIColor

    public var positiveColor: UIColor
    public var negativeColor: UIColor
    public var neutralColor: UIColor


    public var keyboardAppearance: UIKeyboardAppearance

    public var primaryControlTextColor: UIColor
    public var secondaryControlTextColor: UIColor
    public var primaryControlColor: UIColor
    public var secondaryControlColor: UIColor

    public var decorativeCornerRadius: CGFloat = 4.0

    public var inverse: Theme {
        return LightTheme()
    }

    public override init() {
        fontFamily = "Open Sans"
        defaultFontSize = 16

        backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        foregroundColor = UIColor(white: 0.8, alpha: 1.0)
        textInputColor = UIColor(white: 1.0, alpha: 1.0)
        inactiveForegroundColor = UIColor(white: 0.6, alpha: 1.0)

        textFieldBackgroundColor = UIColor(white:0.2, alpha: 0.8)
        placeHolderTextColor = UIColor(white: 0.6, alpha: 1.0)

        tintColor = UIColor(white: 0.95, alpha: 1.0)
        barTintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        barStyle = .black
        statusBarStyle = .lightContent
        tableSeparatorColor = UIColor(white: 0.6, alpha: 1.0)
        keyboardAppearance = .dark

        privateTextColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1.0)
        privateColor = UIColor(red: 0.9, green: 0, blue: 0, alpha: 1.0)


        negativeColor = UIColor(red: 0.768, green: 0.018, blue: 0.039, alpha: 1.0)
        positiveColor = UIColor(red: 0.345, green: 0.723, blue: 0.235, alpha: 1.0)
        neutralColor = UIColor(white: 0.4, alpha: 1.0)

        primaryControlColor = UIColor(red: 0.2, green: 0.2, blue: 0.6, alpha: 1.0)
        primaryControlTextColor = .white

        secondaryControlColor = .white
        secondaryControlTextColor = .white

        super.init()
    }

    @objc
    public func defaultFont(ofSize size: CGFloat, weight: UIFont.Weight = .regular ) -> UIFont {
        let traits: [UIFontDescriptor.TraitKey: Any] = [.weight: weight]
        return UIFont(descriptor: UIFontDescriptor(fontAttributes: [.family: self.fontFamily, .traits: traits]), size: size)
    }

}

@objc
public class LightTheme: DefaultTheme {

    override public var inverse: Theme {
        return DefaultTheme()
    }

    override init() {
        super.init()

        backgroundColor = UIColor(white: 0.86, alpha: 1.0)
        foregroundColor = UIColor(white: 0.2, alpha: 1.0)
        textInputColor = UIColor(white: 0.0, alpha: 1.0)
        textFieldBackgroundColor = UIColor(white:0.8, alpha: 0.8)
        placeHolderTextColor = UIColor(white: 0.4, alpha: 1.0)

        tintColor = UIColor(red: 0.1, green: 0.5, blue: 0.8, alpha: 1.0)
        barTintColor = UIColor(white: 1.0, alpha: 0.5)
        barStyle = .default
        statusBarStyle = .default
        tableSeparatorColor = UIColor(white: 0, alpha: 1.0)
        keyboardAppearance = .light


    }
}
