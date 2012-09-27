//
//  TimePIckerTextField.h
//  CustomClassesipad
//
//  Created by Developer on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPTextFieldHandler.h"
#import "BOTControlDelegate.h"

@interface TimePIckerTextField : UITextField <setTimePicker,setTimeTextBox>
{
    id <ControlDelegate> controlDelegate;
    TPTextFieldHandler *delegateHandler;
    NSIndexPath *indexPath;
    NSString * fieldAPIName;
    BOOL required;
    NSString * control_type;
}

@property (nonatomic , retain)     NSString * control_type;
@property (nonatomic, assign) id <ControlDelegate> controlDelegate;
@property (nonatomic, assign) TPTextFieldHandler *delegateHandler;
@property (nonatomic, retain)  NSIndexPath *indexPath;
@property (nonatomic, retain) NSString * fieldAPIName;
@property (nonatomic) BOOL required;

-(id) initWithFrame:(CGRect)frame inView:(UIView *)inView;
@end
