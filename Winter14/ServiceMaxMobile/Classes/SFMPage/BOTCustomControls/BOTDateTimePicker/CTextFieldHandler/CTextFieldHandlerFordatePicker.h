//
//  CTextFieldHandler.h
//  CustomClassesipad
//
//  Created by Developer on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatePickerClass.h"

@interface CTextFieldHandler : NSObject
<UITextFieldDelegate>
{
  //  UIPopoverController *datepickerPopOver; 
   // DatePickerClass *datePicker;
    
    float  px;
    float  py;
    float width;
    float height;
    UIView *view;
}
@property(nonatomic)float  px;
@property(nonatomic)float  py;
@property(nonatomic)float  width;
@property(nonatomic)float  height;
//@property(nonatomic,retain) UIView *view;
@end
