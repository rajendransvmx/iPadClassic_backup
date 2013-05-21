//
//  CusDateTextFieldPoContent.h
//  CustomClassesipad
//
//  Created by Developer on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol setcusDateTextField;
@protocol cusDatePickerrelease;

@interface CusDateTextFieldPoContent : UIViewController <UIPopoverControllerDelegate> 
{
    id <setcusDateTextField> datePickerDelegate;
    id <cusDatePickerrelease> datepickerreleaseDelegate;
    IBOutlet UIDatePicker *datePicker;
}
- (IBAction)DatePickerValueChanhed:(id)sender;
- (IBAction)deleteDatePickerCOntrolValue:(id)sender;
@property (nonatomic , assign) id <setcusDateTextField> datePickerDelegate;
@property (nonatomic , assign) id <cusDatePickerrelease> datepickerreleaseDelegate;
@property (nonatomic,retain) IBOutlet UIDatePicker *datePicker;
@end

@protocol setcusDateTextField <NSObject>

@optional
-(void) setDateTextField:(NSString *)date ;
-(void) deleteDateTextField;

@end

@protocol cusDatePickerrelease <NSObject>

@optional

-(void) cusDatePickerRelease;

@end
