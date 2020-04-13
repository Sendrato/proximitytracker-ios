//
//  UIView+AFNetworking.h
//  Vidacle
//
//  Created by Jacco Taal on 23-07-13.
//  Copyright (c) 2013 Jacco Taal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIImageCompletionBlock)(UIImage *image, BOOL isPlaceholder);

@interface UIImage (AFNetworking)

+ (void)removeImageURLFromCache:(NSURL *)url;
+ (void)setImageInCache:(UIImage *)image forURL:(NSURL *)url;
+ (UIImage *)imageFromCacheForURL:(NSURL *)url;

+ (void)complete:(UIImageCompletionBlock)complete
    withImageURL:(NSURL *)url
     placeholder:(UIImage *)placeholder;

+ (void)complete:(UIImageCompletionBlock)complete
    withImageURL:(NSURL *)url
     placeholder:(UIImage *)placeholder
         headers:(NSArray*) headers;

@end
