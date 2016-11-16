//
//  SMAlertView.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 16/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SMAlertView.h"
#import "StyleManager.h"



#define ButtonHeight 40
#define ButtonWidth 110

@interface SMAlertView()
{
}

@end

@implementation SMAlertView

@synthesize titleLabel;
@synthesize cancelButton;
@synthesize otherButton;
@synthesize alertViewContainer;
@synthesize alertDelegate;

- (id)initWithTitle:(NSString*)title
           delegate:(id<SMAlertViewDelegate>)alertViewDelegate
  cancelButtonTitle:(NSString*)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle
{
    CGRect frame;
    
    frame = [[UIScreen mainScreen] bounds];
    if (frame.size.width != [UIApplication sharedApplication].statusBarFrame.size.width) {
        frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
    }
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.alertDelegate = alertViewDelegate;
        self.alertViewContainer = [[UIView alloc]init];
        [self populateViewTitle:title cancelButtonTitle:cancelButtonTitle andOtherButton:otherButtonTitle];
        
        [self addMask];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentMode = UIViewContentModeScaleToFill;
        self.translatesAutoresizingMaskIntoConstraints = YES;
        
    }
    return  self;
}

- (void)populateViewTitle:(NSString *)aTitle
        cancelButtonTitle:(NSString *)cancelButtonTitle
           andOtherButton:(NSString *)buttonTitle
{
    height = 0.0;
    width  = 370.0;
    
    if (aTitle != nil)
    {
        [self drawTitle:aTitle];
    }
    
    if (   (cancelButtonTitle != nil)
        | (buttonTitle != nil) )
    {
        [self drawCancelButtonAndOtherButton:cancelButtonTitle otherButtonTitle:buttonTitle];
    }
    
    self.alertViewContainer.frame = CGRectMake(self.frame.origin.x/2,
                                               self.frame.origin.y/2,
                                               width,
                                               height);
    
    self.alertViewContainer.backgroundColor = [UIColor redColor];
    self.alertViewContainer.layer.cornerRadius = 3;
    self.alertViewContainer.layer.borderWidth = 0.01;
    [self addSubview:self.alertViewContainer];
    
    //self.backgroundColor = [UIColor clearColor];
    //self.backgroundColor = [UIColor colorWithRed:166.0f/255 green:166.0f/255 blue:166.0f/255 alpha:0.4f];
    self.backgroundColor = [UIColor colorWithWhite:.1f alpha:0.3f];
    height = titleLabel.frame.size.height;
}


- (void)drawTitle:(NSString *)title
{
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0, height, width, 40.0)];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font =[UIFont fontWithName:kHelveticaNeueMedium
                                     size:kFontSize18];
    
    [titleLabel setTextColor:[UIColor colorWithRed:61.0f/255 green:61.0f/255 blue:61.0f/255 alpha:1]];
    titleLabel.backgroundColor = [UIColor colorWithRed:239.0f/255 green:239.0f/255 blue:239.0f/255 alpha:1];
    titleLabel.backgroundColor = [UIColor colorFromHexString:kPageViewMasterBGColor];
    titleLabel.layer.cornerRadius = 4;
    height = height + 35 + 45 +10.0f;
    [self.alertViewContainer addSubview:titleLabel];
}


- (void)drawCancelButtonAndOtherButton:(NSString*)cancelButtonTitle otherButtonTitle:(NSString*)otherButtonTitle
{
    if (cancelButtonTitle != nil)
    {
        cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(10, height, ButtonWidth, ButtonHeight)];
        [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        cancelButton.tag = 1000;
        cancelButton.layer.borderWidth = 1;
        cancelButton.layer.borderColor = [UIColor orangeColor].CGColor;
        cancelButton.layer.borderColor = [UIColor colorFromHexString:kOrangeColor].CGColor;
        
        cancelButton.titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize15];
        
        [cancelButton setBackgroundColor:[UIColor clearColor]];
        [cancelButton setTitleColor:[UIColor colorFromHexString:kOrangeColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.backgroundColor = [UIColor whiteColor];
    }
    
    if(otherButtonTitle!=nil)
    {
        otherButton = [[UIButton alloc]init];
        otherButton.frame = CGRectMake(width-ButtonWidth-10, height, ButtonWidth, ButtonHeight);
        [otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
        otherButton.tag=1001;
        [otherButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        otherButton.layer.borderWidth = 0;
        
        otherButton.titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize15];
        
        otherButton.layer.borderColor = [UIColor whiteColor].CGColor;
        otherButton.backgroundColor = [UIColor colorFromHexString:kOrangeColor];
        [otherButton addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self setFrameForButtonsCancelButton:cancelButtonTitle otherButton:otherButtonTitle];
}


- (void)onButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger buttonIndex = button.tag - 1000;
    
    if( (self.alertDelegate != nil)
       && ([self.alertDelegate respondsToSelector:@selector(smAlertView:clickedButtonAtIndex:)]))
    {
        [self.alertDelegate smAlertView:self  clickedButtonAtIndex:buttonIndex];
    }
}


- (void)addMask
{
    self.alertViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.alertViewContainer.layer.shadowOffset = CGSizeMake(3, 4);
    self.alertViewContainer.layer.shadowRadius = 4.0f;
    self.alertViewContainer.layer.shadowOpacity = 0.60f;
}


- (void)setFrameForButtonsCancelButton:(NSString *)cancelButtonTitle otherButton:(NSString *)otherButtonTitle
{
    self.cancelButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.otherButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    if (   (cancelButtonTitle != nil)
        && (otherButtonTitle != nil) )
    {
        [self.alertViewContainer addSubview:cancelButton];
        [self.alertViewContainer addSubview:otherButton];
        height = height + cancelButton.frame.size.height + 10.0;
    }
    else
    {
        if (cancelButtonTitle != nil)
        {
            cancelButton.frame = CGRectMake(130, height, ButtonWidth, ButtonHeight);
            [self.alertViewContainer addSubview:cancelButton];
            height = height + cancelButton.frame.size.height + 10.0;
        }
        else if(otherButtonTitle != nil)
        {
            otherButton.frame = CGRectMake(130, height, ButtonWidth, ButtonHeight);
            [self.alertViewContainer addSubview:otherButton];
            height = height + otherButton.frame.size.height + 10.0;
        }
    }
}

@end
