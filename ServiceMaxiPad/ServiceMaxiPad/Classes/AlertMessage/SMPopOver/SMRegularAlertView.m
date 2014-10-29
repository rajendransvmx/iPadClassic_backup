//
//  SMRegularAlertView.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 17/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SMRegularAlertView.h"
#import "SMAppDelegate.h"


@interface SMRegularAlertView()
{
    
}

@property(nonatomic, assign) float labelHeight;

@end

@implementation SMRegularAlertView

@synthesize labelHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
           delegate:(id<SMAlertViewDelegate>)alertViewDelegate
           messages:(NSArray *)messages
       cancelButton:(NSString *)cancelButtonTitle
        otherButton:(NSString *)otherButtonTitle
{
    if (self)
    {
        self = [self initWithTitle:title
                          delegate:alertViewDelegate
                 cancelButtonTitle:cancelButtonTitle
                  otherButtonTitle:otherButtonTitle];
        
        [self drawBorder];

        if ([messages count] > 0)
        {
            [self drawMessage:messages];
        }
        
        [self heightAdjustments];

        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        self.alertViewContainer.center = self.center;
        self.alertViewContainer.backgroundColor = [UIColor whiteColor];
        
        [self.alertViewContainer setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
        
        SMAppDelegate *delegate = (SMAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate addSubviewToRootController:self];
       
    }
    return  self;
}


- (void)drawMessage:(NSArray *)messages
{
    height = height + 25.0f;
    labelHeight = 0.0;
    
    for (int i = 0; i < [messages count]; i++)
    {
        if([messages count]==1)
        {
            labelHeight=labelHeight+20;
        }

        UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(5.0, height, width-10.0, 50.0)];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizesSubviews = YES;
        label.numberOfLines = 0;
        label.text = [messages objectAtIndex:i];
        
        label.font = [UIFont fontWithName:kHelveticaNeueMedium  size:kFontSize16];
        [label setTextColor:[UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1]];
        [label setTextColor:[UIColor colorWithRed:51.0/255.0f green:51.0f/255.0f blue:51.0/255.0f alpha:1.0]];
        [label sizeToFit];
         label.center = CGPointMake(width/2, height+(label.frame.size.height/2));
        
        height = height + label.frame.size.height + 20.0;
        [self.alertViewContainer addSubview:label];
        
        if ( i == ([messages count] - 1 ))
        {
            labelHeight = labelHeight + label.frame.size.height;
        }
        else
        {
             labelHeight = labelHeight + label.frame.size.height + 23.0;
        }
        label = nil;
    }
}


- (void)drawBorder
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, height, width, 1.0)];
    label.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColor];
    [self.alertViewContainer addSubview:label];
    label = nil;
}


- (void)heightAdjustments
{
    CGRect frame = self.alertViewContainer.frame;
    frame.size.height = frame.size.height+labelHeight;
    self.alertViewContainer.frame = frame;
    
    frame = self.cancelButton.frame;
    frame.origin.y = frame.origin.y + labelHeight;
    self.cancelButton.frame = frame;
    
    frame = self.otherButton.frame;
    frame.origin.y = frame.origin.y + labelHeight;
    self.otherButton.frame = frame;
}

@end
