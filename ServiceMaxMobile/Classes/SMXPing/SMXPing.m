//
//  SMXPing.m
//  iService
//
//  Created by Siva Manne on 03/07/13.
//
//

#import "SMXPing.h"
#import "ZKServerSwitchboard.h"
#import "AppDelegate.h"
#import "SMXLogger.h"
#import "SMXMonitor.h"

#define kDurationForPing 1.0
@implementation SMXPing
- (void) scheduleSMXPing
{
    return; // Enable it after Sum13. 
    stopScheduling = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    /*
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, queue, ^(void){
        responseReceived = NO;
        [self connectSVMX];
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
            if (![appDelegate isInternetConnectionAvailable] || appDelegate.connection_error)
                break;
        }
    });
     */
    dispatch_async(queue, ^(void){
        responseReceived = NO;
        [self connectSVMX];
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
            if (![appDelegate isInternetConnectionAvailable] || appDelegate.connection_error)
                break;
        }
    });
}
- (void) connectSVMX
{
    @try
    {
        monitor = [[SMXMonitor alloc] init];
        [monitor monitorSMMessageWithName:"[SMXPing connectSVMX]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kLogLevelPerformance
                               logContext:@"Start"
                             timeInterval:kWSExecutionDuration];

        [INTF_WebServicesDefServiceSvc initialize];
        
        INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
        sessionHeader.sessionId = [[ZKServerSwitchboard switchboard] sessionId];
        
        INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
        callOptions.client = nil;
        
        INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
        debuggingHeader.debugLevel = 0;
        
        INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init]  autorelease];
        allowFieldTruncationHeader.allowFieldTruncation = NO;
        
        INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
        binding.logXMLInOut = YES;
        
        INTF_WebServicesDefServiceSvc_INTF_DataSync_WS * dataSync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
        
        INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init]
                                                                      autorelease];
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_startTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
        SVMXCMap_startTime.key  = @"RANGE_START";
        SVMXCMap_startTime.value = [NSDate date];
        
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXCMap_endTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
        SVMXCMap_endTime.key  = @"RANGE_END";
        SVMXCMap_endTime.value = [NSDate date];
        
        
        [sfmRequest.valueMap addObject:SVMXCMap_startTime];
        [sfmRequest.valueMap addObject:SVMXCMap_endTime];
        
        INTF_WebServicesDefServiceSvc_SVMXClient * client = [appDelegate getSVMXClientObject];
        
        sfmRequest.eventName = @"SVMX_PING";
        sfmRequest.eventType = @"SYNC";
        
        sfmRequest.userId = [appDelegate.loginResult userId];
        sfmRequest.groupId = [[appDelegate.loginResult userInfo] organizationId];
        sfmRequest.profileId = [[appDelegate.loginResult userInfo] profileId];
        
        //sahana
        sfmRequest.value = @"";
        
        
        [sfmRequest addClientInfo:client];
        [dataSync setRequest:sfmRequest];
        
        SMLog(@"  Incremental DataSync Request sent: %@", [NSDate date]);
        
        
        [binding INTF_DataSync_WSAsyncUsingParameters:dataSync
                                        SessionHeader:sessionHeader 
                                          CallOptions:callOptions
                                      DebuggingHeader:debuggingHeader
                           AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:self];
    }
    @catch (NSException *exp)
    {
        SMLog(@"Exception Name WSInterface :dataSyncWithEventName %@",exp.name);
        SMLog(@"Exception Reason WSInterface :dataSyncWithEventName %@",exp.reason);
    }
}
- (void) stopScheduleSMXPing
{
    stopScheduling = YES;
}
#pragma - INTF delegate Method
- (void) operation:(INTF_WebServicesDefBindingOperation *)operation completedWithResponse:(INTF_WebServicesDefBindingResponse *)response
{
    responseReceived = YES;
    [monitor monitorSMMessageWithName:"[SMXPing connectSVMX]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kLogLevelPerformance
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];
    [monitor release];
    monitor = nil;
    /*
    if(!stopScheduling)
        [self scheduleSMXPing];
     */
}
@end
