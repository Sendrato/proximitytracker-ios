//
//  UIButton+icon.h
//  Vidacle
//
//  Created by Jacco Taal on 23-05-16.
//  Copyright © 2016 Vidacle B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FAKIcon;

@interface UIButton (icon)

-(void)setIcon:(FAKIcon *)icon forState:(UIControlState)state;

-(void)setIcon:(FAKIcon *)icon size:(CGSize)size forState:(UIControlState)state ;

@end
