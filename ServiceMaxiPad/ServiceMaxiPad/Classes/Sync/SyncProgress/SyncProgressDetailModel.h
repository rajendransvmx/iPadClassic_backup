//
//  SyncProgressDetailModel.h
//  ServiceMaxiPhone
//
//  Created by Radha Sathyamurthy on 28/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

/**
 This is a  Modal Class which handles Config Sync Data  .
 @author Radha Sathyamurthy http://www.servicemax.com
 */


#import <Foundation/Foundation.h>
#import "SyncConstants.h"

@interface SyncProgressDetailModel : NSObject

/**
 Labels holding value of Sync Progress
 */
 @property(nonatomic,retain) NSString *numberOfSteps;
 @property(nonatomic,retain) NSString *currentStep;
 @property(nonatomic,retain) NSString *progress;
 @property(nonatomic,retain) NSString *message;
 @property(nonatomic) SyncStatus syncStatus;
 @property(nonatomic) NSError *syncError;


/**
 This method  instantiate SyncProgressDetailModel
 @param dict: returns Progress Data
 @returns object instance.
 */
- (id)initWithProgressData:(NSDictionary *)dict;

/**
 This method  instantiate SyncProgressDetailModel
 @param progressValue : value for progress
 @param step : pass the current step number
 @param description : description of the message

 @returns object instance.
 */
- (id)initWithProgress:(NSString *)progressValue currentStep:(NSString *)step
               message:(NSString *)description totalSteps:(NSString *)totalSteps syncStatus:(SyncStatus)status;
@end
