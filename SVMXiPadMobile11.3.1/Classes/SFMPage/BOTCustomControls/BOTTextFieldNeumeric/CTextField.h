//
//  CTextField.h
//  CustomClassesipad
//
//  Created by Developer on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTextFieldHandlerNeum.h"
#import "BOTControlDelegate.h"

@interface CTextField : UITextField
<UITextFieldDelegate, CTextFieldHandlerNumDelegate,ZBarReaderDelegate>
{
    id <ControlDelegate> controlDelegate;
    CTextFieldHandlerNum * delegateHandler;
    NSIndexPath * indexPath;
    NSString * fieldAPIName;
    BOOL required;
    BOOL isinViewMode;;
    NSString * control_type;
}
@property (nonatomic , retain) NSString * control_type;
@property (nonatomic) BOOL isinViewMode;
@property (nonatomic, assign) id <ControlDelegate> controlDelegate;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (nonatomic, assign) CTextFieldHandlerNum * delegateHandler;
@property (nonatomic, retain) NSString * fieldAPIName;
@property (nonatomic) BOOL required;

- (void) setReadOnly:(BOOL)flag;
//Keyboard fix for readonly fields
-(id) initWithFrame:(CGRect)frame lableValue:(NSString *)lableValue controlType:(NSString *)controlType isinViewMode:(BOOL)mode isEditable:(BOOL)isEditable;

@end
