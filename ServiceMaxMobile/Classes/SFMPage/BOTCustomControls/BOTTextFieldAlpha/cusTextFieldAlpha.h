//
//  cusTextFieldAlpha.h
//  CustomClassesipad
//
//  Created by Developer on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlhaTextHandler.h"
#import "BOTControlDelegate.h"


@interface cusTextFieldAlpha : UITextField <setAlphaTextField , AlhaTextHandlerDelegate,ZBarReaderDelegate> 
{
    id <ControlDelegate> controlDelegate;
    AlhaTextHandler * delegatehandler;
    NSIndexPath * indexPath;
    NSString * fieldAPIName;
    BOOL required;
    NSString * control_type;
}

@property (nonatomic , retain) NSString * control_type;
@property (nonatomic, assign) id <ControlDelegate> controlDelegate;
@property (nonatomic, retain) AlhaTextHandler * delegatehandler;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (nonatomic, retain) NSString * fieldAPIName;
@property (nonatomic) BOOL required;

// - (void) setReadOnly:(BOOL)flag;
//Keyboard fix for readonly fields
-(id) initWithFrame:(CGRect)frame control_type:(NSString *)_control_type isInViewMode:(BOOL)mode isEditable:(BOOL)isEditable;


@end
