//
//  CusDateTextFieldHandler.h
//  CustomClassesipad
//
//  Created by Developer on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CusDateTextFieldPoContent.h"
@protocol setPODatePicker;

@interface CusDateTextFieldHandler : NSObject <UITextFieldDelegate , cusDatePickerrelease> 
{
    CGRect pickerFrame;
    UIView *  superView ;
    id delegate ;
    CusDateTextFieldPoContent * contentView;
    UIPopoverController *popOver;
    id <setPODatePicker>  PODatePickerdelegate;
}
@property (nonatomic , assign) id <setPODatePicker>  PODatePickerdelegate;
@property (nonatomic) CGRect pickerFrame;
@property (nonatomic,retain) UIView * superView;
@property(nonatomic,assign)id delegate;
@property (nonatomic ,retain) CusDateTextFieldPoContent * contentView;
@property (nonatomic ,retain)UIPopoverController *popOver;
-(void)tapDatePicker:(id)sender;
@end

@protocol setPODatePicker <NSObject>

@optional
-(void) setPODatepickerValue;

@end