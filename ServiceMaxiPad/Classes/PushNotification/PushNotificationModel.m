//
//  NotificationModel.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 04/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "PushNotificationModel.h"
#import "PushNotificationUtility.h"
#import "ResponseConstants.h"
#import "StringUtil.h"

@implementation PushNotificationModel

- (id)initWithDictionary:(NSDictionary *)dataDictionay {
    
    if (self = [super init]) {
        
        NSString *sfIdValue = @"";
        NSString *objectName = @"";
        NSString *actionTagValue = @"";
        NSString *title = @"";
        NSDictionary *messageDict = nil;
        NSString *notificationMessageValue = @"";
        
        NSDictionary *payLoad = [dataDictionay objectForKey:kPulseNotificationString];
        if ([payLoad count] > 0 && ![payLoad isKindOfClass:[NSNull class]]) {
            
            sfIdValue = [payLoad objectForKey:kPulseNotificationSFId];
            
            NSString * objectName_ =  [PushNotificationUtility getObjectForSfId:sfIdValue];
            objectName = objectName_;//[payLoad objectForKey:kPulseNotificationObjectName];
            actionTagValue = [payLoad objectForKey:kPulseNotificationActionTag];
            title = [payLoad objectForKey:kPulseNotificationTitle];
            messageDict = [payLoad objectForKey:kPulseNotificationAps];
            if (messageDict != nil) {
                notificationMessageValue = [messageDict objectForKey:kPulseNotificationMessage];
            }
        }
        if(![StringUtil isStringEmpty:sfIdValue])
        {
            self.sfId = sfIdValue;
        }
        if(![StringUtil isStringEmpty:objectName])
        {
            self.objectName = objectName;
        }
        if(![StringUtil isStringEmpty:actionTagValue])
        {
            self.actionTag = actionTagValue;
        }
        
        NSString *userIdValue = (NSString *)[dataDictionay objectForKey:kPulseNotificationUserId];
        if(![StringUtil isStringEmpty:userIdValue])
        {
            self.userId = userIdValue;
        }
        
        NSString *orgIdValue = (NSString *)[dataDictionay objectForKey:kPulseNotificationOrgId];
        if(![StringUtil isStringEmpty:orgIdValue])
        {
            self.orgId = orgIdValue;
        }
        
        if(![StringUtil isStringEmpty:title])
        {
            self.notificationTitle = title;
        }
        
        if(![StringUtil isStringEmpty:notificationMessageValue])
        {
            self.notificationMessage = notificationMessageValue;
        }
        
        if ([self.actionTag isEqualToString:kPulseNotificationDownload])
        {
            self.requestType = NotificationRequestTypeDownload;

        }    
    }
    return self;
}

@end
