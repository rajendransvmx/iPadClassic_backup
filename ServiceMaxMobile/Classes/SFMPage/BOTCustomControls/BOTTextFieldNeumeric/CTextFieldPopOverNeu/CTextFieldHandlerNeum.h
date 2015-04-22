//
//  CTextFieldHandlerNeum.h
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CTextFieldHandlerNumDelegate;

@interface CTextFieldHandlerNum : NSObject <UITextFieldDelegate>
{
    id <CTextFieldHandlerNumDelegate> delegate;
    UIPopoverController * POC;
    UIView * PopOverView;
    CGRect rect;
    NSInteger valuel;
    NSString * lableValue;
    NSString * control_type;
    NSInteger percent_count;
    BOOL countflag;
    
}

@property (nonatomic , assign) id<CTextFieldHandlerNumDelegate> delegate;
@property (nonatomic) BOOL countflag; 
@property (nonatomic) NSInteger percent_count;
@property (nonatomic , retain) NSString *control_type;
@property (nonatomic , assign) NSString * lableValue;
@property (nonatomic , retain) UIPopoverController *POC;
@property (nonatomic , retain)  UIView * PopOverView;
@property (nonatomic ) CGRect rect;
@end

@protocol CTextFieldHandlerNumDelegate <NSObject>

@optional
-(void) didChangeText:(NSString *)text;

@end
