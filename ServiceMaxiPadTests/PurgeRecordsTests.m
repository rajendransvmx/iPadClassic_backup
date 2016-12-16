//
//  PurgeRecordsTests.m
//  ServiceMaxiPad
//
//  Created by Sruthi Ramakrishnan on 16/12/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SNetworkReachabilityManager.h"
#import "SyncConstants.h"
#import "TaskModel.h"
#import "TaskManager.h"
#import "TaskGenerator.h"
#import "WebserviceResponseStatus.h"
#import "FlowNode.h"
#import "SuccessiveSyncManager.h"

@interface PurgeRecordsTests : XCTestCase <FlowDelegate>

@end

@implementation PurgeRecordsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testInitiatePurgeRecords {

    NSMutableDictionary *whatIdDict = [NSMutableDictionary new];
    [whatIdDict setObject:@"a1fJ0000001oSYDIA2" forKey:@"SVMXDEV__Service_Order__c"];
    [whatIdDict setObject:@[@"a1dJ0000000zwZRIAY", @"a1dJ0000000zwZQIAY"] forKey:@"SVMXDEV__Service_Order_Line__c"];
    [[SuccessiveSyncManager sharedSuccessiveSyncManager] setWhatIdsToDelete:whatIdDict];
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable] && [[SuccessiveSyncManager sharedSuccessiveSyncManager] whatIdsToDelete].count > 0)
    {
        [self performPurgeRecords];
    }

}

-(void)performPurgeRecords {
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeOneCallDataSync requestParam:nil callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
}

-(void)flowStatus:(id)status {
    if ([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *wsResponseStatus = (WebserviceResponseStatus*)status;
        switch (wsResponseStatus.category)
        {
            case CategoryTypeOneCallDataSync:
            {
                XCTAssert(wsResponseStatus.syncStatus == SyncStatusSuccess, @"sync success");
            }
                break;
            default:
                break;
        }
    }
}

@end
