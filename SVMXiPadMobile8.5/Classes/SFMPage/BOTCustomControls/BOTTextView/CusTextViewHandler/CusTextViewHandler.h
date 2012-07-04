//
//  CusTextViewHandler.h
//  CustomClassesipad
//
//  Created by Developer on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CusTextViewHandlerDelegate;

@interface CusTextViewHandler : NSObject <UITextViewDelegate>
{
    id <CusTextViewHandlerDelegate> delegate;
    UIPopoverController * POP;
    UIView * popOverView;
    NSString * lableValue;
}

@property (nonatomic ,assign)  id <CusTextViewHandlerDelegate> delegate;
@property (nonatomic , retain) UIView *popOverView;
@property (nonatomic ,retain) UIPopoverController * POP;
@property (nonatomic , assign) NSString * lableValue;
@end

@protocol CusTextViewHandlerDelegate <NSObject>
@optional
-(void) didChangeText:(NSString *)text;

@end