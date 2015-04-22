//
//  MPTextFHandler.h
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPickContent.h"

@interface MPTextFHandler : NSObject <UITextFieldDelegate , releasePopOver> 
{
    UIPopoverController * poc;
    id     delegate;
    MPickContent  * contentView;
    NSArray  *  pickerContent;
    UIView   *  view;
    CGRect   pickerrect;
    NSString *str;
    NSMutableArray * pickListValues;
    BOOL flag;
}

//5878: Aparna
@property (nonatomic) BOOL isdependentPicklist;
@property (nonatomic , retain) NSString * controllerName;
@property (nonatomic , retain) NSMutableArray * validFor;


@property (nonatomic )   BOOL flag;
@property (nonatomic ,retain)  NSMutableArray * pickListValues;
@property (nonatomic) CGRect   pickerrect;
@property (nonatomic, retain) NSArray * pickerContent;
@property (nonatomic, retain) MPickContent  * contentView;
@property (nonatomic, retain) UIPopoverController * poc;
@property (nonatomic, retain) UIView * view;
@property (nonatomic,assign) id delegate;
@property (nonatomic, retain)   NSString *str;
-(void) tapMultiPicklist:(id)sender;
@end
