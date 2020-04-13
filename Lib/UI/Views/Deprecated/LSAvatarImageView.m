//
//  LSAvatarImageView.m
//  Vidacle
//
//  Created by Jacco Taal on 11-03-15.
//  Copyright (c) 2015 Jacco Taal. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <ReactiveObjC/ReactiveObjC.h>

#import "LSPictureModel.h"
#import "LSModel.h"
#import "LSUserModel.h"
#import "LSAvatarImageView.h"
#import "UIImage+AFNetworking.h"

@implementation LSAvatarImageView {
    unsigned char * _digest;
    NSString * _placeholderText;
    UILabel __weak * _label;
    BOOL _round;
    UIImageView* _imageView;
    NSLayoutConstraint *_imageSizeInContainerConstraint;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {

        [self addSubViews];

    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubViews];
    }
    return self;
}


-(void)addSubViews {
    self->_imageView = [UIImageView new];
    self->_imageView.translatesAutoresizingMaskIntoConstraints = false;
    self.contentMode = UIViewContentModeScaleAspectFill;
    self->_imageView.contentMode = UIViewContentModeScaleAspectFill;

    [self addSubview:_imageView];

    NSMutableArray * constraints = [NSMutableArray new];
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    _imageSizeInContainerConstraint =
    [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [constraints addObject: _imageSizeInContainerConstraint];

    [NSLayoutConstraint activateConstraints:constraints];

    self.layer.borderColor = self.borderColor.CGColor;
    self.layer.borderWidth = self.borderWidth.floatValue;
    self.clipsToBounds = true;
    self.layer.masksToBounds = true;
    _imageView.clipsToBounds = true;
    if (self.layer.borderColor != nil && self.layer.borderWidth == 0)
        self.layer.borderWidth = 1.0;
    self.round = true;

}


-(void)awakeFromNib {
    self.round = true;
    [super awakeFromNib];
    self.layer.borderColor = self.borderColor.CGColor;
    self.layer.borderWidth = self.borderWidth.floatValue;
    self.clipsToBounds = true;
    self.layer.masksToBounds = true;
    _imageView.clipsToBounds = true;
    if (self.layer.borderColor != nil && self.layer.borderWidth == 0)
        self.layer.borderWidth = 1.0;
    _imageView.backgroundColor = nil;
}

-(BOOL)round {
    return _round;
}

-(void)setRound:(BOOL)round {
    _round = round;
    CGSize s = self.frame.size;
    if (round)
        self.layer.cornerRadius = MIN(s.width, s.height) / 2.0;
    else
        self.layer.cornerRadius = 0.0;

    if (round) {
        if (self.contentMode == UIViewContentModeScaleAspectFit) {
            self->_imageSizeInContainerConstraint.constant = - M_SQRT1_2 * s.width / 2.0;
        } else {
            self->_imageSizeInContainerConstraint.constant = 0.0;
        }
    } else {
        self->_imageSizeInContainerConstraint.constant = 0.0;
    }
    [self setNeedsLayout];
}

-(UIViewContentMode)contentMode {
    return [super contentMode];
}

-(void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    [self setRound:_round];
}


-(void)layoutSubviews {
    [super layoutSubviews];

    CGSize s = self.frame.size;
    if (_round)
        self.layer.cornerRadius = MIN(s.width, s.height)/2.0;
    else
        self.layer.cornerRadius = 0.0;

    _label.frame = CGRectInset(self.bounds, 1.0, 1.0);
    _label.font = [UIFont systemFontOfSize:(CGRectGetHeight(_label.frame)-2.0)/2.5];
}

-(void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderText = placeholderText;

    if (!_label) {
        UILabel * label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        self->_label =label;
    }
    _label.alpha = (self.image != nil )? 1.0 : 0.0;

    _label.text = placeholderText;
    [self setNeedsLayout];
}

-(void)setImage:(UIImage *)image {
    _label.alpha = (image!=nil) ? 1.0 : 0.0;
    _imageView.backgroundColor = [self hashedColor];

    _imageView.image = image;
}

-(UIImage*) image {
    return _imageView.image;
}

-(NSString *)placeholderText {
    return _placeholderText;
}

-(void)dealloc {
    if (_digest) {
        free(_digest);
        _digest = nil;
    }
}

-(void)setColorHashSeed:(NSString *)colorHashSeed {
    if (_digest) {
        free(_digest);
        _digest = nil;
    }
    const char *cstr = colorHashSeed.UTF8String;
    if (cstr) {
        _digest = malloc(16);
        CC_MD5(cstr, (CC_LONG) strlen(cstr), _digest);
    }
    _imageView.backgroundColor = [self hashedColor];
}

-(NSString *)colorHashSeed {
    if (_digest)
        return @((const char *) _digest);
    return nil;
}


-(UIColor *) hashedColor {
    if (!_digest) {
        if (!_placeholderText || _placeholderText.length == 0 || [_placeholderText isEqual:[NSNull null]])
            return [UIColor clearColor];
        self.colorHashSeed = _placeholderText;
    }

    UIColor * color = [UIColor colorWithHue:_digest[0] / 255.0
                                 saturation:0.5+0.5*_digest[1] / 255.0
                                 brightness:0.6+0.4*_digest[2] / 255.0
                                      alpha:1.0];
    return color;
}

@end

@implementation LSAvatarImageView (LSImageProvider)

-(LSImageProvider *)imageProvider {
    return nil;
}
-(void)setImageProvider:(LSImageProvider *)imageProvider {
    return [self setImageProvider:imageProvider predicate:nil];
}

-(void)setImageProvider:(LSImageProvider *)imageProvider predicate:(BOOL (^)(void))predicate {
    if ([imageProvider isKindOfClass:[LSAvatarImageProvider class]]) {
        LSAvatarImageProvider * _av = (LSAvatarImageProvider*) imageProvider;
        self.placeholderText = _av.initials;
        self.colorHashSeed = _av.hashSeed;
    } else {
        self.placeholderText = nil;
        self.colorHashSeed = nil;
    }
    self.image = imageProvider.placeholder;
    self.backgroundColor = imageProvider.backgroundColor;
    self.contentMode = imageProvider.shouldFit ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;

    @weakify(self);
    if (imageProvider !=  nil) {
        [[[imageProvider imageWithSize:self.frame.size] deliverOnMainThread] subscribeNext:^(UIImage * image) {
            if (!predicate || predicate()) {
                @strongify(self);
                if (!self)
                    return;
                self.backgroundColor = imageProvider.backgroundColor;
                self.contentMode = imageProvider.shouldFit ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
                self.round = true; // AvatarImageView is always round //  imageProvider.rounded;

                if ([imageProvider isKindOfClass:[LSAvatarImageProvider class]]) {
                    LSAvatarImageProvider * _av = (LSAvatarImageProvider*) imageProvider;
                    self.placeholderText = _av.initials;
                    self.colorHashSeed = _av.hashSeed;
                }
                self->_imageView.image = image;
            }
        }];
    } else {

    }
}


@end
