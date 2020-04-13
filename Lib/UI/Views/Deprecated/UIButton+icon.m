//
//  UIButton+icon.m
//  Vidacle
//
//  Created by Jacco Taal on 23-05-16.
//  Copyright © 2016 Vidacle B.V. All rights reserved.
//

#import "UIButton+icon.h"
@import FontAwesomeKit;

@implementation UIButton (icon)

-(void)setIcon:(FAKIcon *)icon forState:(UIControlState)state {
    CGFloat height = icon.iconFontSize * 1.2;
    [self setImage:[[icon imageWithSize:CGSizeMake(height, height)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:state];
}

-(void)setIcon:(FAKIcon *)icon size:(CGSize)size forState:(UIControlState)state {
    [self setImage:[[icon imageWithSize:size] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
          forState:state];
}

@end
