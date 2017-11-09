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

@property(nonatomic,strong) NSMutableDictionary *dataDictionaryAfterModification;
@property(nonatomic,assign) BOOL isfieldMergeEnabled;

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

-(void)applyValueMapWithMappingObject:(ValueMappingModel *)modelObj withFieldOrder:(NSArray *)fieldOrder;
-(SFMRecordFieldData *)getDisplayValueForLiteral:(NSString *)mappingValue  mappingObject:(ValueMappingModel *)mappingModel;


- (BOOL)saveHeaderRecord:(SFMPage *)sfmPage;
- (BOOL)saveDetailRecords:(SFMPage *)sfmPage;

-(void)performSourceUpdate:(SFMPage *)page;

- (void)applyFormFillSettingOfHeaderPageField:(SFMPageField*)pageField
                              withRecordField:(SFMRecordFieldData *)recordField
                                       sfPage:(SFMPage *)sfmPage;
- (void)applyFormFillOnChildRecordOfIndexPath:(NSIndexPath *)selectedIndexPath
                             sfpage:(SFMPage *)sfpage
                                withPageField:(SFMPageField *)pageField
                             andselectedIndex:(SFMRecordFieldData *)selctedRecordField;

/* As to show warning message when user clicks cancel button on sfm edit page
      we added settings flag to the method and which is redeclared */

- (NSString*)getJsonStringAfterComparisionForObject:(NSString*)objectName
                                           recordId:(NSString*)recordId
                                            andSfid:(NSString*)sfid;

- (NSString*)getJsonStringAfterComparisionForObject:(NSString*)objectName
                                           recordId:(NSString*)recordId
                                               sfid:(NSString*)sfid
                                    andSettingsFlag:(BOOL)isCancel;

- (void)updateRecordIfEventObject:(NSMutableDictionary *)recordDictionary
                    andObjectName:(NSString *)objectName
              andHeaderObjectName:(NSString *)headerObjectName;

-(BOOL)executeFieldUpdateRulesOnload:(SFMPage *)sfmPage andView:(UIView *)aView andDelegate:(id)aDelegate forEvent:(NSString *)event;
-(void)updateSFMPageWithFieldUpdateResponse:(NSString *)response andSFMPage:(SFMPage *)sfmPage;

- (NSString *)getModifiedJSONStringForObject:(NSString *)objectName recordId:(NSString *)recordId sfid:(NSString *)sfid;
@end
