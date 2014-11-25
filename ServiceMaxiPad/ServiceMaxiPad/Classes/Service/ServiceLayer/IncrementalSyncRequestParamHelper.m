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
            
            
            
            NSArray *fieldsArray =  [self.incrSyncHelper getFieldsForObject:objectName];
            NSString *fieldsStr = [SMXiPad_Utility getConcatenatedStringFromArray:fieldsArray withSingleQuotesAndBraces:NO];
            //HS NSLog
            //NSLog(@"fields Request str is %@",fieldsStr);
            [fieldDict setObject:fieldsStr forKey:kSVMXRequestValue];
            NSMutableArray *recordValueMap = [[NSMutableArray alloc] init];
            NSArray *recordsArray = [mainDict objectForKey:objectName];
            
            
            [self.incrSyncHelper fillUpDataInSyncRecords:recordsArray];
            
            
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
                [recordDict setObject:syncRecord.recordLocalId forKey:kSVMXRequestKey];
                [recordDict setObject:(syncRecord.jsonRecord != nil)?syncRecord.jsonRecord:@""  forKey:kSVMXRequestValue];
                [recordValueMap addObject:recordDict];
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

- (NSInteger)putUpdateParametersForIdLimit:(NSInteger)maximumNumberOfId
                                 intoArray:(NSMutableArray *)dataArray{
    @autoreleasepool {
        self.putInsertRecords = nil;
        id<ModifiedRecordsDAO> daoObj= [self getModifiedRecordsDAOInstance];
        NSDictionary *updatedRecords = [daoObj getUpdatedRecords];
        [self fillRequestParameters:dataArray forSyncRecords:updatedRecords withOperationType:kModificationTypeUpdate];
        
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

    [PlistManager storeLastLocalIdnDefaults:[[NSString alloc] initWithFormat:@"%d",localId]];
    
}

@end
