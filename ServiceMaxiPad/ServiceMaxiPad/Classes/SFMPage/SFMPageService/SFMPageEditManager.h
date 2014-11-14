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
-(SFMRecordFieldData *)getDisplayValueForLiteral:(NSString *)mappingValue  mappingObject:(ValueMappingModel *)mappingModel;


- (void)saveHeaderRecord:(SFMPage *)sfmPage;
- (void)saveDetailRecords:(SFMPage *)sfmPage;

-(void)performSourceUpdate:(SFMPage *)page;

- (void)applyFormFillSettingOfHeaderPageField:(SFMPageField*)pageField
                              withRecordField:(SFMRecordFieldData *)recordField
                                       sfPage:(SFMPage *)sfmPage;
- (void)applyFormFillOnChildRecordOfIndexPath:(NSIndexPath *)selectedIndexPath
                             sfpage:(SFMPage *)sfpage
                                withPageField:(SFMPageField *)pageField
                             andselectedIndex:(SFMRecordFieldData *)selctedRecordField;

@end
