//
//  LSPaddedLabel.m
//  Vidacle
//
//  Created by Jacco Taal on 18-01-16.
//  Copyright © 2016 Vidacle B.V. All rights reserved.
//

#import "LSPaddedLabel.h"

@implementation LSPaddedLabel {
    UIColor * _bgColor;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    _bgColor = backgroundColor;
    [super setBackgroundColor:nil];
    [self setNeedsDisplay];
}

-(UIColor *)backgroundColor {
    return _bgColor;
}

-(void)awakeFromNib {
    [super awakeFromNib];

    if(self.xPadding>0 || self.yPadding>0) {
        self.paddingInset = UIEdgeInsetsMake(self.yPadding, self.xPadding, self.yPadding, self.xPadding);
    }
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = self.paddingInset;
    CGRect _rect = CGRectInset(rect, 0, self.margin);
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (self.roundCorners) {
        CGFloat cornerRadius = rect.size.height/2.0;
        CGPathRef clippingPath = [UIBezierPath bezierPathWithRoundedRect:_rect cornerRadius:cornerRadius].CGPath;
        CGContextAddPath(context, clippingPath);
    } else {
        CGPathRef clippingPath = [UIBezierPath bezierPathWithRect:_rect].CGPath;
        CGContextAddPath(context, clippingPath);
    }
    [_bgColor set];
    CGContextSetAlpha(context, self.alpha);
    CGContextFillPath(context);

    [super drawTextInRect:UIEdgeInsetsInsetRect(_rect, insets)];
}

- (CGSize) intrinsicContentSize {

    CGSize intrinsicSuperViewContentSize = super.intrinsicContentSize ;

    intrinsicSuperViewContentSize.width += self.paddingInset.left + self.paddingInset.right ;
    intrinsicSuperViewContentSize.height += self.paddingInset.top + self.paddingInset.bottom ;

    return intrinsicSuperViewContentSize ;

}


@end
