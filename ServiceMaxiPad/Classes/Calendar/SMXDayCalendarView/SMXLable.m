//
//  SMXLable.m
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 10/17/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMXLable.h"
#import "SFMPageFieldCollectionViewCell.h"
#import "MorePopOverViewController.h"
#import "StyleManager.h"
#import "TagManager.h"
#import "PushNotificationHeaders.h"

@implementation SMXLable
@synthesize  moreButton;
@synthesize popOver;
@synthesize headerText;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
        [self registerForPopOverDismissNotification];
    }
    return self;
}
-(void)checkString{
    
    CGSize size = [self.text sizeWithAttributes:
                   @{NSFontAttributeName:self.font}];
    
    if (size.width > self.bounds.size.width) {
        self.userInteractionEnabled=YES;
        [self openText];
    }
}

-(void)openText{
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(self.frame.size.width-130,0,130,self.frame.size.height);
    moreButton.backgroundColor=[UIColor clearColor];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"fadeout.png"] forState:UIControlStateNormal];
    [moreButton setTitle:[[TagManager sharedInstance]tagByName:kTagmore] forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateNormal];
    moreButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    [moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.titleLabel.textAlignment = NSTextAlignmentRight;
    moreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self addSubview:moreButton];
}

- (void)moreButtonClicked:(id)sender
{
    MorePopOverViewController *morePopoverController = [[MorePopOverViewController alloc]init];
    self.popOver = [[UIPopoverController alloc] initWithContentViewController:morePopoverController];
    [self.popOver presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    morePopoverController.fieldNameLabel.text = self.headerText;
    morePopoverController.fieldValueTextView.text = self.text;
}
-(void)showDayLeftPanel{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)registerForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissPopover)
                                                 name:POP_OVER_DISMISS
                                               object:nil];
}

-(void)deregisterForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POP_OVER_DISMISS object:nil];
}

- (void)dismissPopover
{
    [self performSelectorOnMainThread:@selector(dismissPopoverIfNeeded) withObject:self waitUntilDone:YES];
}


- (void)dismissPopoverIfNeeded
{
    if ([self.popOver isPopoverVisible] &&
        self.popOver) {
        
        [self.popOver dismissPopoverAnimated:YES];
        self.popOver = nil;
    }
}

-(void)dealloc
{
    [self deregisterForPopOverDismissNotification];
}

@end
