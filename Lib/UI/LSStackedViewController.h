//
//  LSStackedViewController.h
//  Vidacle
//
//  Created by Jacco Taal on 23-11-15.
//  Copyright © 2015 Vidacle B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <LifeshareSDK/LSPlayerView.h>

NS_ASSUME_NONNULL_BEGIN

@class LSStackedViewController;

@interface LSStackedViewControllerItem : NSObject

@property(nullable) NSString * title;

@property(nullable) UIView * header;

// Can be nil. if nonnull viewController will become a childViewController of the StackedViewController
@property(nullable) UIViewController * viewController;

@property(nonnull) UIView * view;

-(instancetype)initWithView:(UIView*) view;
-(instancetype)initWithView:(UIView*) view header: (UIView* _Nullable) header NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithView:(UIView*) view title: (NSString* _Nullable) title;

@end


@protocol  LSStackedViewControllerDataSource <NSObject>

@property(readonly) RACCommand<id, id> * reloadItems;

-(LSStackedViewControllerItem*) stackedViewController:(LSStackedViewController*)viewController itemAtIndex:(NSInteger) idx;

-(NSInteger)numberOfItemsForStackedViewController:(LSStackedViewController*)viewController;

@end


@interface LSStackedViewController: UIViewController<LSPlayerViewDelegate>

@property(strong, nonatomic, readonly, nullable) id<LSStackedViewControllerDataSource> dataSource;

@property(readonly, nonatomic)  UIScrollView * scrollView;

@property(readwrite, nonatomic, nullable)  UIView * header;

@property(readonly, nonatomic)  UIStackView * stackView;

@property UIEdgeInsets insets;

+(UIView*)headerWithTitle:(NSString*)title;

-(instancetype)initWithDataSource:(id<LSStackedViewControllerDataSource>) dataSource NS_DESIGNATED_INITIALIZER;

-(void)reloadData;

@end

NS_ASSUME_NONNULL_END
