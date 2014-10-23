//
//  LocationPingServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "LocationPingServiceLayer.h"
#import "FactoryDAO.h"
#import "UserGPSLogDAO.h"

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
    return nil;
    
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
    
//    NSString *latitudeValue = ([values objectAtIndex:0] != nil)?[values objectAtIndex:0]:@"";
//    NSDictionary *latitudeDict = [NSDictionary dictionaryWithObjectsAndKeys:@"SVMXDEV__Latitude__c", kSVMXKey, latitudeValue, kSVMXValue, nil];
//    
//    NSString*longitudeValue = ([values objectAtIndex:1] != nil)?[values objectAtIndex:1]:@"";
//    NSDictionary *longitudeDict = [NSDictionary dictionaryWithObjectsAndKeys:@"SVMXDEV__Longitude__c", kSVMXResponseKey, longitudeValue, kSVMXResponseValue, nil];
//    
//    [fieldsDictionary setObject:@"Fields" forKey:kSVMXResponseKey];
//    [fieldsDictionary setObject:@"" forKey:kSVMXResponseValue];
//    [fieldsDictionary setObject:[NSArray arrayWithObjects:latitudeDict, longitudeDict, nil] forKey:kSVMXValueMap];
//    
//    paramsArray = [NSArray arrayWithObjects:rangeStartDict, rangeEndDict, fieldsDictionary, nil];
//
    return nil;
}

- (NSArray *)fetchRequestParametersForLocationHistoryRequest{
    return nil;
}
@end
