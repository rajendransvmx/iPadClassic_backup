//
//  SMProgressAlertView.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 17/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SMProgressAlertView.h"
#import "SMAppDelegate.h"

@implementation SMProgressAlertView

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
           delegate:(id)alertViewDelegate
           messages:(NSArray *)messages
       cancelButton:(NSString *)cancelButtonTitle
        otherButton:(NSString *)otherButtonTitle
{
    self = [self initWithTitle:title
                      delegate:alertViewDelegate
             cancelButtonTitle:cancelButtonTitle
              otherButtonTitle:otherButtonTitle];
    
    [self progressBar];
    
    if ([messages count] > 0)
    {
        [self drawMessages:messages];
    }
    
   [self heightAdjustments];
    
    self.alertViewContainer.center = self.center;
    self.alertViewContainer.backgroundColor = [UIColor whiteColor];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.alertViewContainer.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin
                                                | UIViewAutoresizingFlexibleRightMargin
                                                | UIViewAutoresizingFlexibleBottomMargin
                                                | UIViewAutoresizingFlexibleTopMargin;
    
    SMAppDelegate *delegate = (SMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate addSubviewToRootController:self];
    
    return  self;
}


- (void)progressBar
{
    heightToAdjust = 0.0f;
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0.0, height, width, 2.0f)];
    progressView.progressViewStyle = UIProgressViewStyleDefault;
    height = height + 6.0;
    
    progresStatus = [[UILabel alloc] initWithFrame:CGRectMake(5.0, height, width - 5.0, 21.0f)];
    progresStatus.text = @"";
    progresStatus.backgroundColor = [UIColor whiteColor];
    progresStatus.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize14];
    progresStatus.textColor = [UIColor lightGrayColor];
    height = height + 20.0f + 21.0f;
    heightToAdjust = progressView.frame.size.height+progresStatus.frame.size.height;

    [self.alertViewContainer addSubview:progressView];
    [self.alertViewContainer addSubview:progresStatus];
}


- (void)drawMessages:(NSArray *)messages
{
    for (int i = 0; i < [messages count]; i++)
    {
        if([messages count] == 1)
        {
            heightToAdjust = heightToAdjust+20;
        }
        float messageHeight = [self getHeightForCellWithText:[messages objectAtIndex:i]];
        
        UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(10.0f, height, width - 20.0f, messageHeight)];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizesSubviews = YES;
        label.numberOfLines = 0.0f;
        label.text = [messages objectAtIndex:i];
        label.font= [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize15];
        [label setTextColor:[UIColor colorWithRed:51.0/255.0f green:51.0f/255.0f blue:51.0/255.0f alpha:1.0]];
        label.textAlignment = NSTextAlignmentCenter;
        label.center = CGPointMake(width/2, height+(label.frame.size.height/2));
        height = height + label.frame.size.height + 20.0f;
        
        if (i == ([messages count] - 1))
        {
            heightToAdjust = heightToAdjust + label.frame.size.height +10;
        }
        else
        {
            heightToAdjust = heightToAdjust + label.frame.size.height + 23.0f + 5.0f;
        }

        [self.alertViewContainer addSubview:label];
        
        label = nil;
    }
}

- (void)heightAdjustments
{
    CGRect frame = self.alertViewContainer.frame;
    frame.size.height = frame.size.height + heightToAdjust;
    self.alertViewContainer.frame = frame;
    
    frame = self.cancelButton.frame;
    frame.origin.y = frame.origin.y + heightToAdjust;
    self.cancelButton.frame = frame;
    
    frame = self.otherButton.frame;
    frame.origin.y = frame.origin.y + heightToAdjust;
    self.otherButton.frame = frame;

}

 
- (void)updateProgressBarWithValue:(float)value andMessage:(NSString *)message
{
    progresStatus.text = message;
    progressView.progress = value;
}

- (CGFloat)getHeightForCellWithText:(NSString *)pText
{
    CGSize constraintSize = CGSizeMake( width - 20.0f, MAXFLOAT);
    CGRect textRect = [pText boundingRectWithSize:constraintSize
                                          options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kFontSize15]}
                                          context:nil];
    return (ceilf(textRect.size.height));
}


@end
