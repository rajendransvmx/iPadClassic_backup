//
//  SyncManagerTests.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 11/24/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SyncManager.h"
#import "PlistManager.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "SNetworkReachabilityManager.h"
#import "DateUtil.h"

@interface SyncManagerTests : XCTestCase <FlowDelegate> {
    XCTestExpectation *expectation;
}

// IPAD-4585
@property (nonatomic, strong) NSString *profileType;
@property (nonatomic, readwrite) BOOL isRequestTimedOut;
@property (nonatomic, readwrite) NSInteger syncProfileDataSize;
@property (nonatomic, strong) NSString *endTimeRequestId;
@property (nonatomic, readwrite) BOOL isSyncProfileEnabled;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation SyncManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void)testStartSyncProfilingForStartTime {
    expectation = [self expectationWithDescription:@"Test Expectations"];
     [self setUpRequestIdForSyncProfiling:@"6222ACB1-5C48-427A-83A1-0109609F93C0"];
    [self testInitiateSyncProfiling:kSPTypeStart];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

-(void)testStartSyncProfilingForEndTime {
    expectation = [self expectationWithDescription:@"Test Expectations"];
     [self setUpRequestIdForSyncProfiling:@"6222ACB1-5C48-427A-83A1-0109609F93C0"];
    [self testInitiateSyncProfiling:kSPTypeEnd];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

}

-(void)testInitiateSyncProfiling:(NSString *)profileType {
    
    if ([self testIsSyncProfilingEnabled])
    {
        self.profileType = profileType;
        
        if ([profileType isEqualToString:kSPTypeStart])
        {
            if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
            {
                [self performSyncProfiling];
            }
        }
        else if ([profileType isEqualToString:kSPTypeEnd])
        {            
            if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
            {
                [self performSyncProfiling];
            }
            else
            {
                NSString *currentDate = [DateUtil getCurrentDateForSyncProfiling];
                [self pushSyncProfileInfoToUserDefaultsWithValue:currentDate forKey:kSPSyncTime];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectivityChanged) name:kNetworkConnectionChanged object:nil];
            }
        }
    }
    else {
        XCTAssert(@"sync profiling disabled");
        [expectation fulfill];
    }
}

-(BOOL)testIsSyncProfilingEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isSyncProfileEnabled = [[userDefaults objectForKey:kSyncProfileEnabled] boolValue];
    return isSyncProfileEnabled;
}

-(void)pushSyncProfileInfoToUserDefaultsWithValue:(NSString *)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

-(void)performSyncProfiling {
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeSyncProfiling requestParam:nil callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
}

-(void)flowStatus:(id)status {
    if ([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *wsResponseStatus = (WebserviceResponseStatus*)status;
        switch (wsResponseStatus.category)
        {
            case CategoryTypeSyncProfiling:
            {
                XCTAssert(wsResponseStatus.syncStatus == SyncStatusSuccess, @"sync success");
                [expectation fulfill];
            }
                break;
            default:
                break;
        }
    }
}

-(void)networkConnectivityChanged {
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
        [self performSyncProfiling];
    }
}

-(void)setUpRequestIdForSyncProfiling:(NSString *)requestId {
    // IPAD-4355
    self.isRequestTimedOut = NO;
    [self pushSyncProfileInfoToUserDefaultsWithValue:requestId forKey:kSyncprofileReqId];
}

@end
