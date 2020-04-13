//
//  LSAvatarImageView.h
//  Vidacle
//
//  Created by Jacco Taal on 11-03-15.
//  Copyright (c) 2015 Jacco Taal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSImageProvider;
@class LSUserModel;

@interface LSAvatarImageView : UIView

@property (nonatomic, strong) NSString * placeholderText;
@property (nonatomic, strong) NSString * colorHashSeed;
@property (nonatomic, strong) IBInspectable  NSNumber * borderWidth;
@property (nonatomic, strong) IBInspectable  UIColor * borderColor;
@property (nonatomic) IBInspectable BOOL round;
@property (nonatomic) UIImage * image;

@end


@interface LSAvatarImageView (LSImageProvider)

@property (nonatomic) LSImageProvider * imageProvider;
-(void)setImageProvider:(LSImageProvider *)imageProvider predicate:(BOOL (^)(void))predicate;

@end
