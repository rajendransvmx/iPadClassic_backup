//
//  CusDateTextField.h
//  CustomClassesipad
//
//  Created by Developer on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CusDateTextFieldHandler.h"
#import "CusDateTextFieldPoContent.h"
#import "BOTControlDelegate.h"

@interface CusDateTextField : UITextField <setcusDateTextField , setPODatePicker>
{
    id <ControlDelegate> controlDelegate;
    CusDateTextFieldHandler * delegateHandler;
    BOOL flag;
    NSIndexPath * indexPath;
    NSString * fieldAPIName;
    BOOL required;
    NSString * control_type;
}
@property (nonatomic , retain) NSString * control_type;
@property (nonatomic, assign) id <ControlDelegate> controlDelegate;
@property (nonatomic) BOOL flag;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (nonatomic, retain) NSString * fieldAPIName;
@property (nonatomic) BOOL required;

-(id) initWithFrame:(CGRect)frame ;

@end
