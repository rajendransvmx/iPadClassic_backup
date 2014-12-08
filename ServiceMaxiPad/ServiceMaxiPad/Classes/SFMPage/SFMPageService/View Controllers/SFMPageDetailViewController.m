//
//  SFMPageDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Aparna on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageDetailViewController.h"
#import "SMSplitViewController.h"
#import "StringUtil.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "PlistManager.h"

@interface SFMPageDetailViewController ()

@property (retain, nonatomic) IBOutlet UIButton *selectedSectionButton;
@property(nonatomic, retain) SMSplitPopover *masterPopoverController;
@property(nonatomic, assign) CGRect childViewFrame;
@property (nonatomic, strong) UIPopoverController * descPopOver;
@end

@implementation SFMPageDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       _pageDetailChildViewController = [[UIViewController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Add dummy view controller for the first time*/
    [self addChildViewController:self.pageDetailChildViewController];
    [self.view addSubview:self.pageDetailChildViewController.view];
    [self.pageDetailChildViewController didMoveToParentViewController:self];
    
    [self addBottomBorder];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
}

-(void) addBottomBorder
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, CGRectGetHeight(self.selectedSectionButton.bounds)-1, CGRectGetWidth(self.selectedSectionButton.bounds), 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColor].CGColor;
    [self.selectedSectionButton.layer addSublayer:bottomBorder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SMSplitViewControllerDelegate Methods

-(void)splitViewController:(SMSplitViewController *)splitViewController didHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover
{
    //Portrait
    self.selectedSectionButton.hidden = NO;
    
    [self presentFirstTimeDetailDescription];

    [self.selectedSectionButton addTarget:barButtonItem.target action:barButtonItem.action forControlEvents:UIControlEventTouchUpInside];
    
    CGRect viewFrame = splitViewController.detailViewController.view.bounds;
    viewFrame.origin.y=44;
    viewFrame.size.height-= 44;
    self.pageDetailChildViewController.view.frame = viewFrame;
    self.childViewFrame = viewFrame;
    
    self.masterPopoverController = popover;

}


- (void)splitViewController:(SMSplitViewController *)splitViewController didShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem{
    
    //Landscape
    self.selectedSectionButton.hidden = YES;
    
    CGRect viewFrame = splitViewController.detailViewController.view.bounds;
    viewFrame.origin.y=0;
    self.pageDetailChildViewController.view.frame = viewFrame;
    self.childViewFrame = viewFrame;
    
    self.masterPopoverController = nil;
    [self.descPopOver dismissPopoverAnimated:NO];
    

}


- (void)setContentWithItem:(id)item
{
    [self.selectedSectionButton setTitle:[item description] forState:UIControlStateNormal];
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
}

- (void)setPageDetailChildViewController:(UIViewController *)childViewController
{
    UIViewController *currentViewController = self.pageDetailChildViewController;
    UIViewController *newViewController = childViewController;
    if (newViewController != nil) {
        newViewController.view.frame = self.childViewFrame;
        
        [currentViewController willMoveToParentViewController:nil];
        [self addChildViewController:newViewController];
        [self transitionFromViewController:currentViewController toViewController:newViewController duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
            [currentViewController removeFromParentViewController];
            [newViewController didMoveToParentViewController:self];
        }];
        _pageDetailChildViewController = newViewController;
    }
}

-(void)presentFirstTimeDetailDescription{
    
    //check for first time login
        BOOL firstTimeLogin = [PlistManager isFirstTimeLogin];
        ;
        if(firstTimeLogin){
            [self presentDetailDescriptionPopOver];
        }
}



-(void)presentDetailDescriptionPopOver
{
    UIViewController * vc = [[UIViewController alloc] init];
    if(self.descPopOver == nil){
        self.descPopOver = [[UIPopoverController alloc] initWithContentViewController:vc];

    }
    
    CGSize popOverContentSize ;
    
    popOverContentSize.width = 202;
    popOverContentSize.height = 81;
    
    vc.view.frame = CGRectZero;
    vc.view.backgroundColor = [UIColor clearColor];
    
    self.descPopOver.popoverContentSize = CGSizeMake(202, 81);
    
    
    UITextView * textView  = [[UITextView alloc] initWithFrame:CGRectZero];
    CGRect textViewframe ;
    textViewframe.origin.x = CGRectGetMinX(  vc.view.bounds) + 10;
    textViewframe.origin.y =  CGRectGetMinY(  vc.view.bounds) + 10;
    textViewframe.size.height = 81 -10;
    textViewframe.size.width = 202 - 10;

    textView.backgroundColor = [UIColor clearColor];
    
    NSString * tapHere = @"Tap Here\n";
    NSString * afterTapHere  = [[NSString alloc] initWithFormat:@"To see a list of  %@ sections.",@"Work Order"];
    
    NSMutableAttributedString * firstPart = [[NSMutableAttributedString alloc] initWithString:tapHere];
    [firstPart addAttribute:NSFontAttributeName value:[UIFont fontWithName:kHelveticaNeueMedium size:16.0] range:NSMakeRange(0, [tapHere length])];

    
    NSMutableAttributedString * secondPart = [[NSMutableAttributedString alloc] initWithString:afterTapHere];
    
    [secondPart addAttribute:NSFontAttributeName value:[UIFont fontWithName:kHelveticaNeueLight size:16.0] range:NSMakeRange(0, [afterTapHere length])];
    
    
  
    NSMutableAttributedString * descAttStr = [[NSMutableAttributedString alloc] init];
    
    [descAttStr appendAttributedString:firstPart];
    
    [descAttStr appendAttributedString:secondPart];
    
    
    textView.attributedText = descAttStr;
    textView.frame = textViewframe;
    textView.delegate = self;
    [vc.view addSubview:textView];
    
    
    CGRect buttonframe = self.selectedSectionButton.bounds;
    buttonframe.size.width =  (buttonframe.size.width *1)/8;
    buttonframe.origin.y = CGRectGetHeight(buttonframe)/2 +10;

    if (!self.selectedSectionButton.isHidden) {
        [self.descPopOver presentPopoverFromRect:buttonframe inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}


-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    

}

- (void)refreshSFmPageData:(SFMPageViewModel*)pageViewModel
{
    id pageLayOutViewController = self.pageDetailChildViewController;
    if ([pageLayOutViewController respondsToSelector:@selector(resetViewPage:)]) {
        [pageLayOutViewController resetViewPage:pageViewModel];
    }
}

@end
