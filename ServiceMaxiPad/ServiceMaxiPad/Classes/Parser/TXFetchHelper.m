//
//  TXFetchHelper.m
//  ServiceMaxMobile
//
//  Created by shravya on 27/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "TXFetchHelper.h"
#import "StringUtil.h"
#import "CacheManager.h"
#import "TransactionObjectModel.h"
#import "TransactionObjectService.h"
#import "SFObjectFieldService.h"
#import "DBRequestInsert.h"
#import "DBRequestUpdate.h"
#import "AppManager.h"
#import "SyncHeapService.h"
#import "RequestConstants.h"
#import "SyncHeapDAO.h"
#import "SyncRecordHeapModel.h"
#import "ObjectNameFieldValueModel.h"
#import "ObjectNameFieldValueService.h"
#import "DataTypeUtility.h"

NSString *const kInsertQueryCache   = @"InsertQueryCache";
NSString *const kUpdateQueryCache   = @"UpdateQueryCache";

@interface TXFetchHelper()

@property(nonatomic,assign)BOOL shouldCheckForDuplicateRecords;
@property(nonatomic,strong)DataTypeUtility *dataTypeUtility;

@end

@implementation TXFetchHelper

- (id)initWithCheckForDuplicateRecords:(BOOL)shouldCheck {
    
    self = [super init];
    
    if (self != nil) {
        self.shouldCheckForDuplicateRecords = shouldCheck;
    }
    return self;
}

- (DBRequestInsert *)getInsertQuery:(NSString *)objectName {
    @synchronized([self class]) {
        
        
        NSMutableDictionary *insertQueryDictionary = [[CacheManager sharedInstance] getCachedObjectByKey:kInsertQueryCache];
        if (insertQueryDictionary == nil) {
            insertQueryDictionary = [[NSMutableDictionary alloc ] init];
            [[CacheManager sharedInstance] pushToCacheWithAutomaticDataCleanupProtection:insertQueryDictionary byKey:kInsertQueryCache];;
        }
        
        DBRequestInsert *insertRequest =  [insertQueryDictionary objectForKey:objectName];
        
        if (insertRequest == nil) {
            SFObjectFieldService *sfObject = [[SFObjectFieldService alloc] init];
            NSArray *sfObjectFields =  [sfObject getSFObjectFieldsForObjectWithLocalId:objectName];
            
            if ([sfObjectFields count] > 1) {
                
                NSMutableArray *fieldsArray = [[NSMutableArray alloc] init];
                for (SFObjectFieldModel *aFieldModel in sfObjectFields) {
                    if (aFieldModel.fieldName != nil) {
                        [fieldsArray  addObject:aFieldModel.fieldName];
                    }
                }
                insertRequest = [[DBRequestInsert alloc] initWithTableName:objectName andFieldNames:fieldsArray];
                if (insertRequest != nil) {
                    [insertQueryDictionary setObject:insertRequest forKey:objectName];
                }
            }
        }
        return insertRequest;
    }
    return nil;
}
- (DBRequestUpdate *)getUpdateQuery:(NSString *)objectName {
    
    @synchronized([self class]) {
        
        
        NSMutableDictionary *udateQueryDictionary = [[CacheManager sharedInstance] getCachedObjectByKey:kUpdateQueryCache];
        if (udateQueryDictionary == nil) {
            udateQueryDictionary = [[NSMutableDictionary alloc ] init];
            [[CacheManager sharedInstance] pushToCacheWithAutomaticDataCleanupProtection:udateQueryDictionary byKey:kUpdateQueryCache];
        }
        
        DBRequestUpdate *updateRequest =  [udateQueryDictionary objectForKey:objectName];
        
        if (updateRequest == nil) {
            SFObjectFieldService *sfObject = [[SFObjectFieldService alloc] init];
            NSArray *sfObjectFields =  [sfObject getSFObjectFieldsForObject:objectName];
            
            if ([sfObjectFields count] > 1) {
                
                NSMutableArray *fieldsArray = [[NSMutableArray alloc] init];
                for (SFObjectFieldModel *aFieldModel in sfObjectFields) {
                    if (aFieldModel.fieldName != nil) {
                        [fieldsArray  addObject:aFieldModel.fieldName];
                    }
                }
                DBCriteria *criteria = [[DBCriteria alloc] initWithFieldNameToBeBinded:kId];
                updateRequest = [[DBRequestUpdate alloc] initWithTableName:objectName andFieldNames:fieldsArray whereCriteria:@[criteria] andAdvanceExpression:nil];
                if (updateRequest != nil) {
                    [udateQueryDictionary setObject:updateRequest forKey:objectName];
                }
            }
        }
        return updateRequest;
    }
    return nil;
}

- (BOOL)insertObjects:(NSArray *)objects
       withObjectName:(NSString *)objectName {
    
  
    DBRequestInsert *insertRequest = nil; DBRequestUpdate *updateRequest = nil;
    BOOL isSucces = NO;
    
    NSMutableArray *nameFieldObjects = [[NSMutableArray alloc] init];
   for (TransactionObjectModel *transModel in objects) {
       
       NSMutableDictionary *valueDictionary = (NSMutableDictionary *)[transModel getFieldValueDictionary];
       
       NSString *localId =   [valueDictionary objectForKey:kLocalId];
       if (localId == nil) {
           localId =  [AppManager generateUniqueId];
           if (localId != nil) {
               [valueDictionary setObject:localId forKey:kLocalId];
           }
      }
       [self updateDataBasedOnDataType:objectName andMutableDictionary:valueDictionary];
       
       [self fillUpObjectNameFieldFrom:transModel intoObjectsArray:nameFieldObjects andObjectName:objectName];
   }
    TransactionObjectService * transService = [[TransactionObjectService alloc] init];
    if (self.shouldCheckForDuplicateRecords) {
         insertRequest = [self getInsertQuery:objectName];
         updateRequest = [self getUpdateQuery:objectName];
        
        /* Check the record count by looking for Id */
        if (insertRequest != nil || updateRequest != nil) {
            isSucces =  [transService updateOrInsertTransactionObjects:objects withObjectName:objectName andDbRequest:insertRequest andUpdateRequest:updateRequest];

        }
     }
     else{
         
         insertRequest = [self getInsertQuery:objectName];
         if (insertRequest != nil) {
             isSucces = [transService insertTransactionObjects:objects andDbRequest:[insertRequest query]];
         }
         
     }
    
    if ([nameFieldObjects count] > 0) {
        ObjectNameFieldValueService *service = [[ObjectNameFieldValueService alloc] init];
        [service saveRecordModels:nameFieldObjects];
    }
   return isSucces;
}

- (NSMutableDictionary *)getIdListFromSyncHeapTableWithLimit:(NSInteger)overAllIdLimit {
    @synchronized([self class]){
        
        @autoreleasepool {
            SyncHeapService *heapService = [[SyncHeapService alloc] init];
            
            NSMutableDictionary *objectIdsDictionary = [[NSMutableDictionary alloc] init];
            @autoreleasepool {
                NSArray *objectList = [heapService getDistinctObjectNames];
                
                NSInteger currentNumberOfIds = 0;
                NSInteger numberOfRecordsPerObject = kMaximumnumberOfIdsPerObject;
                if (overAllIdLimit < kMaximumnumberOfIdsPerObject) {
                    numberOfRecordsPerObject = overAllIdLimit;
                }
                
                for (SyncRecordHeapModel *objectModel in objectList) {
                    
                    NSString *objectName = objectModel.objectName;
                    NSMutableDictionary *idsDictionary = [[NSMutableDictionary alloc] init];
                    
                    NSArray *syncRecordIdModels =  [heapService getAllIdsFromHeapTableForObjectName:objectName forLimit:numberOfRecordsPerObject];
                    for (SyncRecordHeapModel *idModel in syncRecordIdModels) {
                        if (![StringUtil isStringEmpty:idModel.sfId] ) {
                            [idsDictionary setObject:idModel.sfId forKey:idModel.sfId];
                        }
                    }
                    NSInteger idsCount = [idsDictionary count];
                    if (idsCount > 0) {
                        [objectIdsDictionary setObject:idsDictionary forKey:objectName];
                        SXLogInfo(@"Request: ObjectName %@ Count %d",objectName,[idsDictionary count]);
                    }
                    
                    currentNumberOfIds = currentNumberOfIds + idsCount;
                    if (currentNumberOfIds >= overAllIdLimit ) {
                        break;
                    }
                    numberOfRecordsPerObject = overAllIdLimit - currentNumberOfIds;
                    if (numberOfRecordsPerObject > kMaximumnumberOfIdsPerObject) {
                        numberOfRecordsPerObject = kMaximumnumberOfIdsPerObject;
                    }
                }
                
                
                if ([objectIdsDictionary count] > 0) {
                    /* DELETE the BELOW IDS*/
                    [heapService    deleteRecordsFromHeap:objectIdsDictionary];
                    return objectIdsDictionary;
                }
                return nil;
            }
        }
   }
}
- (NSArray *)getValueMapDictionary:(NSDictionary *)objectDictionary {
    /* Form a request parameters and get client info */
    NSMutableArray *valueMapArray = [[NSMutableArray alloc] init];
    NSArray *objectNames = [objectDictionary allKeys];
    for (NSString *eachObject in objectNames) {
        
        NSMutableDictionary *idsDictionary = [objectDictionary objectForKey:eachObject];
        NSArray *idsArray = [idsDictionary allKeys];
        NSDictionary *finalDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kSVMXTXObject,kSVMXRequestKey,eachObject,kSVMXRequestValue, idsArray ,kSVMXRequestValues,nil];
        [valueMapArray addObject:finalDictionary];
    }
    return  valueMapArray;
}

- (void)fillUpObjectNameFieldFrom:(TransactionObjectModel *)transModel
                 intoObjectsArray:(NSMutableArray *)objectsArray
                    andObjectName:(NSString *)objectName {
    
    NSDictionary *recordDictionary = (NSMutableDictionary *)[transModel getFieldValueDictionary];
    
    NSArray *allKeys = [recordDictionary allKeys];
    for (NSString *eachKey in allKeys) {
        
        NSDictionary *referenceDictionary = [recordDictionary objectForKey:eachKey];
        /* If value is NSDictionary , then */
        if ([referenceDictionary isKindOfClass:[NSDictionary class]]) {
            
            NSString *sfid = [referenceDictionary objectForKey:kId];
            NSDictionary *attributes =  [referenceDictionary objectForKey:@"attributes"];
            NSString *objName = [attributes objectForKey:@"type"];
            NSString *nameField = [self getNameFieldNameForobject:objName];
            NSString *value = [referenceDictionary objectForKey:nameField];
            
            ObjectNameFieldValueModel *nameFieldModel = [[ObjectNameFieldValueModel alloc] init];
            nameFieldModel.Id =sfid;
            nameFieldModel.value =value;
            
            if (nameFieldModel.Id   != nil) {
                [objectsArray addObject:nameFieldModel];
            }
            
        }
    }
}

- (void)dealloc {
    [[CacheManager sharedInstance]  clearCacheByKey:kInsertQueryCache];
    [[CacheManager sharedInstance]  clearCacheByKey:kUpdateQueryCache];
}


- (void)updateDataBasedOnDataType:(NSString *)objectName
             andMutableDictionary:(NSMutableDictionary *)dataDictionary {
    

    if (self.dataTypeUtility == nil) {
        self.dataTypeUtility = [[DataTypeUtility alloc] init];
    }
    
    NSDictionary *dataTypeDict = [self.dataTypeUtility fieldDataType:objectName];
    for (NSString *fieldName in dataTypeDict) {
        
        NSString *fieldType = [dataTypeDict objectForKey:fieldName];
        if ([fieldType isEqualToString:kSfDTBoolean]) {
            
            NSString *dataValue =  [dataDictionary objectForKey:fieldName];
            BOOL isTrue = [StringUtil isItTrue:dataValue];
            if (isTrue) {
                [dataDictionary setObject:kTrue forKey:fieldName];
            }
            else{
                [dataDictionary setObject:kFalse forKey:fieldName];
            }
        }
    }
}

/* These values are hard coded for query optimization purpoes */
- (NSString *)getNameFieldNameForobject:(NSString *)objectName {
    
    @synchronized([self class]){
        NSString *nameFieldName = kAllObjectNameField;
        if ([objectName isEqualToString:kCaseObject]) {
            nameFieldName = kCaseNameField;
        }
        else{
            if ([objectName isEqualToString:kEventObject]) {
                nameFieldName = kEventNameField;
            }
        }
        return nameFieldName;
    }
    return nil;
}


@end
