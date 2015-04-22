//
//  SMXSyncLog.h
//  iService
//
//  Created by Siva Manne on 08/07/13.
//
//

#import <Foundation/Foundation.h>
#import "INTF_WebServicesDefServiceSvc.h"
@interface SMXSyncLog : NSObject <INTF_WebServicesDefBindingResponseDelegate>
{
    BOOL responseReceived;
}
- (void) syncLogsToServer;
- (NSArray *) getLogRecords;
- (void) sendLogsToServer;
- (void) updateSyncPlistForKey:(NSString *)key withValue:(NSString *)value;
- (void) updateLastPushLogStausInPlist:(NSString *)key withValue:(NSDate *)value; //10312
- (NSDate *) getFormattedDate; //10312
- (void) scheduletimer;
@end
