//
//  LSPaddedLabel.h
//  Vidacle
//
//  Created by Jacco Taal on 18-01-16.
//  Copyright © 2016 Vidacle B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSPaddedLabel : UILabel

@property IBInspectable UIEdgeInsets paddingInset;
@property IBInspectable CGFloat xPadding;
@property IBInspectable CGFloat yPadding;
@property IBInspectable CGFloat margin;
@property IBInspectable BOOL roundCorners;

@end
