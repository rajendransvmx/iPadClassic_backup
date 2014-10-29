//
//  SFMPageEditManager.h
//  ServiceMaxMobile
//
//  Created by shravya on 29/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPageManager.h"
#import "ValueMappingModel.h"

@interface SFMPageEditManager : SFMPageManager

//@property(nonatomic, assign)BOOL ischild;
@property (nonatomic, weak)id  editViewControllerDelegate;

- (void)fillSfmPage:(SFMPage *)sfPage andProcessType:(NSString *)processType;

- (NSArray *)getPickListInfoForObject:(NSString *)objectName fieldName:(NSString *)fieldName;
- (NSArray *)getPicklistValueForIndexPath:(NSString *)objectName
                                pageField:(SFMPageField *)pageField
                                  sfmpage:(SFMPage *)newSfmPage;
- (NSArray *)getRTDependentPicklistInfoForobject:(NSString *)objectApiName recordTypeId:(NSString *)recordTypeId;
- (NSDictionary *)getDefautValueForRTDepFields:(NSArray *)fields
                               objectname:(NSString *)objectApiName
                             recordTypeId:(NSString *)recordTypeId;

- (void)applyValueMapWithMappingObject:(ValueMappingModel *)modelObj;


- (void)saveHeaderRecord:(SFMPage *)sfmPage;
- (void)saveDetailRecords:(SFMPage *)sfmPage;

@end
