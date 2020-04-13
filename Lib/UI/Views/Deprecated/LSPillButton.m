//
//  LSPillButton.m
//  Vidacle
//
//  Created by Jacco Taal on 19-01-16.
//  Copyright © 2016 Vidacle B.V. All rights reserved.
//

#import "LSPillButton.h"

@implementation LSPillButton {
    UIColor * _bgColor;
    CGFloat _padding;
    CGFloat _lineWidth;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (! (self = [super initWithFrame:frame]))
        return nil;

    self->_lineWidth = 1.0;
    self.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    self->_padding = 4;

    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setNeedsLayout];
    [super setBackgroundColor:nil];
}

-(void)layoutSubviews {
    CGFloat r = self.frame.size.height / 2.0 ;
    CGFloat m = self.padding;
    self.contentEdgeInsets = UIEdgeInsetsMake(m, r , m, r  );
    if (self.imageView.image && self.currentTitle != nil) {
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
    } else {
        self.titleEdgeInsets = UIEdgeInsetsZero;
        self.imageEdgeInsets = UIEdgeInsetsZero;
    }

    [super layoutSubviews];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    _bgColor = backgroundColor;
    [self setNeedsDisplay];
}

-(UIColor *)backgroundColor {
    return _bgColor;
}

-(void)setPadding:(CGFloat)padding {
    _padding = padding;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

-(CGFloat)padding {
    return _padding;
}

-(void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

-(CGFloat)lineWidth {
    return _lineWidth;
}

- (void)drawRect:(CGRect)rect {
    CGFloat cornerRadius = rect.size.height/2.0;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPathRef clippingPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius].CGPath;
    CGContextAddPath(context, clippingPath);
    CGContextSetFillColorWithColor(context, _bgColor.CGColor);
    CGContextFillPath(context);

    if (self.borderColor) {
        CGRect _rect = CGRectInset(rect, self.lineWidth/2.0, self.lineWidth/2.0);
        CGPathRef clippingPath = [UIBezierPath bezierPathWithRoundedRect:_rect cornerRadius:cornerRadius].CGPath;
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);

        CGContextAddPath(context, clippingPath);
        CGContextStrokePath(context);
    }

    [super drawRect:rect];
}



@end
