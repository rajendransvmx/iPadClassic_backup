//
//  SFMSearchServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Himanshi on 11/3/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMSearchServiceLayer.h"
#import "ParserFactory.h"
#import "DODHelper.h"
#import "CacheManager.h"


@implementation SFMSearchServiceLayer

- (instancetype)initWithCategoryType:(CategoryType)categoryType requestType:(RequestType)requestType {
    self = [super initWithCategoryType:categoryType requestType:requestType];
    if (self != nil) {
        //Intialize if required
    }
    return self;
}


- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    ResponseCallback *callBack = nil;
    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        parserObj.clientRequestIdentifier = self.requestIdentifier;
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel responseData:responseData];
    }
    return callBack;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{

    NSArray *requestArray;
    switch (self.requestType) {
        case RequestDataOnDemandGetData:
            //fill Data
            
           requestArray =[self fetchRequestParametersForDODRequest];
            
            break;
            
        default:
            NSLog(@"Invalid request type");
            break;
    }
    
    return requestArray;
    
}


- (NSArray *)fetchRequestParametersForDODRequest
    {
        NSArray *resultArray;
        
        
        NSString *objectName = [[CacheManager sharedInstance] getCachedObjectByKey:@"searchObjectName"];
        NSString *recordId = [[CacheManager sharedInstance] getCachedObjectByKey:@"searchSFID"];
        
        NSMutableDictionary *valueMapForObject = [[NSMutableDictionary alloc]initWithCapacity:0];
        [valueMapForObject setObject:@"Object_Name" forKey:kSVMXKey];
        [valueMapForObject setObject:objectName forKey:kSVMXValue];
        
        
        NSMutableDictionary *valueMapId = [[NSMutableDictionary alloc]initWithCapacity:0];
        [valueMapId setObject:@"Id" forKey:kSVMXKey];
        [valueMapId setObject:recordId forKey:kSVMXValue];
        
        NSString *field_string = [DODHelper getFieldNamesForObject:objectName];

        NSMutableDictionary *valueMapFields = [[NSMutableDictionary alloc]initWithCapacity:0];
        [valueMapFields setObject:@"Fields" forKey:kSVMXKey];
        [valueMapFields setObject:field_string forKey:kSVMXValue];
        
        
        NSMutableDictionary *valueMapParentField_for_Parent = [[NSMutableDictionary alloc]initWithCapacity:0];
        [valueMapParentField_for_Parent setObject:@"Parent_Reference_Field" forKey:kSVMXKey];
        [valueMapParentField_for_Parent setObject:@"" forKey:kSVMXValue];
        
        
        NSArray *valueMapArray  = [NSArray arrayWithObjects:valueMapParentField_for_Parent,valueMapId,valueMapFields, nil];
        [valueMapForObject setObject:valueMapArray forKey:kSVMXSVMXMap];
        
        
        RequestParamModel *reqParModel = [[RequestParamModel alloc]init];
        //reqParModel.valueMap = @[valueMapForObject];
        
        NSDictionary *dict_Child = [DODHelper getChildRelationshipForObject:objectName];
        NSArray * allChildObject = [dict_Child allKeys];
        NSString *child_Object = nil;
        NSMutableDictionary *valueMapChildObject = [[NSMutableDictionary alloc]initWithCapacity:0];

        
        for (int i = 0 ; i < [allChildObject count]; i++)
        {
            
            child_Object = [allChildObject objectAtIndex:i];
            
            [valueMapChildObject setObject:@"Object_Name" forKey:kSVMXKey];
            [valueMapChildObject setObject:child_Object forKey:kSVMXValue];
            
            NSMutableDictionary *valueMapChildId = [[NSMutableDictionary alloc]initWithCapacity:0];
            [valueMapChildId setObject:@"Id" forKey:kSVMXKey];
            [valueMapChildId setObject:recordId forKey:kSVMXValue];
            
            
            
            NSString *field_child_string = [DODHelper getFieldNamesForObject:child_Object];
            
            NSMutableDictionary *valueMapChildFields = [[NSMutableDictionary alloc]initWithCapacity:0];
            [valueMapChildFields setObject:@"Fields" forKey:kSVMXKey];
            [valueMapChildFields setObject:field_child_string forKey:kSVMXValue];
            
            
            
            NSMutableDictionary *valueMapParentField = [[NSMutableDictionary alloc]initWithCapacity:0];
            [valueMapParentField setObject:@"Parent_Reference_Field" forKey:kSVMXKey];
            [valueMapParentField setObject:[dict_Child objectForKey:child_Object] forKey:kSVMXValue];
            
            
            NSArray *valueMapArray1 = [NSArray arrayWithObjects:valueMapChildId,valueMapChildFields,valueMapParentField, nil];
            [valueMapChildObject setObject:valueMapArray1 forKey:kSVMXRequestSVMXMap];
            
            

            
        }

        reqParModel.valueMap = @[valueMapForObject,valueMapChildObject];

        resultArray = @[reqParModel];

        return resultArray;
 }


@end
