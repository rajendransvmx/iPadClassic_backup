//
//  SMSplitViewController.h
//  POCReskin
//
//  Created by Pushpak on 13/08/14.
//  Copyright (c) 2014 pushpak. All rights reserved.
//

#import "SMSplitViewController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#pragma mark - SMSplitPopover category
@interface SMSplitPopover ()

@property (nonatomic, weak) SMSplitViewController *smSplitViewController;

@end

#pragma mark - SMSplitView delegate
@protocol SMSplitViewDelegate <NSObject>

- (BOOL)shouldAutoHideMasterInOrientation:(UIInterfaceOrientation)orientation;
- (void)willHideMaster;
- (void)didHideMaster;
- (void)willShowMaster;
- (void)didShowMaster;

@end

#pragma mark - SMSplitView interface
@interface SMSplitView : UIView

@property (nonatomic, weak) id<SMSplitViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *masterView;
@property (nonatomic, strong, readonly) UIView *detailView;

@property (nonatomic, assign) CGFloat splitLineWidth;
@property (nonatomic, assign) CGFloat masterWidth;
@property (nonatomic, assign, readonly) BOOL isMasterVisible;

- (void)setMasterView:(UIView *)masterView detailView:(UIView *)detailView;
- (void)toggleMasterVisible;
- (void)hideMasterAnimated:(BOOL)animated;
- (void)setSplitLineColor:(UIColor *)color;

@end

#pragma mark - SMSplitView implementation
@interface SMSplitView ()

@property (nonatomic, strong) UIView *masterView;
@property (nonatomic, strong) UIView *detailView;
@property (nonatomic, strong) UIView *splitLineView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, weak) UIView *realMasterView;

@property (nonatomic, assign) BOOL isInPopoverState;
@property (nonatomic, assign) BOOL isPoping;
@property (nonatomic, assign) BOOL isMasterVisible;

@end

@implementation SMSplitView

CGFloat const kDefaultMasterWidth = 320.0;
CGFloat const kDefaultSplitLineWidth = 1.0;
float const kDefaultAnimationDuration = 0.25;

@synthesize splitLineWidth = _splitLineWidth;
@synthesize masterWidth = _masterWidth;

- (void)setMasterView:(UIView *)masterView detailView:(UIView *)detailView
{
    if (self.isInPopoverState) {
        [self hideMasterAnimated:NO];
    }
    [_masterView removeFromSuperview];
    [_detailView removeFromSuperview];

    _masterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.masterViewWidth, self.bounds.size.height)];
    _masterView.backgroundColor = [UIColor clearColor];
    _masterView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;

    masterView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    self.realMasterView = masterView;
    [self.masterView addSubview:masterView];
    [_masterView addSubview:self.splitLineView];
    [self layoutMasterView];

    _detailView = detailView;
    _detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self addSubview:_masterView];
    [self addSubview:_detailView];

    [self setNeedsLayout];
}


//HS added
- (void)setDetailView:(UIView *)detailView
{
    if (self.isInPopoverState) {
        [self hideMasterAnimated:NO];
    }
    [_detailView removeFromSuperview];
    
    _detailView = detailView;
    _detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_detailView];
    [self setNeedsLayout];
}
//HS ends


- (void)layoutMasterView
{
    self.masterView.frame = CGRectMake(0, 0, self.masterViewWidth, self.bounds.size.height);
    self.realMasterView.frame = CGRectMake(0, 0, self.masterWidth, self.bounds.size.height);
    self.splitLineView.frame = CGRectMake(self.masterWidth, 0, self.splitLineWidth, self.bounds.size.height);
}

- (UIView *)splitLineView
{
    if (!_splitLineView) {
        _splitLineView = [[UIView alloc]initWithFrame:CGRectMake(self.masterWidth, 0, self.splitLineWidth, self.bounds.size.height)];
        _splitLineView.backgroundColor = [UIColor colorFromHexString:kActionBgColor];
        _splitLineView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    }
    return _splitLineView;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:self.bounds];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideMaster)];
        [_maskView addGestureRecognizer:tapGesture];
        [self insertSubview:_maskView atIndex:0];
    }
    return _maskView;
}

- (void)setMasterWidth:(CGFloat)masterWidth
{
    masterWidth = masterWidth > 0 ? masterWidth : kDefaultMasterWidth;
    if (_masterWidth != masterWidth) {
        _masterWidth = masterWidth;
        [self layoutMasterView];
        [self setNeedsLayout];
    }
}

- (CGFloat)masterWidth
{
    return  _masterWidth > 0 ? _masterWidth : kDefaultMasterWidth;
}

- (void)setSplitLineWidth:(CGFloat)splitLineWidth
{
    splitLineWidth = splitLineWidth > kDefaultSplitLineWidth ? splitLineWidth : kDefaultSplitLineWidth;
    if (_splitLineWidth != splitLineWidth) {
        _splitLineWidth = splitLineWidth;
        [self layoutMasterView];
        [self setNeedsLayout];
    }
}

- (CGFloat)splitLineWidth
{
    return _splitLineWidth > kDefaultSplitLineWidth ? _splitLineWidth : kDefaultSplitLineWidth;
}

- (CGFloat)masterViewWidth
{
    return self.masterWidth + self.splitLineWidth;
}

- (void)setSplitLineColor:(UIColor *)color
{
    self.splitLineView.backgroundColor = color;
}

- (void)layoutSubviews
{
    if (self.isPoping) {
        return;
    }
    self.isInPopoverState = NO;
    self.maskView.hidden = YES;
    NSAssert(self.delegate, @"must set the SMSplitView's delegate.");
    if ([self.delegate shouldAutoHideMasterInOrientation:[UIApplication sharedApplication].statusBarOrientation]) {
        [self.delegate willHideMaster];
        self.masterView.frame = CGRectMake(0, 0, 0, self.bounds.size.height);
        self.masterView.clipsToBounds = YES;
        self.detailView.frame = self.bounds;
        self.isMasterVisible = NO;
        [self.delegate didHideMaster];
        
    } else {
        [self.delegate willShowMaster];
        self.masterView.frame = CGRectMake(0, 0, self.masterViewWidth, self.bounds.size.height);
        self.masterView.clipsToBounds = NO;
        CGRect frame = self.bounds;
        frame.origin.x = self.masterViewWidth;
        frame.size.width = self.bounds.size.width - self.masterViewWidth;
        self.detailView.frame = frame;
        self.isMasterVisible = YES;
        [self.delegate didShowMaster];
        
    }
}

- (void)showMaster
{
    [self showMasterAnimated:YES];
}

- (void)showMasterAnimated:(BOOL)animated
{
    if (self.isInPopoverState) {
        return;
    }
    self.isPoping = YES;
    self.maskView.hidden = NO;
    [self bringSubviewToFront:self.maskView];
    [self bringSubviewToFront:self.masterView];
    self.isInPopoverState = YES;
    self.isMasterVisible = YES;
    if (animated) {
        self.masterView.clipsToBounds = YES;
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            self.masterView.frame = CGRectMake(0, 0, self.masterViewWidth, self.bounds.size.height);
        } completion:^(BOOL finished) {
            self.masterView.clipsToBounds = NO;
            self.isPoping = NO;
        }];
    } else {
        self.masterView.frame = CGRectMake(0, 0, self.masterViewWidth, self.bounds.size.height);
        self.isPoping = NO;
    }
}

- (void)hideMaster
{
    [self hideMasterAnimated:YES];
}

- (void)hideMasterAnimated:(BOOL)animated
{
    if (!self.isInPopoverState) {
        return;
    }
    self.isPoping = YES;
    self.maskView.hidden = YES;
    self.isInPopoverState = NO;
    self.isMasterVisible = NO;
    if (animated) {
        self.masterView.clipsToBounds = YES;
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            self.masterView.frame = CGRectMake(0, 0, 0, self.bounds.size.height);
        } completion:^(BOOL finished) {
            self.isPoping = NO;
        }];
    } else {
        self.masterView.frame = CGRectMake(0, 0, 0, self.bounds.size.height);
        self.isPoping = NO;
    }
}

- (void)toggleMasterVisible
{
    if (self.isInPopoverState) {
        [self hideMaster];
    } else {
        [self showMaster];
    }
}

@end

#pragma mark - SMSplitViewController
typedef NS_ENUM(NSInteger, MasterAutoShowingState) {
    MasterAutoShowingStateUnknown,
    MasterAutoShowingStateHide,
    MasterAutoShowingStateShow,
};

@interface SMSplitViewController () <SMSplitViewDelegate>

@property (nonatomic, weak) SMSplitView *splitView;
@property (nonatomic, assign) MasterAutoShowingState masterAutoShowingState;
@property (nonatomic, strong) UIBarButtonItem *barButtonItem;
@property (nonatomic, strong) SMSplitPopover *smSplitPopover;

@end

@implementation SMSplitViewController

- (void)loadView
{
    SMSplitView *splitView = [[SMSplitView alloc]init];
    splitView.delegate = self;
    self.view = splitView;
    
    UIBarButtonItem *barButtomItem = [[UIBarButtonItem alloc]init];
    barButtomItem.target = splitView;
    barButtomItem.action = @selector(toggleMasterVisible);
    self.barButtonItem = barButtomItem;
    SMSplitPopover *popover = [[SMSplitPopover alloc]init];
    popover.smSplitViewController = self;
    self.smSplitPopover = popover;

}

- (SMSplitView *)splitView
{
    return (SMSplitView *)self.view;
}

- (void)setSplitLineWidth:(CGFloat)splitLineWidth
{
    self.splitView.splitLineWidth = splitLineWidth;
}

- (CGFloat)splitLineWidth
{
    return self.splitView.splitLineWidth;
}

- (void)setMasterWidth:(CGFloat)masterWidth
{
    self.splitView.masterWidth = masterWidth;
}

- (CGFloat)masterWidth
{
    return self.splitView.masterWidth;
}

- (void)setSplitLineColor:(UIColor *)color
{
    self.splitView.backgroundColor = color;
}

- (UIColor *)splitLineColor
{
    return self.splitView.backgroundColor;
}

- (BOOL)isMasterVisible
{
    return self.splitView.isMasterVisible;
}

- (UIViewController *)masterViewController
{
    return self.viewControllers[0];
}

- (UIViewController *)detailViewController
{
    return self.viewControllers[1];
}


- (void)setViewControllers:(NSArray *)viewControllers
{
     _viewControllers = viewControllers;
     NSAssert(self.viewControllers.count == 2 && self.masterViewController != self.detailViewController, @"should exactly have two diffrent viewControllers.");
     [self addChildViewController:self.masterViewController];
     [self addChildViewController:self.detailViewController];
     [self.splitView setMasterView:self.masterViewController.view detailView:self.detailViewController.view];
}


- (void)triggerDelegateWillHideMaster
{
    if ([self.delegate respondsToSelector:@selector(splitViewController:willHideViewController:withBarButtonItem:popover:)]) {

        [self.delegate splitViewController:self
                    willHideViewController:self.masterViewController
                         withBarButtonItem:self.barButtonItem
                                   popover:self.smSplitPopover];
        self.masterAutoShowingState = MasterAutoShowingStateHide;
    }
}

- (void)triggerDelegateDidHideMaster
{
    if ([self.delegate respondsToSelector:@selector(splitViewController:didHideViewController:withBarButtonItem:popover:)]) {
        [self.delegate splitViewController:self
                    didHideViewController:self.masterViewController
                         withBarButtonItem:self.barButtonItem
                                   popover:self.smSplitPopover];
    }
}

- (void)triggerDelegateWillShowMaster
{
    if ([self.delegate respondsToSelector:@selector(splitViewController:willShowViewController:barButtonItem:)]) {
        [self.delegate splitViewController:self
                    willShowViewController:self.masterViewController
                 barButtonItem:self.barButtonItem];
        self.masterAutoShowingState = MasterAutoShowingStateShow;
    }
}

- (void)triggerDelegateDidShowMaster
{
    if ([self.delegate respondsToSelector:@selector(splitViewController:didShowViewController:barButtonItem:)]) {
        [self.delegate splitViewController:self
                    didShowViewController:self.masterViewController
                 barButtonItem:self.barButtonItem];
    }
}


- (void)hideMasterAnimated:(BOOL)animated
{
    [self.splitView hideMasterAnimated:animated];
}

- (BOOL)shouldAutoHideMasterInOrientation:(UIInterfaceOrientation)orientation
{
    if (![self.delegate respondsToSelector:@selector(splitViewController:shouldHideViewController:inOrientation:)]) {
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return [self.delegate splitViewController:self shouldHideViewController:self.masterViewController inOrientation:orientation];
    }
}

- (void)willHideMaster
{
    [self triggerDelegateWillHideMaster];
}

- (void)didHideMaster
{
    [self triggerDelegateDidHideMaster];
}

- (void)willShowMaster
{
    [self triggerDelegateWillShowMaster];
}

- (void)didShowMaster
{
    [self triggerDelegateDidShowMaster];
}

@end

#pragma mark - SMSplitPopover implementation
@implementation SMSplitPopover

- (void)dismissPopoverAnimated:(BOOL)animated
{
    [self.smSplitViewController hideMasterAnimated:animated];
}

@end
