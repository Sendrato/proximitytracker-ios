//
//  LSStackedViewController.m
//  Vidacle
//
//  Created by Jacco Taal on 23-11-15.
//  Copyright © 2015 Vidacle B.V. All rights reserved.
//

@import UIKit;
@import Foundation;

#import <LifeshareSDK/LifeshareSDK-Swift.h>

#import "LSStackedViewController.h"

@implementation LSStackedViewControllerItem

-(instancetype)init {
    return [self initWithView:[UIView new] header: nil];
}

-(instancetype)initWithView:(UIView *)view {
    return [self initWithView:view header:nil];
}

-(instancetype)initWithView:(UIView *)view header:(UIView *)header {
    if (!(self = [super init]))
        return nil;
    self.view = view;
    self.header = header;
    return self;
}

-(instancetype)initWithView:(UIView *)view title:(NSString *)title {
    self = [self initWithView:view header:nil];
    self.title = title;
    return self;
}

@end


@interface LSStackedViewController ()

@property(strong, nonatomic) NSArray * items;
@property(readwrite, nonatomic)  UIScrollView * scrollView;
@property(readwrite, nonatomic)  UIStackView * stackView;

@end

@implementation LSStackedViewController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    return nil;
}
#pragma clang diagnostic pop


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

-(instancetype)initWithDataSource:(id<LSStackedViewControllerDataSource>)dataSource {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _dataSource = dataSource;
    }
    return self;
}


-(void)viewDidLoad {
    [super viewDidLoad];

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = false;
    self.scrollView.refreshControl = [[UIRefreshControl alloc] init];

    self.scrollView.refreshControl.rac_command = self.dataSource.reloadItems;

    [self.dataSource.reloadItems.executionSignals.switchToLatest subscribeNext:^(RACSignal<id> * _Nullable x) {
        [self reloadData];
    }];

    [self.view addSubview:self.scrollView];

    if (_header) {
        NSDictionary * viewsDictionary = NSDictionaryOfVariableBindings(_scrollView, _header);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_header]|" options:0 metrics: 0 views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_header][_scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
        if (@available(iOS 11.0, *)) {
            [[_header.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor] setActive:true];
        } else {
            [[_header.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:true];
        }
    } else {
        NSDictionary * viewsDictionary = NSDictionaryOfVariableBindings(_scrollView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    }

    UIStackView * stackView = self.stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = false;

    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.spacing = 2.0;
    stackView.alignment = UIStackViewAlignmentFill;

    [self.scrollView addSubview:stackView];

    NSDictionary * viewsDictionary = NSDictionaryOfVariableBindings(_stackView);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_stackView]|"
                                                                      options:0
                                                                      metrics: 0
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_stackView]|"
                                                                      options:0
                                                                      metrics: 0
                                                                        views:viewsDictionary]];

}


-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(UIViewController *)viewControllerForItem:(LSStackedViewControllerItem *)item {
    return item.viewController;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self tryLoad: 0];
}

-(void)tryLoad: (NSInteger) try {
    [[_dataSource.reloadItems execute:nil] subscribeNext:^(id  _Nullable x) {
    } error:^(NSError * _Nullable error) {
        if (try<3) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Could not load home page"
                                                                            message:@"Are you connected to Internet"
                                                                         withButton:@"Retry"
                                                                            handler:^(UIAlertController * _Nonnull controller,
                                                                                      UIAlertAction * _Nonnull action) {
                [self tryLoad: try + 1];
            }];
            [self presentViewController:alert animated:true completion:nil];
        }
    } completed:^{
    }];
}

#pragma  mark Properties

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length,
                                                0,
                                                self.bottomLayoutGuide.length,
                                                0);
}

#pragma mark

-(void)reloadData {
    for (UIViewController * child in self.childViewControllers) {
        [child willMoveToParentViewController:nil];
        [child.view removeFromSuperview];
        [child removeFromParentViewController];
    }

    for (UIView * sub in self.stackView.arrangedSubviews) {
        [sub removeFromSuperview];
        [self.stackView removeArrangedSubview: sub];
    }

    NSInteger count = [self.dataSource numberOfItemsForStackedViewController:self];

    for (NSInteger i = 0; i < count; i++) {
        LSStackedViewControllerItem * item = [self.dataSource stackedViewController:self itemAtIndex:i];


        if (item.title) {
            item.header = [[self class] headerWithTitle:item.title];
        }

        if (item.header) {
            item.header.translatesAutoresizingMaskIntoConstraints = false;
            [self.stackView addArrangedSubview:item.header];

            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[header]-|"
                                                                              options:0
                                                                              metrics:nil
                                                                            views:@{@"header":item.header}]];
        }

        UIViewController * vc = [self viewControllerForItem:item];
        if (vc) {
            [self addChildViewController:vc];
        }

        item.view.translatesAutoresizingMaskIntoConstraints = false;
        [self.stackView addArrangedSubview:item.view];

        item.view.translatesAutoresizingMaskIntoConstraints = false;

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:item.view
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0
                                                                    constant:0]];

        if ([item.viewController isKindOfClass:[UICollectionViewController class]]) {
            ((UICollectionViewController *) item.viewController).collectionView.contentInset = UIEdgeInsetsMake(0, self.insets.left, 0, self.insets.right);
        }
    }

}


+(UIView*)headerWithTitle:(NSString*)title {

    static UIFont * font;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        font = [LifeshareSDK.shared.theme defaultFontOfSize:14 weight:400];
    });

    UILabel * label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = false;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = font;
    label.textColor = LifeshareSDK.shared.theme.foregroundColor;
    label.text = title;

    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:@{@"label":label}]];

    return label;
}


-(void)playerViewRequestsDismissFullScreen:(LSPlayerView *)playerView {
    if ([self.presentedViewController isKindOfClass:FullScreenPlayerViewController.class]) {
        [((FullScreenPlayerViewController*)self.presentedViewController) minimize];
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

-(void)playerViewRequestsPresentFullScreen:(LSPlayerView *)playerView {
    UIViewController * fullscreen = [[FullScreenPlayerViewController alloc] initWithPlayerView:playerView];
    fullscreen.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController: fullscreen animated:true completion:^{
        [playerView setNeedsLayout];
    }];
}

@end
