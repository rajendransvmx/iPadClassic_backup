//
//  IncrementalSyncRequestParamHelper.m
//  ServiceMaxMobile
//
//  Created by Sahana on 10/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "IncrementalSyncRequestParamHelper.h"
#import "ModifiedRecordModel.h"
#import "SMXiPad_Utility.h"
#import "SFObjectFieldService.h"
#import "FactoryDAO.h"
#import "ModifiedRecordsDAO.h"
#import "RequestParamModel.h"
#import "RequestConstants.h"
#import "PlistManager.h"
#import "ModifiedRecordModel.h"
#import "CacheManager.h"
#import "StringUtil.h"
#import "SVMXGetPriceHelper.h"
#import "TransactionObjectDAO.h"
#import "CustomActionsDAO.h"
#import "SyncHeapDAO.h"

@interface IncrementalSyncRequestParamHelper ()

@property(nonatomic,strong)NSString *currentRequestIdentifier;
@end

@implementation IncrementalSyncRequestParamHelper

-(id)init
{
    self = [super init];
    if(self)
    {
        self.incrSyncHelper = [[IncrementalSyncHelper alloc] init];
    }
    return self;
}


- (id)initWithRequestIdentifier:(NSString *)requestIndetifier {
    self = [super init];
    if(self)
    {
        self.incrSyncHelper = [[IncrementalSyncHelper alloc] init];
        self.currentRequestIdentifier = requestIndetifier;
    }
    return self;
}

- (RequestParamModel * )createSyncParamters:(NSDictionary *)lastIndexDict
                                 andContext:(NSDictionary *)contextDicticonary {
    @synchronized([self class]){
        
        RequestParamModel * paramModel = [[RequestParamModel alloc] init];
        
        NSMutableArray *parameterArray = [[NSMutableArray alloc] init];
        @autoreleasepool {
            
            /* Last index */
            NSDictionary *subParamDictionary = nil;
            if (lastIndexDict == nil) {
                subParamDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kLastIndex,kSVMXRequestKey,@"0",kSVMXRequestValue,nil];
                [parameterArray addObject:subParamDictionary];
                subParamDictionary = nil;
            }
            else{
                [parameterArray addObject:lastIndexDict];
            }
            
            
            /* Call back */
            
            if (contextDicticonary != nil) {
                
                [parameterArray addObject:contextDicticonary];
            }
            else{
                subParamDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kSVMXCallBack,kSVMXRequestKey,kFalse,kSVMXRequestValue,nil];
                [parameterArray addObject:subParamDictionary];
                subParamDictionary = nil;
            }
            
            /* Last sync time */
            NSString * currentLastSyncTime = nil;
            
            if (currentLastSyncTime == nil) {
                currentLastSyncTime = [self getLastSyncTime];
            }
            NSString *lastModifiedTime = currentLastSyncTime;
            
            if (lastModifiedTime != nil) {
                subParamDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kLastSyncTime,kSVMXRequestKey,lastModifiedTime,kSVMXRequestValue,nil];
                [parameterArray addObject:subParamDictionary];
            }
            
            
            /* Get price change */
            NSArray *pricebookIds = [self getPricebookIds];
            if (pricebookIds == nil) {
                pricebookIds = @[];
            }
            
            if ([pricebookIds count]) {
                subParamDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"PRICEBOOK_IDs",kSVMXRequestKey,pricebookIds,kSVMXRequestValues,nil];
                [parameterArray addObject:subParamDictionary];
            }
            
            NSArray *servicepricebookIds = [self getServicePricebookIds];
            if (servicepricebookIds == nil) {
                servicepricebookIds = @[];
            }
            if ([servicepricebookIds count]) {
                subParamDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"SERVICE_PRICEBOOK_IDs",kSVMXRequestKey,servicepricebookIds,kSVMXRequestValues,nil];
                [parameterArray addObject:subParamDictionary];
            }
            /* We need to send last time stamp for individual request */
            NSDictionary *lastSyncTimeDict = [[NSDictionary alloc] initWithObjectsAndKeys:kOldLastSyncTime,kSVMXRequestKey,lastModifiedTime,kSVMXRequestValue,nil];
            
            NSInteger overallId = kOneCallSyncIdLimit;
            NSInteger currentNumberOfIds = 0;
            /* Create PUT DELETE / PUT UPDATE / PUT INSERT parameters*/
            for (int counter = 0; counter < 3; counter++) {
                
                NSString *paramType = nil;
                NSMutableArray *valueMap = [[NSMutableArray alloc] init];
                switch (counter) {
                    case 0:
                        currentNumberOfIds += [self putDeleteParametersForIdLimit:overallId intoArray:valueMap];
                        paramType = kPutDelete;
                        break;
                    case 1:
                        currentNumberOfIds +=  [self putUpdateParametersForIdLimit:overallId intoArray:valueMap];
                        paramType = kPutUpdate;
                        break;
                    case 2:
                        currentNumberOfIds+= [self putInsertParametersForIdLimit:overallId intoArray:valueMap];
                        paramType = kPutInsert;
                        break;
                }
                
                if ([valueMap count] > 0) {
                    
                    if(counter == 1) {//For Update call
                        //Add syncTime Stamp
                        NSString * updateTimeStamp = [self getLastUpdateTimeFromDefaults];
                        if(updateTimeStamp == nil)
                        {
                            updateTimeStamp = [self getLastSyncTime];
                        }
                        NSDictionary *updateTimeDict = [[NSDictionary alloc] initWithObjectsAndKeys:kOldLastSyncTime,kSVMXRequestKey,updateTimeStamp,kSVMXRequestValue,nil];
                        [valueMap  insertObject:updateTimeDict atIndex:0];
                    }
                    else{
                        
//                        key = "After_Insert_Web_Service";
//                        value = "true";

                        NSString *lCustomCallInsert = [[CacheManager sharedInstance]getCachedObjectByKey:kAfterSaveInsertCustomCallValueMap];
                        if ([lCustomCallInsert isEqualToString:@"AfterInsert"] && counter==2)
                            {
//                            NSDictionary *lAfterInsertCustomCallDict = @{kAfterSaveInsertCustomCallValueMap:@"true"};
                            NSDictionary *updateTimeDict = [[NSDictionary alloc] initWithObjectsAndKeys:kAfterSaveInsertCustomCallValueMap,kSVMXRequestKey,@"true",kSVMXRequestValue,nil];

                            [valueMap insertObject:updateTimeDict atIndex:0];
                        }

                        [valueMap insertObject:lastSyncTimeDict atIndex:0];
                    }
                    
                    NSMutableDictionary *internalValue = [[NSMutableDictionary alloc] init];
                    [internalValue setObject:valueMap forKey:kSVMXRequestSVMXMap];
                    [internalValue setObject:paramType forKey:kEventName];
                    [internalValue setObject:kSync forKey:kEventType];
                    [internalValue setObject:[self getCurrentRequestIdentifier] forKey:kClientRequId];
                    
                    
                    NSDictionary *putParams = [[NSDictionary alloc] initWithObjectsAndKeys:paramType, kSVMXRequestKey,[NSArray arrayWithObject:internalValue ],kLsInternalRequest,nil];
                    [parameterArray addObject:putParams];
                }
                
                /* Number of ids crosses more than 150, then we stop parameter*/
                overallId = overallId - currentNumberOfIds;
                if (overallId<= 0) {
                    break;
                }
            }
            
            /*Update the last local id time in DB*/
            [self handleMaxLocalID];
        }
        
        paramModel.valueMap = parameterArray;
        return paramModel;
        
    }
}



- (void) fillObjectRequestInfo:(NSMutableDictionary *)objectInfoDict
                fromDictionary:(NSDictionary *)mainDict
                    objectName:(NSString *)objectName
{
    
    @synchronized([self class]){
        @autoreleasepool {
            
            /*Fields are valuemaps. Create an array to hold this value*/
            NSMutableArray *fieldValueMapArray = [[NSMutableArray alloc] init];
            NSMutableDictionary *fieldDict = [[NSMutableDictionary alloc] init];
            [fieldDict setObject:kFields forKey:kSVMXRequestKey];
            
            
            
          //  NSArray *fieldsArray =  [self.incrSyncHelper getFieldsForObject:objectName];
           // NSString *fieldsStr = [SMXiPad_Utility getConcatenatedStringFromArray:fieldsArray withSingleQuotesAndBraces:NO];
            //HS NSLog
            //NSLog(@"fields Request str is %@",fieldsStr);
            [fieldDict setObject:@"" forKey:kSVMXRequestValue];
            NSMutableArray *recordValueMap = [[NSMutableArray alloc] init];
            NSArray *recordsArray = [mainDict objectForKey:objectName];
            
            
            [self.incrSyncHelper fillUpDataInSyncRecords:recordsArray];
            
            NSMutableDictionary *beforeSaveDict = [[NSMutableDictionary alloc]init];
            NSMutableArray *beforeSaveArray = [[NSMutableArray alloc]init];

            for (int index = 0; index<[recordsArray count]; index++) {
                
                ModifiedRecordModel *syncRecord = [recordsArray objectAtIndex:index];
                if (syncRecord.cannotSendToServer ) {
                    continue;
                } //sbm save
                else if([syncRecord.recordType isEqualToString:kRecordTypeDetail] && [syncRecord.parentLocalId length] > 0 && ![self.putInsertRecords containsObject:syncRecord.parentLocalId] ) {
                    continue;
                }
                else if([syncRecord.recordType isEqualToString:kRecordTypeMaster])
                {
                    //sbm save
                    [self.putInsertRecords addObject:syncRecord.recordLocalId];
                }
                
                NSMutableDictionary *recordDict = [[NSMutableDictionary alloc] init];
                NSString *keyValue = ([StringUtil isStringEmpty:syncRecord.overrideFlag])?syncRecord.recordLocalId:syncRecord.overrideFlag;
                [recordDict setObject:keyValue forKey:kSVMXRequestKey];
                [recordDict setObject:(syncRecord.jsonRecord != nil)?syncRecord.jsonRecord:@""  forKey:kSVMXRequestValue];
                
                if ( [syncRecord.operation isEqualToString:@"UPDATE"] && syncRecord.jsonRecord.length <2) {
                    syncRecord.fieldsModified = nil;
                }
                else{
                     [recordValueMap addObject:recordDict];
                }
               
                
                if (syncRecord.fieldsModified != nil && [syncRecord.operation isEqualToString:@"UPDATE"]) {  //check for put_update also
                    
                    NSError *error;
                    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[syncRecord.fieldsModified dataUsingEncoding:NSUTF8StringEncoding]
                                                                                   options:NSJSONReadingMutableContainers
                                                                                     error:&error];
                    [beforeSaveDict setObject:@"BEFORE_SAVE" forKey:kSVMXRequestKey];
                    NSError * err;
                    NSMutableDictionary *beforeSaveTempDict = [NSMutableDictionary dictionaryWithDictionary:[jsonDictionary objectForKey:@"BEFORE_SAVE"]];
                    [beforeSaveTempDict setObject:syncRecord.sfId forKey:@"Id"];
                    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:beforeSaveTempDict options:0 error:&err];
                    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [beforeSaveArray addObject:jsonString];
                    
                    [beforeSaveDict setObject:beforeSaveArray forKey:kSVMXRequestValues];
                }
            }
            
            if ([beforeSaveDict count] > 0) {
                [recordValueMap addObject:beforeSaveDict];
            }
            //sbm save
            if([recordValueMap count] > 0){
                [fieldDict setObject:recordValueMap forKey:kSVMXRequestSVMXMap];
                [fieldValueMapArray addObject:fieldDict];
                [objectInfoDict setObject:fieldValueMapArray forKey:kSVMXRequestSVMXMap];
                [objectInfoDict setObject:objectName forKey:kSVMXRequestValue];
            }
        }
    }
}


- (void) fillDeleteObjectRequestInfo:(NSMutableDictionary *)objectInfoDict
                      fromDictionary:(NSDictionary *)mainDict
                          objectName:(NSString *)objectName
{
    @synchronized([self class]){
        @autoreleasepool {
            [objectInfoDict setObject:objectName forKey:kSVMXRequestValue];
            
            /*Fields are valuemaps. Create an array to hold this value*/
            NSMutableArray *fieldValueMapArray = [[NSMutableArray alloc] init];
            NSMutableDictionary *fieldDict = [[NSMutableDictionary alloc] init];
            [fieldDict setObject:kFields forKey:kSVMXRequestKey];
           [fieldDict setObject:@"" forKey:kSVMXRequestValue];
            NSMutableArray *recordValueMap = [[NSMutableArray alloc] init];
            NSArray *recordsArray = [mainDict objectForKey:objectName];
            for (int index = 0; index<[recordsArray count]; index++) {
                NSMutableDictionary *recordDict = [[NSMutableDictionary alloc] init];
                ModifiedRecordModel *syncRecord = [recordsArray objectAtIndex:index];
                [recordDict setObject:syncRecord.recordLocalId forKey:kSVMXRequestKey];
                [recordDict setObject:syncRecord.sfId forKey:kSVMXRequestValue];
                [recordValueMap addObject:recordDict];
            }
            [fieldDict setObject:recordValueMap forKey:kSVMXRequestSVMXMap];
            [fieldValueMapArray addObject:fieldDict];
            [objectInfoDict setObject:fieldValueMapArray forKey:kSVMXRequestSVMXMap];
        }
    }
    
}



- (void)fillRequestParameters:(NSMutableArray *)dataArray
               forSyncRecords:(NSDictionary *)syncRecords
            withOperationType:(NSString *)operationType
{
    
    @synchronized([self class])
    {
        @autoreleasepool {
            
            NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO];
            NSArray * sortedKeys = [[syncRecords allKeys]sortedArrayUsingDescriptors:[[NSArray alloc]initWithObjects:sortDesc, nil]];
            for (int counter = 0; counter < [sortedKeys count]; counter++)
            {
                NSString * key = [sortedKeys objectAtIndex:counter];
                NSString *requestKey = nil;
                if ([operationType isEqualToString:kModificationTypeUpdate] || [operationType isEqualToString:kModificationTypeDelete] ) {
                    requestKey = kObjectName;
                }
                else
                {
                    requestKey = ([key isEqualToString:kRecordTypeMaster])?kParentObject:kChildObject;
                }
                
                NSDictionary * allObjectDict = [syncRecords objectForKey:key];
                NSArray * allObjKeys = [allObjectDict allKeys];
                for (int index=0;index<[allObjKeys count];index++)
                {
                    NSMutableDictionary *objectInfoDict = [[NSMutableDictionary alloc] init];
                    
                    NSString *objectName = [allObjKeys objectAtIndex:index];
                    
                    if ([operationType isEqualToString:kModificationTypeUpdate] || [operationType isEqualToString:kModificationTypeInsert] ) {
                        [self fillObjectRequestInfo:objectInfoDict fromDictionary:allObjectDict objectName:objectName];
                    }
                    else
                    {
                        [self fillDeleteObjectRequestInfo:objectInfoDict fromDictionary:allObjectDict objectName:objectName];
                    }
                    //sbm save
                    if([objectInfoDict count] > 0)
                    {
                        [objectInfoDict setObject:requestKey forKey:kSVMXRequestKey];
                        [dataArray addObject:objectInfoDict];
                    }
                }
                
            }
            
        }
    }
    
}

- (NSDictionary *)filterModifiedRecordsForDeletedRecords:(NSDictionary *)updatedRecords {

    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    id <ModifiedRecordsDAO> modifiedRecordsService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    id <CustomActionsDAO> customActionsService = [FactoryDAO serviceByServiceType:ServiceTypeCustomActionRequestParams];
    id <SyncHeapDAO> syncHeapService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
    
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in [updatedRecords allKeys]) {
        NSDictionary *recordDictionary = [updatedRecords objectForKey:key];
        NSMutableDictionary *filteredRecordDictionary = [[NSMutableDictionary alloc] init];
        
        for (NSString *objectKey in [recordDictionary allKeys]) {
            NSArray *modifiedRecords = [recordDictionary objectForKey:objectKey];
            NSMutableArray *filteredModifiedRecords = [[NSMutableArray alloc] init];
            for (ModifiedRecordModel *modifiedRecordModel in modifiedRecords) {
                /* Check if record exist */
                BOOL isRecordExist =  [transObjectService isRecordExistsForObject:objectKey forRecordLocalId:modifiedRecordModel.recordLocalId];
                if (isRecordExist) {
                    [filteredModifiedRecords addObject:modifiedRecordModel];
                }
                else {
                    //delete record from ModifiedRecords, Sync Heap and CustomActionRequestParams table
                    [modifiedRecordsService deleteRecordsForRecordLocalIds:@[modifiedRecordModel.sfId]];
                    [customActionsService deleteRecordsForRecordLocalIds:@[modifiedRecordModel.sfId]];
                    [syncHeapService deleteRecordsForSfIds:@[modifiedRecordModel.sfId] forParallelSyncType:nil];
                }
            }
            if (filteredModifiedRecords.count > 0) {
                [filteredRecordDictionary setObject:filteredModifiedRecords forKey:objectKey];
            }
        }
        
        if (filteredRecordDictionary.count > 0) {
            [resultDictionary setObject:filteredRecordDictionary forKey:key];
        }
    }
    
    return resultDictionary;
}

- (NSInteger)putUpdateParametersForIdLimit:(NSInteger)maximumNumberOfId
                                 intoArray:(NSMutableArray *)dataArray{
    @autoreleasepool {
        self.putInsertRecords = nil;
        id<ModifiedRecordsDAO> daoObj= [self getModifiedRecordsDAOInstance];
        NSDictionary *updatedRecords = [daoObj getUpdatedRecords];
        NSDictionary *filteredUpdatedRecords = [self filterModifiedRecordsForDeletedRecords:updatedRecords]; //IPAD-4825
        [self fillRequestParameters:dataArray forSyncRecords:filteredUpdatedRecords withOperationType:kModificationTypeUpdate];
        
    }
    
    return 0;
}



- (NSInteger)putDeleteParametersForIdLimit:(NSInteger)maximumNumberOfId
                                 intoArray:(NSMutableArray *)dataArray{
    
    @autoreleasepool {
        id<ModifiedRecordsDAO>  daoObj= [self getModifiedRecordsDAOInstance];
        NSDictionary *deletedRecords = [daoObj getDeletedRecords];
        [self fillRequestParameters:dataArray forSyncRecords:deletedRecords withOperationType:kModificationTypeDelete];
        
    }
    return 0;
}



- (NSInteger)putInsertParametersForIdLimit:(NSInteger)maximumNumberOfId
                                 intoArray:(NSMutableArray *)dataArray{
    
    @autoreleasepool {
        //sbm save
        if(self.putInsertRecords == nil) {
            self.putInsertRecords = [NSMutableArray array];
        }
        
        id<ModifiedRecordsDAO>  daoObj= [self getModifiedRecordsDAOInstance];
        NSDictionary *insertedRecords = [daoObj getInsertedSyncRecords];
        [self fillRequestParameters:dataArray forSyncRecords:insertedRecords withOperationType:kModificationTypeInsert];
        
        self.putInsertRecords = nil;
    }
    return 0;
    
    
}

-(id<ModifiedRecordsDAO>)getModifiedRecordsDAOInstance
{
    id <ModifiedRecordsDAO> daoObj = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    return daoObj;
    
}

-(NSString *)getLastSyncTime
{
   return [PlistManager getOneCallSyncTime];
   
}

-(NSString *)getLastUpdateTimeFromDefaults
{
    return [PlistManager getPutUpdateTime];
}

-(NSString *)getCurrentRequestIdentifier
{
    return self.currentRequestIdentifier;
}

-(void)handleMaxLocalID
{
    NSInteger localId = [self getLastLocalId];
    [self storeLocald:localId];
}

- (NSInteger)getLastLocalId
{
    return [self.incrSyncHelper getMaximumLocalId];
}
-(void)storeLocald:(NSInteger)localId
{

    [PlistManager storeLastLocalIdnDefaults:[[NSString alloc] initWithFormat:@"%ld",(long)localId]];
    
}
-(NSArray*)getPricebookIds
{
    SVMXGetPriceHelper *list = [[SVMXGetPriceHelper alloc] init];
    NSArray *sfidsArrayObj = [list getPricebookIds];
    return sfidsArrayObj;
}

-(NSArray*)getServicePricebookIds
{
    SVMXGetPriceHelper *list = [[SVMXGetPriceHelper alloc] init];
    NSArray *sfidsArrayObj = [list getServicePricebookIds];
    return sfidsArrayObj;
}

@end
