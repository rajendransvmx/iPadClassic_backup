//
//  SFMDetailFieldData.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFMDetailFieldData : NSObject

@property(nonatomic, strong) NSString *parentColumnName;
@property(nonatomic, strong) NSString *parentSfID;
@property(nonatomic, strong) NSString *parentLocalId;
@property(nonatomic, strong) NSString *expression;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSArray  *fieldsArray;
@property(nonatomic, strong) NSDictionary  *fieldInfo;
@property(nonatomic, strong) NSString  *recordId;
@property(nonatomic, strong) NSString *sortingData;
@property(nonatomic, strong) NSMutableArray *criteriaObjects;
@property(nonatomic, copy) NSString *sourceToTargetType;

- (NSMutableArray *)getAllFieldNames;
- (NSDictionary *)getSortingDetails;
- (void)updateEntryCriteriaObjects;
- (BOOL)shouldApplySortingOrder;

@end
