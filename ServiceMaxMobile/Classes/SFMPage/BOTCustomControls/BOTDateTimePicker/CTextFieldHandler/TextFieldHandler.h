//
//  TextFieldHandler.h
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DatePickerClass.h"
@protocol setDatePickerDate;


@interface TextFieldHandler : NSObject
<UITextFieldDelegate, DatePickerClassDelegate>

{
    id <setDatePickerDate> classdelegate;
    id delegate;
    UIPopoverController * datePickerPopOver;
    DatePickerClass * datepicker;
    CGRect pickerFrame;
    UIView * super_view;
    NSDate * date;
    UIPopoverController * popOver;
}
@property(nonatomic,assign)id <setDatePickerDate> classdelegate;
@property (nonatomic, assign) id delegate;
@property (nonatomic) CGRect pickerFrame;
@property (nonatomic,retain) UIView * super_view;
@property (nonatomic,retain) DatePickerClass * datepicker;
@property (nonatomic,retain)NSDate *date;
@property (nonatomic, retain) UIPopoverController * popOver;
-(void) tapDateTimePicker:(id)sender;
@end

@protocol setDatePickerDate <NSObject>

@optional
-(void)setDatePickerDatetoTextFielddate;

@end