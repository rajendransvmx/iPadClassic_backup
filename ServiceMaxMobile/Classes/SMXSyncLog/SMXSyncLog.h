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
- (NSString *) getFormattedDate;
- (void) scheduletimer;
@end
