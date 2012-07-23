//
//  CtextFieldWithDatePicker.h
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextFieldHandler.h"
#import "DatePickerClass.h"
#import "BOTGlobals.h"
#import "BOTControlDelegate.h"

@interface CtextFieldWithDatePicker : UITextField <setTextBox,setDatePickerDate>
{
    id <ControlDelegate> controlDelegate;
    TextFieldHandler * delegateHandler; 
    BOOL  flag;
    NSIndexPath * indexPath;
    NSString * fieldAPIName;
    BOOL required;
    NSString * control_type;
}
@property (nonatomic , retain) NSString * control_type;
@property (nonatomic, assign) id <ControlDelegate> controlDelegate;
@property (nonatomic, assign) TextFieldHandler * delegateHandler;
@property (nonatomic ) BOOL flag;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (nonatomic, retain) NSString * fieldAPIName;
@property (nonatomic) BOOL required;

-(id) initWithFrame:(CGRect)frame ;
-(NSDate *)getDate;
-(void) setDate:(NSDate *)date;

@end
