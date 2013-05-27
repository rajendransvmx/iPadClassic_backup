//
//  CSwitch.h
//  CustomClassesipad
//
//  Created by Developer on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOTControlDelegate.h"

@interface CSwitch : UISwitch
{
    id <ControlDelegate> controlDelegate;
    NSIndexPath * indexPath;
    NSString * fieldAPIName;
    BOOL required;
    NSString * control_type;
    BOOL valueChanged;
}
@property (nonatomic) BOOL valueChanged;
@property (nonatomic , retain) NSString * control_type;
@property (nonatomic, assign) id <ControlDelegate> controlDelegate;
@property (nonatomic, retain)  NSIndexPath * indexPath;
@property (nonatomic, retain) NSString * fieldAPIName;
@property (nonatomic) BOOL required;

-(id)initAtPoint: (CGPoint )point;
-(BOOL)getSelected;
-(void)switchValueChanged:(id)sender;

@end
