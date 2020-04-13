//
//  UIView+AFNetworking.m
//  Vidacle
//
//  Created by Jacco Taal on 23-07-13.
//  Copyright (c) 2013 Jacco Taal. All rights reserved.
//

@import UIKit;
@import RestKit.AFRKHTTPClient;
@import RestKit.AFRKImageRequestOperation;
@import RestKit.UIImageView_AFRKNetworking;

#import "UIImage+AFNetworking.h"


@interface AFImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;
@end

@interface UIImageView (UIImage)
+ (AFImageCache *)afrk_sharedImageCache;
+ (NSOperationQueue *)afrk_sharedImageRequestOperationQueue;
@end

@implementation UIImage (AFNetworking)


+ (NSMutableDictionary *)af_shared_currentOperations {
    static NSMutableDictionary *_currentOperations = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentOperations = [[NSMutableDictionary alloc] init];
    });
    return _currentOperations;
}

+ (void)setImageInCache:(UIImage *)image forURL:(NSURL *)url {
    if (url)
        [[UIImageView afrk_sharedImageCache] setObject:image
                                              forKey:url.absoluteString];
}

+ (void)removeImageURLFromCache:(NSURL *)url {
    if (url)
        [[UIImageView afrk_sharedImageCache]
            removeObjectForKey:url.absoluteString];
}

+ (UIImage *)imageFromCacheForURL:(NSURL *)url {
    if (url)
        return
            [[UIImageView afrk_sharedImageCache] objectForKey:url.absoluteString];
    return nil;
}

+ (void)complete:(UIImageCompletionBlock)complete
    withImageURL:(NSURL *)url
     placeholder:(UIImage *)placeholder {
    return [self complete:complete withImageURL:url placeholder:placeholder headers:nil];
}

+ (void)complete:(UIImageCompletionBlock)complete
    withImageURL:(NSURL *)url
     placeholder:(UIImage *)placeholder
          headers:(NSArray*) headers{

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    for (NSArray * header in headers) {
        [urlRequest addValue:header[1] forHTTPHeaderField:header[0]];
    }

    UIImage *cachedImage =
        [[UIImageView afrk_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage) {
        if (complete) {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               complete(cachedImage, false);
                           });
        }

    } else {
        NSMutableDictionary *currentOperations =
            [UIImage af_shared_currentOperations];
        NSString *key = urlRequest.URL.absoluteString;
        if (key) {
            @synchronized(currentOperations) {
                NSMutableArray * thisImgOperations = currentOperations[key];
                if (thisImgOperations) {
                    [thisImgOperations addObject:complete];
                    return;
                } else {
                    currentOperations[key] = [NSMutableArray arrayWithObject:complete];
                }
            }
        }
        AFRKHTTPRequestOperation *requestOperation =
            [[AFRKImageRequestOperation alloc] initWithRequest:urlRequest];
        requestOperation.allowsInvalidSSLCertificate = YES;
        [requestOperation
            setCompletionBlockWithSuccess:^(AFRKHTTPRequestOperation *operation,
                                            UIImage *responseObject) {
                if (responseObject) {
                    [[UIImageView afrk_sharedImageCache] cacheImage:responseObject
                                                       forRequest:urlRequest];
                    NSMutableArray *completions;
                    NSString *key = operation.request.URL.absoluteString;
                    if (key) {
                        @synchronized(currentOperations) {
                            completions = currentOperations[key];
                            [currentOperations removeObjectForKey:key];
                        }
                        [completions enumerateObjectsUsingBlock:
                                         ^(UIImageCompletionBlock complete,
                                           NSUInteger idx, BOOL *stop) {
                                             complete(responseObject, false);
                                         }];
                    }
                }
            }
            failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
                NSString *key = operation.request.URL.absoluteString;
                if (placeholder)
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{ complete(placeholder, true);
                                   });

                if (key) {
                    @synchronized(currentOperations) {
                        [currentOperations removeObjectForKey:key];
                    }
                }
            }];

        [[UIImageView afrk_sharedImageRequestOperationQueue]
            addOperation:requestOperation];
    }
}

@end
