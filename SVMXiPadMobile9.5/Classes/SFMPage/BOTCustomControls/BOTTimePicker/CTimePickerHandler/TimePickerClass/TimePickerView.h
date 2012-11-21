//
//  TimePickerView.h
//  CustomClassesipad
//
//  Created by Developer on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimePickerClassDelegate;
@protocol setTimeTextBox;

@interface TimePickerView : UIViewController <UIPopoverControllerDelegate>
{
    id <setTimeTextBox> delegate;
    id <TimePickerClassDelegate> TimePickerDelegate;
    IBOutlet UIDatePicker * picker;
}
@property (nonatomic, assign)  id <setTimeTextBox> delegate;
@property (nonatomic, assign)   id <TimePickerClassDelegate> TimePickerDelegate;
@property(nonatomic,retain) UIDatePicker * picker;


- (IBAction)timePickerValueChanged:(id)sender;
@end



@protocol TimePickerClassDelegate <NSObject>

@optional
- (void) didTimePickerDismiss;

@end



@protocol setTimeTextBox <NSObject>

@optional

-(void)setTextBoxToPickerValue:(NSString *) string;

@end