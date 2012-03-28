//
//  CusLabel.h
//  CustomClassesipad
//
//  Created by Developer on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOTControlDelegate.h"

@interface CusLabel : UILabel 
{
    BOOL shouldResizeAutomatically;
    NSString * id_;
    NSString * object_api_name ;
    NSString * refered_to_table_name;
    BOOL isDoubleTap;
    id <ControlDelegate> controlDelegate;
    
}
@property (nonatomic , retain)  NSString * object_api_name ;
@property (nonatomic , retain) NSString * id_;
@property BOOL shouldResizeAutomatically;
@property (nonatomic , retain) NSString * refered_to_table_name;
-(id)initWithFrame:(CGRect)frame;
-(NSString *) getLabel;
@property (nonatomic, assign) id <ControlDelegate> controlDelegate;
@end
