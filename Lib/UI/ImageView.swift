//
//  ImageView.swift
//  LifeshareSDK
//
//  Created by Jacco Taal on 18/02/2020.
//

import Foundation
import ReactiveSwift

public extension UIImageView {
    static var providerKey = "provider"

    var provider: ImageProvider? {
        get {
            return objc_getAssociatedObject(self, &Self.providerKey) as? ImageProvider
        }
        set {
           set(provider: newValue, condition: { true })
        }
    }

    func set(provider: ImageProvider?, condition: (() -> Bool)) {
        objc_setAssociatedObject(self, &Self.providerKey, provider, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.contentMode = .scaleAspectFill
        self.image = nil
        if frame.size.width > 0 && frame.size.height > 0,
            let provider = provider {
            load(provider, condition: { true })
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

         if let provider = provider {
            load(provider, condition: { true })
        }
    }

    func load(_ provider: ImageProvider, condition: @escaping (() -> Bool)) {

        provider.image(with: (width: Int(self.frame.size.width), height: Int(self.frame.size.height)))
            .start({ event in
                switch event {
                case .value(let image):
                    if condition(),
                        let image = image {
                        self.image = image
                        self.backgroundColor = .white
                    }
                    objc_setAssociatedObject(self, &Self.providerKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                default:
                    ()
                }
            })
    }
}

public class BlurredImageView: UIImageView {

    var blurRadius: CGFloat = 4

    let blur: CALayer

    public init() {
        blur = CALayer()
        if let blurFilter = CIFilter(name: "CIGaussianBlur",
                                 parameters: [kCIInputRadiusKey: 4]) {
            blur.backgroundFilters = [blurFilter]
        }

        super.init(image: nil)

        layer.addSublayer(blur)
    }

    /// Apply Gaussian Blur to a ciimage, and return a UIImage
    ///
    /// - Parameter ciimage: the imput CIImage
    /// - Returns: output UIImage
    private func applyBlur(image: UIImage) -> UIImage? {
        guard let ciimage = CIImage(image: image) else {
            return nil
        }
        if let filter = CIFilter(name: "CIGaussianBlur") {
            filter.setValue(ciimage, forKey: kCIInputImageKey)
            filter.setValue(blurRadius, forKeyPath: kCIInputRadiusKey)

            // Due to a iOS 8 bug, we need to bridging CIContext from OC to avoid crashing
            let context = CIContext()
            if let output = filter.outputImage, let cgimage = context.createCGImage(output, from: ciimage.extent) {
                return UIImage(cgImage: cgimage)
            }
        }
        return nil
    }

    override public var image: UIImage? {
        get {
            return super.image
        }
        set {
            if let image = newValue {
                super.image = applyBlur(image: image)
            } else {
                super.image = nil
            }
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        blur.frame = self.layer.bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class AvatarImageView: LSAvatarImageView {

    private var _avatarProvider: AvatarImageProvider?
    private var _condition: (() -> Bool)?

    public var avatarProvider: AvatarImageProvider? {
        get {
            _avatarProvider
        }
        set {
            set(provider: newValue, condition: { true })
        }
    }

    public func set(provider: AvatarImageProvider?, condition: @escaping () -> Bool) {
        _avatarProvider = provider
        _condition = condition
        self.contentMode = .scaleAspectFill
        guard let avatarProvider = avatarProvider else {
            self.backgroundColor = .white
            self.placeholderText = nil
            self.image = nil
            return
        }

        self.colorHashSeed = avatarProvider.hashSeed
        self.placeholderText = avatarProvider.initials
        self.image = nil
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.round = true
        if let avatarProvider = avatarProvider {
            load(avatarProvider)
        }
    }

    var disposable: Disposable? = nil

    func load(_ provider: AvatarImageProvider)  {

        disposable?.dispose()

        disposable = provider.image(with: (width: Int(self.frame.size.width), height: Int(self.frame.size.height)))
            .start { event in
                let condition = self._condition ?? { true }
                if !condition() {
                    return
                }
                switch event {
                case .value(let image):
                    if let image = image{
                        self.image = image
                        self.backgroundColor = .white
                        self.placeholderText = nil
                    } else {
                        self.colorHashSeed = provider.hashSeed
                        self.placeholderText = provider.initials
                    }
                    self._avatarProvider = nil
                default:
                    ()
                }
        }
    }
}
