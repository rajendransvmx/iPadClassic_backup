//
//  PageModificationObserver.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 6/6/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PageModificationObserver : NSObject

- (id)initWithModifiedDataDictionary:(NSMutableDictionary *)dataDictionary
                            recordId:(NSString *)recordId
                  andObjectOrApiName:(NSString *)apiName;

- (id)initWithModifiedEventStartDate:(NSString *)startDate
                             endDate:(NSString *)endDate
                            recordId:(NSString *)recordId
                             andSfId:(NSString *)salesForceId;

- (NSString *)jsonString;

- (void)doDataComparison;

- (BOOL)hasDataModified;
- (BOOL)hasFoundNonAdvancedFieldMergeChanges;
- (BOOL)updateModifiedFieldsData;

@end
