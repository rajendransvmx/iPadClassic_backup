//
//  BotSpinnerTextField.h
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpinnerTFhandler.h"
#import "BOTControlDelegate.h"

@interface BotSpinnerTextField : UITextField <setTextFieldPopover,setSpinnerValue>
{
    SpinnerTFhandler * TFHandler;
    NSArray * spinnerData;
    NSIndexPath * indexPath;
    id <ControlDelegate> controlDelegate;
    NSString * fieldAPIName;
    BOOL required;
    NSString * control_type;
}
@property (nonatomic , retain) NSString * control_type;
@property (nonatomic, assign) id <ControlDelegate> controlDelegate;
@property (nonatomic, retain) NSArray * spinnerData;
@property (nonatomic, retain) SpinnerTFhandler * TFHandler;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (nonatomic, retain) NSString * fieldAPIName;
@property (nonatomic) BOOL required;

-(id)initWithFrame:(CGRect)frame initArray:(NSArray *)arr;
@end
