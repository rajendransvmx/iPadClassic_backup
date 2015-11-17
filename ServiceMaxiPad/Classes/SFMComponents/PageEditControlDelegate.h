//
//  PageEditControlDelegate.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMRecordFieldData.h"


@protocol PageEditControlDelegate <NSObject>

@optional
- (void)valueForField:(SFMRecordFieldData *)model forIndexPath:(NSIndexPath *)indexPath sender:(id)sender;
-(void)valuesForField:(NSArray *)modelsArray forIndexPath:(NSIndexPath *)indexPath selectionMode:(NSInteger)selectionMode;
- (void)resetDependentPicklistFieldsForIndexpth:(NSIndexPath *)indexPath recordTyeId:(NSString *)recordTypeId;
- (void)clearDependentFields:(NSArray *)pageFields dataDict:(NSDictionary *)defaultValueDict;
- (SFMRecordFieldData *)getInternalValueForLiteral:(NSString *)lietral;
- (SFMRecordFieldData *)filterCriteriaForContextFilter:(NSString *)fieldName forHeaderObject:(NSString *)headerValue;
- (SFMRecordFieldData *)getInternalValueForLiteralForLookUp:(NSString *)lietral;

@end
