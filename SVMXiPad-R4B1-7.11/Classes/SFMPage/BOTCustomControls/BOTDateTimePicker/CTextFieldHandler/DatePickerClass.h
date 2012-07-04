//
//  DatePickerClass.h
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol setTextBox;
@protocol DatePickerClassDelegate;

@interface DatePickerClass : UIViewController
<UIPopoverControllerDelegate>
{
    id <setTextBox> delegate;
    id <DatePickerClassDelegate> datePickerDelegate;
    UIPopoverController * popOverController;
    IBOutlet UIDatePicker * picker;
    NSDate * date;
}

@property (nonatomic, assign) id <setTextBox> delegate;
@property (nonatomic, assign) id <DatePickerClassDelegate> datePickerDelegate;
@property (nonatomic, retain) UIPopoverController * popOverController;
@property (nonatomic, retain) UIDatePicker * picker;

- (IBAction)pickerValueChanged:(id)sender;

- (IBAction)DeleteTextFieldValue:(id)sender;
- (void) setDate:(NSDate *)_date;

@end

@protocol DatePickerClassDelegate <NSObject>

@optional
- (void) didDatePickerDismiss;

@end

@protocol setTextBox <NSObject>

@optional

-(void)setTextBoxToPickerValue:(NSString *) string;
-(void)deleteTextFieldValue;

@end
