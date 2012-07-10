//
//  BOTControlDelegate.h
//  project
//
//  Created by Developer on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@protocol ControlDelegate;

// Protocol
@protocol ControlDelegate <NSObject>
@required
- (void) didUpdateLookUp:(NSString *)updatedValue fieldApiName:(NSString *)fieldApiName valueKey:(NSString *)key;
@optional
- (void) controlIndexPath:(NSIndexPath *)indexPath;
- (void) selectControlAtIndexPath:(NSIndexPath *)indexPath;
- (void) deselectControlAtIndexPath:(NSIndexPath *)indexPath;
- (void) control:(id)control didChangeValue:(NSString *)value atIndexPath:(NSIndexPath *)indexPath;
- (void) updateDictionaryForCellAtIndexPath:(NSIndexPath *)indexPath fieldAPIName:(NSString *)fieldAPI fieldValue:(NSString *)fieldValue fieldKeyValue:(NSString *)fieldKeyValue controlType:(NSString *)control_type;
- (void) setLookupPopover:(UIPopoverController *)popover;
// Lookup History
- (void) addLookupHistory:(NSMutableArray *)lookupHistory forRelatedObjectName:(NSString *)relatedObjectName;
-(NSInteger)getControlFieldPickListIndexForControlledPicklist:(NSString *)fieldApi_name atIndexPath:(NSIndexPath *)indexPath controlType:(NSString *)controlType;
-(void)clearTheDependentPicklistValue:(NSString *)fieldApi_name atIndexPath:(NSIndexPath *)indexPath controlType:(NSString *)controlType  fieldValue:(NSString *)field_value;
-(void)singleTapOncusLabel:(id)cusLabel;
-(void)doubleTapOnCusLabel:(id)cusLabel;
-(NSMutableDictionary *)getRecordTypeIdAndObjectNameForCellAtIndexPath:(NSIndexPath *)indexPath;
@end
