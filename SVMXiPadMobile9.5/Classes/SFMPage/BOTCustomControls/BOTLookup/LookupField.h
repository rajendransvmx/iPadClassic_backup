//
//  LookupField.h
//  CustomClassesipad
//
//  Created by Developer on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LookupFieldPopover.h"
#import "BOTControlDelegate.h"

@interface LookupField : UITextField
<UITextFieldDelegate, LookupFieldPopoverDelegate,ZBarReaderDelegate>
{
    id <ControlDelegate> controlDelegate;
    NSString * objectName, * searchId;
    NSString * objectLabel;
    LookupFieldPopover * delegateHandler;
    NSMutableArray * lookupHistory;
    NSIndexPath * indexPath;
    NSArray * lookupValue;
    NSString * fieldAPIName, * relatedObjectName;
    BOOL required;
    NSString * control_type;
    NSString * idValue;
    NSNumber * Override_Related_Lookup;
    NSString * Field_Lookup_Context, * Field_Lookup_Query;
    
    NSDictionary * Disclosure_dict;
    ZBarReaderViewController *reader;
}
@property (nonatomic , retain) NSString * barCodeScannedData;
@property (nonatomic , retain) NSString * first_idValue;
@property (nonatomic , retain) NSString * idValue;
@property (nonatomic , retain)     NSString * control_type;
@property (nonatomic, assign) id <ControlDelegate> controlDelegate;
@property (nonatomic, retain) NSString * objectName, * objectLabel,* searchId;
@property (nonatomic, assign) LookupFieldPopover * delegateHandler;
@property (nonatomic, retain) NSMutableArray * lookupHistory;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (nonatomic, retain) NSArray * lookupValue;
@property (nonatomic, retain) NSString * fieldAPIName, * relatedObjectName;
@property (nonatomic) BOOL required;
@property (nonatomic, retain) NSNumber * Override_Related_Lookup;
@property (nonatomic, retain) NSString * Field_Lookup_Context, * Field_Lookup_Query;

@property (nonatomic, retain) NSIndexPath * selectedIndexPath;
@property (nonatomic, retain) NSDictionary * Disclosure_dict;

-(id) initWithFrame:(CGRect)frame labelValue:(NSString *)labelValue inView:(UIView *)poview;
- (void) setReadOnly:(BOOL)flag;
- (void) settextField:(NSString *)value;
- (void) addObjectToHistory:(NSArray *)lookupObject withObjectName:(NSString *)value;
- (void) launchBarcodeScanner;


@end
