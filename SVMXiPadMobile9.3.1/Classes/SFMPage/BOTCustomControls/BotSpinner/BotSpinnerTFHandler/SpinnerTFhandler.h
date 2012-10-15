//
//  SpinnerTFhandler.h
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "popOverContent.h"
#import "WSIntfGlobals.h"


@protocol setSpinnerValue;

@interface SpinnerTFhandler : NSObject <UITextFieldDelegate>
{
    popOverContent *contentView;
    UIPopoverController * POC;
    CGRect rect;
    UIView * TextfieldView;
    id delegate;
    NSArray * spinnerData;
    id <setSpinnerValue>  setSpinnerValuedelegate;
    NSInteger spinnerValue_index;
    BOOL flag;
    NSString * controllerName;
    NSMutableArray * validFor;
    BOOL isdependentPicklist;
}
@property (nonatomic) BOOL isdependentPicklist;
@property (nonatomic , retain) NSString * controllerName;
@property (nonatomic , retain) NSMutableArray * validFor;
@property (nonatomic) BOOL flag;
@property (nonatomic )  NSInteger spinnerValue_index;
@property (nonatomic , assign) id <setSpinnerValue> setSpinnerValuedelegate;
@property (nonatomic , retain)  NSArray * spinnerData;
@property (nonatomic , assign) id delegate;
@property (nonatomic , retain) UIView * TextfieldView;;
@property (nonatomic)   CGRect rect;
@property (nonatomic , retain)  popOverContent *contentView;
@property (nonatomic , retain)  UIPopoverController * POC;
@end

@protocol setSpinnerValue <NSObject>

@optional
-(void) setSpinnerValue;
-(NSArray *)getValuesForDependentPickList;
-(void)clearTheDependentPickListValue;
@end
