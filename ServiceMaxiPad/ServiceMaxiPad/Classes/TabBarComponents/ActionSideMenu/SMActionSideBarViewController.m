//
//  SMActionSideBarViewController.m
//  iPadRedesignActionMenuComponent
//
//  Created by pushpak on 14/09/14.
//  Copyright (c) 2014 Service Max Inc. All rights reserved.
//

#import "SMActionSideBarViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO_Value(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface SMActionSideBarViewController ()
@property (nonatomic, strong) UIView *translucentView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property CGPoint panStartPoint;
@end

@implementation SMActionSideBarViewController

- (instancetype)init {
	self = [super init];
	if (self) {
		[self initSMActionSideBarViewController];
	}
	return self;
}

- (instancetype)initWithDirectionFromRight:(BOOL)showFromRight {
	self = [super init];
	if (self) {
		_showSideBarFromRight = showFromRight;
		[self initSMActionSideBarViewController];
	}
	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

#pragma mark - Custom Initializer
- (void)initSMActionSideBarViewController {
	_hasShownSideBar = NO;
	self.isCurrentPanGestureTarget = NO;
    
	self.sideBarWidth = 200;
	self.animationDuration = 0.25f;
    
	[self initTranslucentView];
    
	self.view.backgroundColor = [UIColor clearColor];
	self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	self.tapGestureRecognizer.delegate = self;
	[self.view addGestureRecognizer:self.tapGestureRecognizer];
	self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	self.panGestureRecognizer.minimumNumberOfTouches = 1;
	self.panGestureRecognizer.maximumNumberOfTouches = 1;
	[self.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)initTranslucentView {
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO_Value(@"7.0")) {
		CGRect translucentFrame =
        CGRectMake(self.showSideBarFromRight ? self.view.bounds.size.width : -self.sideBarWidth, 0, self.sideBarWidth, self.view.bounds.size.height);
		self.translucentView = [[UIView alloc] initWithFrame:translucentFrame];
		self.translucentView.frame = translucentFrame;
		self.translucentView.contentMode = _showSideBarFromRight ? UIViewContentModeTopRight : UIViewContentModeTopLeft;
		self.translucentView.clipsToBounds = YES;
		[self.view.layer insertSublayer:self.translucentView.layer atIndex:0];
	}
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)loadView {
	[super loadView];
}

#pragma mark - Layout
- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
	if ([self isViewLoaded] && self.view.window != nil) {
		[self layoutSubviews];
	}
}

- (void)layoutSubviews {
	CGFloat x = self.showSideBarFromRight ? self.parentViewController.view.bounds.size.width - self.sideBarWidth : 0;
    
	if (self.contentView != nil) {
		self.contentView.frame = CGRectMake(x, 0, self.sideBarWidth, self.parentViewController.view.bounds.size.height);
	}
}

#pragma mark - Show
- (void)showInViewController:(UIViewController *)controller
                    animated:(BOOL)animated {
    
    if (_hasShownSideBar) {
        return;
    }
    
	if ([self.delegate respondsToSelector:@selector(sideBar:willAppear:)]) {
		[self.delegate sideBar:self willAppear:animated];
	}
    
	[self addToParentViewController:controller callingAppearanceMethods:YES];
	self.view.frame = controller.view.bounds;
    
	CGFloat parentWidth = self.view.bounds.size.width;
	CGRect sideBarFrame = self.view.bounds;
	sideBarFrame.origin.x = self.showSideBarFromRight ? parentWidth : -self.sideBarWidth;
	sideBarFrame.size.width = self.sideBarWidth;
    
	if (self.contentView != nil) {
		self.contentView.frame = sideBarFrame;
	}
	sideBarFrame.origin.x = self.showSideBarFromRight ? parentWidth - self.sideBarWidth : 0;
    
	void (^animations)() = ^{
		if (self.contentView != nil) {
			self.contentView.frame = sideBarFrame;
		}
		self.translucentView.frame = sideBarFrame;
	};
	void (^completion)(BOOL) = ^(BOOL finished)
	{
		_hasShownSideBar = YES;
		self.isCurrentPanGestureTarget = YES;
		if (finished && [self.delegate respondsToSelector:@selector(sideBar:didAppear:)]) {
			[self.delegate sideBar:self didAppear:animated];
		}
	};
    
	if (animated) {
		[UIView animateWithDuration:self.animationDuration delay:0 options:kNilOptions animations:animations completion:completion];
	}
	else {
		animations();
		completion(YES);
	}
}

- (void)showAnimated:(BOOL)animated {
	UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (controller.presentedViewController != nil) {
		controller = controller.presentedViewController;
	}
	[self showInViewController:controller animated:animated];
}

#pragma mark - Show by Pangesture
- (void)startShow:(CGFloat)startX {
	UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (controller.presentedViewController != nil) {
		controller = controller.presentedViewController;
	}
	[self addToParentViewController:controller callingAppearanceMethods:YES];
	self.view.frame = controller.view.bounds;
    
	CGFloat parentWidth = self.view.bounds.size.width;
    
	CGRect sideBarFrame = self.view.bounds;
	sideBarFrame.origin.x = self.showSideBarFromRight ? parentWidth : -self.sideBarWidth;
	sideBarFrame.size.width = self.sideBarWidth;
	if (self.contentView != nil) {
		self.contentView.frame = sideBarFrame;
	}
	self.translucentView.frame = sideBarFrame;
}

- (void)move:(CGFloat)deltaFromStartX {
	CGRect sideBarFrame = self.translucentView.frame;
	CGFloat parentWidth = self.view.bounds.size.width;
    
	if (self.showSideBarFromRight) {
		CGFloat x = deltaFromStartX;
		if (deltaFromStartX >= self.sideBarWidth) {
			x = self.sideBarWidth;
		}
		sideBarFrame.origin.x = parentWidth - x;
	}
	else {
		CGFloat x = deltaFromStartX - _sideBarWidth;
		if (x >= 0) {
			x = 0;
		}
		sideBarFrame.origin.x = x;
	}
    
	if (self.contentView != nil) {
		self.contentView.frame = sideBarFrame;
	}
	self.translucentView.frame = sideBarFrame;
}

- (void)showAnimatedFrom:(BOOL)animated
                  deltaX:(CGFloat)deltaXFromStartXToEndX {
	if ([self.delegate respondsToSelector:@selector(sideBar:willAppear:)]) {
		[self.delegate sideBar:self willAppear:animated];
	}
    
	CGRect sideBarFrame = self.translucentView.frame;
	CGFloat parentWidth = self.view.bounds.size.width;
    
	sideBarFrame.origin.x = self.showSideBarFromRight ? parentWidth - sideBarFrame.size.width : 0;
    
	void (^animations)() = ^{
		if (self.contentView != nil) {
			self.contentView.frame = sideBarFrame;
		}
        
		self.translucentView.frame = sideBarFrame;
	};
	void (^completion)(BOOL) = ^(BOOL finished)
	{
		_hasShownSideBar = YES;
		if (finished && [self.delegate respondsToSelector:@selector(sideBar:didAppear:)]) {
			[self.delegate sideBar:self didAppear:animated];
		}
	};
    
	if (animated) {
		[UIView animateWithDuration:self.animationDuration delay:0 options:kNilOptions animations:animations completion:completion];
	}
	else {
		animations();
		completion(YES);
	}
}

#pragma mark - Dismiss

- (void)dismissAnimated:(BOOL)animated {
    
    if (!_hasShownSideBar) {
        return;
    }
    
	if ([self.delegate respondsToSelector:@selector(sideBar:willDisappear:)]) {
		[self.delegate sideBar:self willDisappear:animated];
	}
    
	void (^completion)(BOOL) = ^(BOOL finished)
	{
		[self removeFromParentViewControllerCallingAppearanceMethods:YES];
		_hasShownSideBar = NO;
		self.isCurrentPanGestureTarget = NO;
		if ([self.delegate respondsToSelector:@selector(sideBar:didDisappear:)]) {
			[self.delegate sideBar:self didDisappear:animated];
		}
	};
    
	if (animated) {
		CGRect sideBarFrame = self.contentView.frame;
		CGFloat parentWidth = self.view.bounds.size.width;
		sideBarFrame.origin.x = self.showSideBarFromRight ? parentWidth : -self.sideBarWidth;
		[UIView animateWithDuration:self.animationDuration
		                      delay:0
		                    options:UIViewAnimationOptionBeginFromCurrentState
		                 animations: ^{
                             if (self.contentView != nil) {
                                 self.contentView.frame = sideBarFrame;
                             }
                             self.translucentView.frame = sideBarFrame;
                         }
         
		                 completion:completion];
	}
	else {
		completion(YES);
	}
}

#pragma mark - Dismiss by Pangesture
- (void)dismissAnimated:(BOOL)animated
                 deltaX:(CGFloat)deltaXFromStartXToEndX {
	if ([self.delegate respondsToSelector:@selector(sideBar:willDisappear:)]) {
		[self.delegate sideBar:self willDisappear:animated];
	}
    
	void (^completion)(BOOL) = ^(BOOL finished)
	{
		[self removeFromParentViewControllerCallingAppearanceMethods:YES];
		_hasShownSideBar = NO;
		self.isCurrentPanGestureTarget = NO;
		if ([self.delegate respondsToSelector:@selector(sideBar:didDisappear:)]) {
			[self.delegate sideBar:self didDisappear:animated];
		}
	};
    
	if (animated) {
		CGRect sideBarFrame = self.contentView.frame;
		CGFloat parentWidth = self.view.bounds.size.width;
		sideBarFrame.origin.x = self.showSideBarFromRight ? parentWidth : -self.sideBarWidth + deltaXFromStartXToEndX;
        
		[UIView animateWithDuration:self.animationDuration
		                      delay:0
		                    options:UIViewAnimationOptionBeginFromCurrentState
		                 animations: ^{
                             if (self.contentView != nil) {
                                 self.contentView.frame = sideBarFrame;
                             }
                             self.translucentView.frame = sideBarFrame;
                         }
         
		                 completion:completion];
	}
	else {
		completion(YES);
	}
}

#pragma mark - Gesture Handler
- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
	CGPoint location = [recognizer locationInView:self.view];
	if (!CGRectContainsPoint(self.translucentView.frame, location)) {
		[self dismissAnimated:YES];
	}
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
	if (!self.isCurrentPanGestureTarget) {
		return;
	}
    
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		self.panStartPoint = [recognizer locationInView:self.view];
	}
    
	if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGPoint currentPoint = [recognizer locationInView:self.view];
		if (!self.showSideBarFromRight) {
			[self move:self.sideBarWidth + currentPoint.x - self.panStartPoint.x];
		}
		else {
			[self move:self.sideBarWidth + self.panStartPoint.x - currentPoint.x];
		}
	}
    
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		CGPoint endPoint = [recognizer locationInView:self.view];
        
		if (!self.showSideBarFromRight) {
			if (self.panStartPoint.x - endPoint.x < self.sideBarWidth / 3) {
				[self showAnimatedFrom:YES deltaX:endPoint.x - self.panStartPoint.x];
			}
			else {
				[self dismissAnimated:YES deltaX:endPoint.x - self.panStartPoint.x];
			}
		}
		else {
			if (self.panStartPoint.x - endPoint.x >= self.sideBarWidth / 3) {
				[self showAnimatedFrom:YES deltaX:self.panStartPoint.x - endPoint.x];
			}
			else {
				[self dismissAnimated:YES deltaX:self.panStartPoint.x - endPoint.x];
			}
		}
	}
}

- (void)handlePanGestureToShow:(UIPanGestureRecognizer *)recognizer
                        inView:(UIView *)parentView {
	if (!self.isCurrentPanGestureTarget) {
		return;
	}
    
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		self.panStartPoint = [recognizer locationInView:parentView];
		[self startShow:self.panStartPoint.x];
	}
    
	if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGPoint currentPoint = [recognizer locationInView:parentView];
		if (!self.showSideBarFromRight) {
			[self move:currentPoint.x - self.panStartPoint.x];
		}
		else {
			[self move:self.panStartPoint.x - currentPoint.x];
		}
	}
    
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		CGPoint endPoint = [recognizer locationInView:parentView];
        
		if (!self.showSideBarFromRight) {
			if (endPoint.x - self.panStartPoint.x >= self.sideBarWidth / 3) {
				[self showAnimatedFrom:YES deltaX:endPoint.x - self.panStartPoint.x];
			}
			else {
				[self dismissAnimated:YES deltaX:endPoint.x - self.panStartPoint.x];
			}
		}
		else {
			if (self.panStartPoint.x - endPoint.x >= self.sideBarWidth / 3) {
				[self showAnimatedFrom:YES deltaX:self.panStartPoint.x - endPoint.x];
			}
			else {
				[self dismissAnimated:YES deltaX:self.panStartPoint.x - endPoint.x];
			}
		}
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if (touch.view != gestureRecognizer.view) {
		return NO;
	}
	return YES;
}

#pragma mark - ContentView
- (void)setContentViewInSideBar:(UIView *)contentView {
	if (self.contentView != nil) {
		[self.contentView removeFromSuperview];
	}
    
	self.contentView = contentView;
	//self.contentView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:self.contentView];
}


//HS added 25Oct
- (void)removeContentViewInSideBar:(UIView *)contentView {
	if (self.contentView != nil) {
		[self.contentView removeFromSuperview];
	}
    
	//self.contentView = contentView;
	//self.contentView.backgroundColor = [UIColor clearColor];
	//[self.view addSubview:self.contentView];
}
//HS 25 Oct ends here
#pragma mark - Helper methods
- (void)addToParentViewController:(UIViewController *)parentViewController
         callingAppearanceMethods:(BOOL)callAppearanceMethods {
	if (self.parentViewController != nil) {
		[self removeFromParentViewControllerCallingAppearanceMethods:callAppearanceMethods];
	}
    
	if (callAppearanceMethods) [self beginAppearanceTransition:YES animated:NO];
	[parentViewController addChildViewController:self];
	[parentViewController.view addSubview:self.view];
	[self didMoveToParentViewController:self];
	if (callAppearanceMethods) [self endAppearanceTransition];
}

- (void)removeFromParentViewControllerCallingAppearanceMethods:(BOOL)callAppearanceMethods {
	if (callAppearanceMethods) [self beginAppearanceTransition:NO animated:NO];
	[self willMoveToParentViewController:nil];
	[self.view removeFromSuperview];
	[self removeFromParentViewController];
	if (callAppearanceMethods) [self endAppearanceTransition];
}

@end
