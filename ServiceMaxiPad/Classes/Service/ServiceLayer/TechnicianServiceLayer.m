//
//  TechnicianServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Anoop on 11/2/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "TechnicianServiceLayer.h"
#import "CacheManager.h"
#import "CustomerOrgInfo.h"
#import "CacheConstants.h"
#import "StringUtil.h"

NSString *const KNotificationTechnicianDetails = @"NotificationTechnicianDetails";
NSString *const KNotificationTechnicianAddress = @"NotificationTechnicianAddress";

@implementation TechnicianServiceLayer

- (instancetype) initWithCategoryType:(CategoryType)categoryType
                          requestType:(RequestType)requestType {
    
    self = [super initWithCategoryType:categoryType requestType:requestType];
    
    if (self != nil) {
        //Intialize if required
        
    }
    
    return self;
    
}

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                        responseData:(id)responseData {
    switch (self.categoryType) {
        case CategoryTypeTechnicianDetails:
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationTechnicianDetails object:responseData];
            break;
            
        case CategoryTypeTechnicianAddress:
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationTechnicianAddress object:responseData];
            break;
            
        default:
            break;
    }
    
    //NO DB for technician required need to request server whenever required
    /*
    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        
        parserObj.clientRequestIdentifier = self.requestIdentifier;
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
    }
     */
    return nil;
    
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    RequestParamModel * param = nil;
    
    switch (self.categoryType) {

        case CategoryTypeTechnicianDetails:
        {
            NSString *userId = [CustomerOrgInfo sharedInstance].currentUserId;
            if ([StringUtil isStringEmpty:userId]) {
                userId = @"";
            }
            NSString *query = [NSString stringWithFormat:@"SELECT %@, %@, %@  FROM %@ WHERE %@ = '%@'", kId, kServiceGroup, kInventoryLocation, kServiceGroupMembers, kSalesForceUser, userId];
                param = [[RequestParamModel alloc] init];
                param.value = query;
        }
        break;

        case CategoryTypeTechnicianAddress:
        {
            NSString *technicianId = [[CacheManager sharedInstance] getCachedObjectByKey:TECHNICIANID];
            if ([StringUtil isStringEmpty:technicianId]) {
                technicianId = @"";
            }
            NSString *query = [NSString stringWithFormat:@"Select %@, %@, %@, %@, %@, %@, %@ FROM %@ WHERE Id = '%@'", kWorkOrderSTREET, kWorkOrderCITY, kWorkOrderSTATE, kWorkOrderZIP, kWorkOrderCOUNTRY, kWorkOrderLatitude,kWorkOrderLongitude,kServiceGroupMembers, technicianId];
                param = [[RequestParamModel alloc] init];
                param.value = query;
        }
        break;
        default:
            return nil;
            break;
    }
    
    return @[param];
}
@end
