//
//  CTextFieldHandlerNeum.h
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LookupView.h"

@class iServiceAppDelegate;

@protocol LookupFieldPopoverDelegate;

@interface LookupFieldPopover : NSObject <UITextFieldDelegate, LookupViewDelegate, UIPopoverControllerDelegate>
{
    id <LookupFieldPopoverDelegate> lookupDelegate;
    iServiceAppDelegate * appDelegate;

    UIPopoverController * POC;
    CGRect rect;
    NSInteger value;
    NSString * lableValue;
    UIView * POView;
    LookupView * lookupView;
    
    UIPopoverController * popOver;
    
    //shrinivas
    NSString *searchId;
    NSString *relatedObjectName;
}

@property (nonatomic, assign) id <LookupFieldPopoverDelegate> lookupDelegate;
@property (nonatomic, retain) UIView * POView;
@property (nonatomic, assign) NSString * lableValue;
@property (nonatomic, retain) UIPopoverController * POC;
@property (nonatomic, retain)  UIView * PopOverView;
@property (nonatomic) CGRect rect;

@property (nonatomic, retain) NSString *searchId;
@property (nonatomic, retain) NSString *relatedObjectName;

@end

@protocol LookupFieldPopoverDelegate <NSObject>

@optional
//sahana 23rd sept 2011
- (void) didSelectObject:(NSArray *)lookupObject defaultDisplayColumn:(NSString *)defaultdisplayColumn;

@end
