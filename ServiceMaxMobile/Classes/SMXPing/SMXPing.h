//
//  SMXPing.h
//  iService
//
//  Created by Siva Manne on 03/07/13.
//
//

#import <Foundation/Foundation.h>
#import "INTF_WebServicesDefServiceSvc.h"
@class SMXMonitor;
@interface SMXPing : NSObject <INTF_WebServicesDefBindingResponseDelegate>
{
    SMXMonitor *monitor;
    BOOL responseReceived;
    BOOL stopScheduling;
}
- (void) stopScheduleSMXPing;
- (void) scheduleSMXPing;
- (void) connectSVMX;
- (void) connectSalesforce;
@end
