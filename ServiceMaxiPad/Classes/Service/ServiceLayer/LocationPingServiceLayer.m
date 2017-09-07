//
//  LocationPingServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "LocationPingServiceLayer.h"
#import "FactoryDAO.h"
#import "UserGPSLogDAO.h"
#import "StringUtil.h"

@implementation LocationPingServiceLayer

- (instancetype)initWithCategoryType:(CategoryType)categoryType
                          requestType:(RequestType)requestType {
    
    self = [super initWithCategoryType:categoryType requestType:requestType];
    
    if (self != nil) {
        //Intialize if required
        
    }
    
    return self;
    
}

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                        responseData:(id)responseData {
    ResponseCallback *callBack;
    switch (self.requestType) {
            
        case RequestTechnicianLocationUpdate:
        {
            /**
             * We don't have to do anything :)....
             */
        }
            break;
            
        case RequestLocationHistory:
        {
            /**
             * Send requestParamModel and delete the records that are updated.
             */
            [self deleteSentUserGPSLogs:requestParamModel];
        }
            break;
            
        default:
            break;
    }

    return callBack;
    
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount {
    
    NSArray *result = nil;
    switch (self.requestType) {
            
        case RequestTechnicianLocationUpdate:
        {
            result = [self fetchRequestParametersForTechnicianLocationUpdateRequest];
        }
            break;
            
        case RequestLocationHistory:
        {
            result = [self fetchRequestParametersForLocationHistoryRequest];
        }
            break;
            
        default:
            break;
    }
    return result;
}

- (NSArray *)fetchRequestParametersForTechnicianLocationUpdateRequest{
    
    NSArray *result;
    id gpsLogService = [FactoryDAO serviceByServiceType:ServiceTypeUserGPSLog];
    if ([gpsLogService conformsToProtocol:@protocol(UserGPSLogDAO)]) {
        
        UserGPSLogModel *model = [gpsLogService getLastGPSLog];
        
        NSMutableDictionary *finaldict = [[NSMutableDictionary alloc]initWithCapacity:0];
        [finaldict setObject:@"Fields" forKey:kSVMXKey];
        [finaldict setObject:@"" forKey:kSVMXValue];
        
        NSString *timeRecorded = @""; // IPAD-4607
        
        if (![StringUtil isStringEmpty:model.latitude] && ![StringUtil isStringEmpty:model.longitude]) {
            
            NSDictionary *latDict = @{kSVMXKey:ORG_NAME_SPACE@"__Latitude__c",
                                      kSVMXValue:model.latitude};
            NSDictionary *longDict = @{kSVMXKey:ORG_NAME_SPACE@"__Longitude__c",
                                       kSVMXValue:model.longitude};
            [finaldict setObject:@[latDict,longDict] forKey:kSVMXSVMXMap];
            
            // IPAD-4607
            timeRecorded = model.timeRecorded;
            timeRecorded = [timeRecorded stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            timeRecorded = [timeRecorded stringByDeletingPathExtension];

            
        } else {
            [finaldict setObject:@[] forKey:kSVMXSVMXMap];
        }

        RequestParamModel *reqParModel = [[RequestParamModel alloc]init];
        reqParModel.valueMap = @[finaldict];
        reqParModel.values = @[timeRecorded]; // IPAD-4607
        result = @[reqParModel];
    }

    return result;
}

- (NSArray *)fetchRequestParametersForLocationHistoryRequest{
    
    NSArray *result;
    id gpsLogService = [FactoryDAO serviceByServiceType:ServiceTypeUserGPSLog];
    if ([gpsLogService conformsToProtocol:@protocol(UserGPSLogDAO)]) {
        
        NSArray *models = [gpsLogService fetchAllUserGPSLogs];
        NSMutableArray *params = [[NSMutableArray alloc]initWithCapacity:0];
        for (UserGPSLogModel *model in models) {
            
            NSMutableDictionary *finaldict = [[NSMutableDictionary alloc]initWithCapacity:0];
            [finaldict setObject:@"Record" forKey:kSVMXKey];
            [finaldict setObject:@"" forKey:kSVMXValue];
            NSMutableArray *valueMap = [[NSMutableArray alloc]initWithCapacity:0];
            
            if(model.localId)
            {
            [valueMap addObject:@{kSVMXKey:@"localId",
                                  kSVMXValue:model.localId}];
            }
            
            if (model.latitude) {
            [valueMap addObject:@{kSVMXKey:ORG_NAME_SPACE@"__Latitude__c",
                                      kSVMXValue:model.latitude}];
            }
            
            if (model.longitude)
            {
            [valueMap addObject:@{kSVMXKey:ORG_NAME_SPACE@"__Longitude__c",
                                  kSVMXValue:model.longitude}];
            }
            
            if (model.status)
            {
            [valueMap addObject:@{kSVMXKey:ORG_NAME_SPACE@"__Status__c",
                                  kSVMXValue:model.status}];
            }
            
            if (model.user)
            {
            [valueMap addObject:@{kSVMXKey:ORG_NAME_SPACE@"__User__c",
                                  kSVMXValue:model.user}];
            }
            
            if (model.deviceType) {
                [valueMap addObject:@{kSVMXKey:ORG_NAME_SPACE@"__Device_Type__c",
                                      kSVMXValue:model.deviceType}];
            }
            
            if (model.additionalInfo) {

            [valueMap addObject:@{kSVMXKey:ORG_NAME_SPACE@"__Additional_Info__c",
                                  kSVMXValue:model.additionalInfo}];
            }
            NSString *timeStamp = model.timeRecorded;
            timeStamp = [timeStamp stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            timeStamp = [timeStamp stringByDeletingPathExtension];
            
            if (timeStamp) {

            [valueMap addObject:@{kSVMXKey:ORG_NAME_SPACE@"__Time_Recorded__c",
                                  kSVMXValue:timeStamp}];
            }
            [finaldict setObject:valueMap forKey:kSVMXSVMXMap];
            [params addObject:finaldict];
        }
        RequestParamModel *reqParModel = [[RequestParamModel alloc]init];
        reqParModel.valueMap = params;
        result = @[reqParModel];
    }
    
    return result;
}

#pragma mark - deleting send ids
- (void)deleteSentUserGPSLogs:(RequestParamModel *)paramModel
{
    NSMutableArray *localIds = [[NSMutableArray alloc]initWithCapacity:0];
    for (NSDictionary *dict in paramModel.valueMap) {
        NSArray *valueMap = [dict objectForKey:kSVMXSVMXMap];
        NSPredicate *p = [NSPredicate predicateWithFormat:@"key == %@",@"localId"];
        NSArray *matchedDicts = [valueMap filteredArrayUsingPredicate:p];
        NSDictionary *localIdDict = [matchedDicts lastObject];
        NSString *localId = [localIdDict objectForKey:kSVMXValue];
        [localIds addObject:localId];
    }
    if ([localIds count]) {
        id gpsLogService = [FactoryDAO serviceByServiceType:ServiceTypeUserGPSLog];
        if ([gpsLogService conformsToProtocol:@protocol(UserGPSLogDAO)]) {
           BOOL status = [gpsLogService deleteGPSLogsWithLocalIds:localIds];
            if (status) {
//                NSLog(@"Location logs are successfully deleted from UserGPSLogs");
            }
        }
    }
}
@end
