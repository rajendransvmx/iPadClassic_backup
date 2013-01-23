//
//  BMPTextView.h
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPTextFHandler.h"
#import "MPickContent.h"
#import "BOTControlDelegate.h"
extern void SVMXLog(NSString *format, ...);


@interface BMPTextView : UITextField <setTextfield>
{
    //Radha 9 August
    id <ControlDelegate> controlDelegate;
    
    MPTextFHandler * TextFieldDelegate;
    
    NSArray * PickerValue;
    NSString * str;
    NSIndexPath * indexPath;
    NSString * fieldAPIName;
    NSString * control_type;
    BOOL required;
}

@property (nonatomic, retain) id <ControlDelegate> controlDelegate;
@property (nonatomic , retain) NSString * control_type;
@property (nonatomic, retain) NSString * str;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (nonatomic, retain) NSString * fieldAPIName;
@property (nonatomic) BOOL required;

-(id) initWithFrame:(CGRect)frame  initArray:(NSArray *)arr;

@end
