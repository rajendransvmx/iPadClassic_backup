//
//  AlhaTextHandler.h
//  CustomClassesipad
//
//  Created by Developer on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlphaContentView.h"

@protocol AlhaTextHandlerDelegate;

@interface AlhaTextHandler : NSObject <UITextFieldDelegate,releasetextFieldAlphaPO> 
{
    id <AlhaTextHandlerDelegate> delegate;
    UIPopoverController * POC;
    AlphaContentView * alphaContent;
    UIView * popOverView;
    CGRect rect;
    NSString * control_type;
    BOOL isInViewMode;
}

@property (nonatomic, assign) id <AlhaTextHandlerDelegate> delegate;
@property (nonatomic, retain) UIView * popOverView;
@property (nonatomic) CGRect rect;
@property (nonatomic, retain) AlphaContentView * alphaContent;
@property (nonatomic, retain) UIPopoverController * POC;
@property (nonatomic, assign) NSString * control_type;
@property (nonatomic) BOOL isInViewMode;

@end

@protocol AlhaTextHandlerDelegate <NSObject>

@optional
-(void) didChangeText:(NSString *)text;

@end
