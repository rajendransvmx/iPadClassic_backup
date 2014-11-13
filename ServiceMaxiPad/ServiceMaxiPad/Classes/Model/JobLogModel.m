//
//  JobLogModel.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 13/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "JobLogModel.h"

@implementation JobLogModel

- (void)explainMe  {
    NSLog(@"localId = %@,\n category = %@,\n timeStamp = %@,\n level = %zd,\n context = %@,\n message = %@,\n type = %@,\n groupId = %@,\n profileId = %@,\n operation = %@",self.localId,self.category,self.timeStamp,self.level,self.context,self.message,self.type,self.groupId,self.profileId,self.operation);
}

- (void)dealloc {
    
    _localId = nil;
    _category = nil;
    _timeStamp = nil;
    _context = nil;
    _message = nil;
    _type = nil;
    _groupId = nil;
    _profileId = nil;
    _operation = nil;
}
@end
