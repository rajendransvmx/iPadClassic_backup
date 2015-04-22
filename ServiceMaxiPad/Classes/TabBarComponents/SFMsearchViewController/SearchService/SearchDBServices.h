//
//  SearchDBServices.h
//  ServiceMaxiPhone
//
//  Created by Damodar on 6/27/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "CommonServices.h"
#import "SFMSearchProcessModel.h"
#import "SFMSearchObjectModel.h"

@interface SearchDBServices : CommonServices

- (void)getNameFieldValuesIn:(NSMutableDictionary *)idsDictionary forIds:(NSString*)idsString;

- (NSArray *)getListOfSearchProcesses;
- (NSArray *)getSearchobjectsForProcess:(SFMSearchProcessModel *)searchProcess ;
- (void)fillUpSearchFieldsIntoObject:(SFMSearchObjectModel *)searchObject;
- (NSString *)getFieldNameFromRelationShipName:(NSString *)relationShip
                         withRelatedObjectName:(NSString *)relatedObjctName
                          andCurrentobjectName:(NSString *)objectName;
- (NSMutableArray *)getDataForQuery:(NSString *)searchQuery andObject:(SFMSearchObjectModel *)searchObject;



-(NSMutableArray *)getExpressionComponentForSeachExpressionId:(NSString *)expressionId;
- (NSString *)getNameFieldFOrObjectName:(NSString *)objectName ;
- (void)fillDisplayValueForIds:(NSMutableDictionary *)idsDictionary
                 andObjectName:(NSString *)objectName;



-(void)fillUpPicklistValues:(NSMutableDictionary *)objectInfoDict  pickListDict:(NSMutableDictionary *)pickListDict;
-(void)fillUpRecordTypeForObjects:(NSMutableDictionary *)objectInfoDict  recordTypeDict:(NSMutableDictionary *)recordTypeDict;
- (BOOL)doesObjectHavePermission:(NSString *)objectName;
-(NSString *)getDipalyValueForMultipicklist:(NSDictionary *)picklistDict forValue:(NSString *)fieldValue;

@end
