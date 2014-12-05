//
//  SMCheckBoxBindedAlertView.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 18/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SMCheckBoxBindedAlertView.h"
#import "SMAppDelegate.h"
#import "AppManager.h"


@interface SMCheckBoxBindedAlertView()

@property(nonatomic, strong) NSArray *keyArray;

@end

@implementation SMCheckBoxBindedAlertView

@synthesize keyArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
           delegate:(id<SMAlertViewDelegate>)alertViewDelegate
           messages:(NSArray *)messages
   checkBoxMessages:(NSDictionary *)checkBoxMessages
       cancelButton:(NSString *)cancelButtonTitle
        otherButton:(NSString *)otherButtonTitle
{
    if (self)
    {
        self = [super initWithTitle:title
                           delegate:alertViewDelegate
                  cancelButtonTitle:cancelButtonTitle
                   otherButtonTitle:otherButtonTitle];
        
        [self drawBorder];
        
        if ([messages count] > 0)
        {
            [self drawMessages:messages];
        }
        
        if ([checkBoxMessages count] > 0)
        {
            [self drawCheckBoxesForTheMessages:checkBoxMessages];
        }
        
        [self heightAdjustments];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.alertViewContainer.center = self.center;
        self.alertViewContainer.backgroundColor = [UIColor whiteColor];
       
        [self.alertViewContainer setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
        
        SMAppDelegate *delegate = (SMAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate addSubviewToRootController:self];
    }
    return  self;
}


- (void)drawMessages:(NSArray *)messages
{
    height = height + 25.0f;
    labelHeight = 0.0;
    for (int i = 0; i < [messages count]; i++)
    {
        if([messages count]==1)
        {
            labelHeight=labelHeight+20;
        }
        float heightOfMessage =  [self getHeightForCellWithText:[messages objectAtIndex:i] WitheTheWidTh:width - 20.0f];
        UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(10.0f, height, width-20.0f, heightOfMessage)];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizesSubviews = YES;
        label.numberOfLines = 0;
        label.text = [messages objectAtIndex:i];
        label.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize15];
        [label setTextColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0f alpha:1.0f]];
         label.center = CGPointMake(width/2, height+(label.frame.size.height/2));
        
        height = height + label.frame.size.height + 14.0f;
        [self.alertViewContainer addSubview:label];
        if ( i == ([messages count] - 1))
        {
            labelHeight = labelHeight + label.frame.size.height;
        }
        else
        {
            labelHeight = labelHeight + label.frame.size.height + 23.0f + 5.0f;
        }
        label = nil;
    }
}

- (void)drawBorder
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0, height, width, 2.0)];
    label.backgroundColor=[UIColor colorWithHexString:kSeperatorLineColor];
    [self.alertViewContainer addSubview:label];
    label = nil;
}

- (void)heightAdjustments
{
    CGRect frame = self.alertViewContainer.frame;
    frame.size.height = frame.size.height + labelHeight;
    self.alertViewContainer.frame = frame;
    
    frame = self.cancelButton.frame;
    frame.origin.y = frame.origin.y + labelHeight;
    self.cancelButton.frame = frame;
    
    frame = self.otherButton.frame;
    frame.origin.y = frame.origin.y + labelHeight;
    self.otherButton.frame = frame;

}

- (void)drawCheckBoxesForTheMessages:(NSDictionary *)messages
{
    self.keyArray = [messages allKeys];
    height = height + 18.0f;
    labelHeight = labelHeight + 18.0f;
    
    for (int i = 0; i < [keyArray count]; i++)
    {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10.0, height, 20.0, 20.0)];
        button.layer.cornerRadius = 2;
        button.tag = i;
       [button addTarget:self action:@selector(setCheckMark:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([[messages objectForKey:[keyArray objectAtIndex:i]] integerValue] == 1)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"checkbox-active-checked.png"]
                              forState:UIControlStateNormal];
            button.selected = YES;
        }
        else
        {
            [button setBackgroundImage:[UIImage imageNamed:@"checkbox-active-unchecked.png"]
                              forState:UIControlStateNormal];
            button.selected = NO;
        }
        float heightOfMessage = [self getHeightForCellWithText:[keyArray objectAtIndex:i] WitheTheWidTh:width - 45.0f];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(40.0, height, width - 45.0f, heightOfMessage)];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentLeft;
        label.autoresizesSubviews = YES;
        label.numberOfLines = 0;
        label.text = [keyArray objectAtIndex:i];
        label.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize15];
        [label setTextColor:[UIColor colorWithRed:51.0f/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f]];
        height = height + label.frame.size.height + 10.0;
        [self.alertViewContainer addSubview:button];
        [self.alertViewContainer addSubview:label];
       
        
        if (i == ([messages count] - 1) )
        {
            labelHeight = labelHeight + label.frame.size.height;
        }
        else
        {
            labelHeight = labelHeight + label.frame.size.height + 10.0;
        }
        label = nil;
        button = nil;
    }
    labelHeight = labelHeight + 10.0;
}

- (void)setCheckMark:(UIButton*)sender
{
    id <CheckBoxDelegate> delegate =  self.alertDelegate;
    NSInteger index = sender.tag;
    UIButton *button = sender;
    if(button .selected == YES)
   
    {
        [button setBackgroundImage:[UIImage imageNamed:@"checkbox-active-unchecked.png"]
                          forState:UIControlStateNormal];
        button.selected = NO;
         [delegate  checkBoxValueChanged:NO forKey:[self.keyArray objectAtIndex:index]];
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"checkbox-active-checked.png"]
                          forState:UIControlStateNormal];
        button.selected = YES;
        [delegate checkBoxValueChanged:YES forKey:[self.keyArray objectAtIndex:index]];
    }
}

- (CGFloat)getHeightForCellWithText:(NSString *)pText WitheTheWidTh:(float)widthOfLabel
{
    CGSize constraintSize = CGSizeMake(widthOfLabel, MAXFLOAT);
    CGRect textRect = [pText boundingRectWithSize:constraintSize
                                          options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kFontSize15]}
                                          context:nil];

    return (ceilf(textRect.size.height));
}


@end
