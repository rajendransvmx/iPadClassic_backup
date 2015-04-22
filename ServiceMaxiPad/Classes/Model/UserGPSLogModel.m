//
//  UserGPSLog.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 17/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "UserGPSLogModel.h"

@implementation UserGPSLogModel

- (void)explainMe  {
    SXLogInfo(@"localId = %@,\n status = %@,\n latitude = %@,\n longitude = %@,\n user = %@,\n ownerId = %@,\n deviceType = %@,\n createdById = %@,\n additionalInfo = %@,\n timeRecorded = %@,\n",self.localId,self.status,self.latitude,self.longitude,self.user,self.ownerId,self.deviceType,self.createdById,self.additionalInfo,self.timeRecorded);
}

- (void)dealloc
{
    _localId = nil;
    _status = nil;
    _latitude = nil;
    _longitude = nil;
    _user = nil;
    _ownerId = nil;
    _deviceType = nil;
    _createdById = nil;
    _additionalInfo = nil;
    _timeRecorded = nil;
}

@end
