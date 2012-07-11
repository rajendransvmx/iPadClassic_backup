//
//  CusTextView.h
//  CustomClassesipad
//
//  Created by Developer on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CusTextViewHandler.h"
#import "BOTControlDelegate.h"

@interface CusTextView : UITextView
<CusTextViewHandlerDelegate,ZBarReaderDelegate>
{
    id <ControlDelegate> controlDelegate;
    BOOL readOnly;
    CusTextViewHandler * cusTextView;
    NSIndexPath * indexPath;
    NSString * fieldAPIName;
    BOOL required;
    NSString * control_type;
}

@property (nonatomic , retain)  NSString * control_type;
@property (nonatomic, assign) id <ControlDelegate> controlDelegate;
@property (nonatomic) BOOL readOnly;
@property (nonatomic, retain) CusTextViewHandler * cusTextView;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (nonatomic, retain) NSString * fieldAPIName;
@property (nonatomic) BOOL required;

- (void) setReadOnly:(BOOL)flag;
- (void) setShouldResizeAutomatically:(BOOL)_shouldResizeAutomatically;
-(id) initWithFrame:(CGRect)frame lableValue:(NSString *)lableValue;

@end
