//
//  TPTextFieldHandler.h
//  CustomClassesipad
//
//  Created by Developer on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimePickerView.h"

@protocol setTimePicker;

@interface TPTextFieldHandler : NSObject <UITextFieldDelegate,TimePickerClassDelegate> 
{
    id delegate;
    TimePickerView * timePicker;
    UIPopoverController * timePickerPopOver;
    CGRect pickerFrame;
    UIView * superView;
    id <setTimePicker> classdelegate;

}
@property(nonatomic,assign)id delegate;
@property(nonatomic,assign)id <setTimePicker> classdelegate;
@property (nonatomic,retain)TimePickerView * timePicker;
@property (nonatomic,retain)UIPopoverController *timePickerPopOver;
@property (nonatomic) CGRect pickerFrame;
@property (nonatomic,retain) UIView * superView;
-(void) tapTimePicker:(id)sender;

@end



@protocol setTimePicker<NSObject>

@optional
-(void)setTimePickertoTextFielddate;

@end