//
//  UIPlaceholderTextView.m
//  Vidacle
//
//  Created by Jacco Taal on 02-12-13.
//  Copyright (c) 2013 Jacco Taal. All rights reserved.
//

#import "UIPlaceholderTextView.h"

@interface UIPlaceholderTextView ()

@property(nonatomic, retain) UILabel *placeHolderLabel;

@end

@implementation UIPlaceholderTextView {
    NSString * _placeholder;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    // Use Interface Builder User Defined Runtime Attributes to set
    // placeholder and placeholderColor in Interface Builder.
    if (!self.placeholder) {
        self.placeholder = @"";
    }

    if (!self.placeholderColor) {
        self.placeholderColor = [UIColor lightGrayColor];
    }

    if (_placeHolderLabel == nil) {
        _placeHolderLabel = [[UILabel alloc]
                             initWithFrame:CGRectInset(self.bounds, 8, 8)];
        _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _placeHolderLabel.numberOfLines = 0;
        _placeHolderLabel.font = self.font;
        _placeHolderLabel.backgroundColor = [UIColor clearColor];
        _placeHolderLabel.textColor = self.placeholderColor;
        _placeHolderLabel.alpha = 0;
        _placeHolderLabel.tag = 999;
        [self addSubview:_placeHolderLabel];
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    /*CALayer * lineTop = [[CALayer alloc] init];
    CALayer * lineBot = [[CALayer alloc] init];
    lineTop.frame = CGRectMake(0, 0, self.frame.size.width, 0.5);
    lineBot.frame = CGRectMake(0, self.frame.size.height,
                               self.frame.size.width, 0.5);

    UIColor * grey = [UIColor grayColor];
    lineTop.backgroundColor = grey.CGColor;
    lineBot.backgroundColor = grey.CGColor;

    [self.layer addSublayer:lineTop];
    [self.layer addSublayer:lineBot];
    lines = @[lineTop, lineBot];
*/
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(textChanged:)
               name:UITextViewTextDidChangeNotification
             object:nil];
}


-(void)layoutSubviews {
    [super layoutSubviews];
    _placeHolderLabel.frame = CGRectInset(self.bounds, 8, 8);
    [_placeHolderLabel sizeToFit];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.placeholder = @"";
        self.placeholderColor = [UIColor lightGrayColor];
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(textChanged:)
                   name:UITextViewTextDidChangeNotification
                 object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification {
    if (self.text.length == 0 && self.placeholder.length > 0) {
        _placeHolderLabel.alpha = 1;
    } else {
        _placeHolderLabel.alpha = 0;
    }

}

- (void)setText:(NSString *)text {
    super.text = text;
    [self textChanged:nil];
}

-(NSString *)placeholder{
    return _placeholder;
}

-(void)setPlaceholder:(NSString *)placeholder {
    _placeHolderLabel.text = placeholder;
    _placeholder = placeholder;
    [self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect {

    [super drawRect:rect];
    CGRect bounds = self.bounds;
    NSLog(@"Bounds: %@ %@", NSStringFromCGRect(bounds), NSStringFromCGRect(rect));
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGPathMoveToPoint(visiblePath, NULL, bounds.origin.x, bounds.origin.y);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.size.width, bounds.origin.y);
    CGPathMoveToPoint(visiblePath, NULL, bounds.origin.x, bounds.size.height+bounds.origin.y);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.size.width, bounds.size.height+bounds.origin.y);

    UIColor *aColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    [aColor setStroke];
    CGContextAddPath(context, visiblePath);
    CGContextStrokePath(context);
    CGPathRelease(visiblePath);
}

@end
