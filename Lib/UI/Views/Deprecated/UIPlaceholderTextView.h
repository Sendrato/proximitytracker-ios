//
//  UIPlaceholderTextView.h
//  Vidacle
//
//  Created by Jacco Taal on 02-12-13.
//  Copyright (c) 2013 Jacco Taal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIPlaceholderTextView : UITextView

@property(nonatomic, retain) IBInspectable NSString *placeholder;
@property(nonatomic, retain) IBInspectable UIColor *placeholderColor;

- (void)textChanged:(NSNotification *)notification;

@end
