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

        UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(5.0, height, width-10.0, 50.0f)];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizesSubviews = YES;
        label.numberOfLines = 0;
        label.text = [messages objectAtIndex:i];
        //label.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:kFontSize14];
        label.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize15];
        [label setTextColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0f alpha:1.0f]];
        [label sizeToFit];
         label.center = CGPointMake(width/2, height+(label.frame.size.height/2));
        
        height = height + label.frame.size.height + 14.0f;
        [self.alertViewContainer addSubview:label];
        if ( i == ([messages count] - 1))
        {
            labelHeight = labelHeight + label.frame.size.height;
        }
        else
        {
            labelHeight = labelHeight + label.frame.size.height + 20.0f;
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
        }
        else
        {
            [button setBackgroundImage:[UIImage imageNamed:@"checkbox-active-unchecked.png"]
                              forState:UIControlStateNormal];
        }
        
        UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(40.0, height, width-45.0f, 50.0f)];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizesSubviews = YES;
        label.numberOfLines = 0;
        label.text = [keyArray objectAtIndex:i];
        //label.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:kFontSize14];
        label.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize15];
        [label setTextColor:[UIColor colorWithRed:51.0f/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f]];
        [label sizeToFit];
        
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
    NSInteger index = sender.tag;
  
   id <CheckBoxDelegate> delegate =  self.alertDelegate;
    
    if ([sender backgroundImageForState:UIControlStateNormal] == [UIImage imageNamed:@"checkbox-active-checked.png"])
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"checkbox-active-unchecked.png"]
                          forState:UIControlStateNormal];
        
        if ([delegate respondsToSelector:@selector(checkBoxValueChanged:forKey:)])
        {
            [delegate  checkBoxValueChanged:NO forKey:[self.keyArray objectAtIndex:index]];
        }
    }
    else
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"checkbox-active-checked.png"]
                          forState:UIControlStateNormal];
        if([delegate respondsToSelector:@selector(checkBoxValueChanged:forKey:)])
        {
            [delegate checkBoxValueChanged:YES forKey:[self.keyArray objectAtIndex:index]];
        }
    }
}

@end
