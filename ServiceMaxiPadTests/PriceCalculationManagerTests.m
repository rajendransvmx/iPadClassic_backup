//
//  PriceCalculationManagerTests.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 12/27/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SFMPageViewManager.h"
#import "PriceCalculationManager.h"
#import "SMAppDelegate.h"

@interface PriceCalculationManagerTests : XCTestCase <PriceCalculationManagerDelegate>

@property (nonatomic, strong) PriceCalculationManager *priceCalculationManager;

@end

@implementation PriceCalculationManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testInvokeGetPrice {
    NSString *objName = ORG_NAME_SPACE@"__Service_Order__c";
    NSString *recordId = @"7E793861-1EE2-40BC-A9C9-0016AE20AE97";
    SFMPageViewManager *viewPageManager = [[SFMPageViewManager alloc]initWithObjectName:objName recordId:recordId];
    SFMPage *sfmPage = viewPageManager.sfmPageView.sfmPage;
    
    SMAppDelegate *appdelegate = (SMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *testView = appdelegate.window.rootViewController.view;
    
    self.priceCalculationManager = [[PriceCalculationManager alloc] initWithCodeSnippetId:@"Standard Get Price" andParentView:testView];
    self.priceCalculationManager.managerDelegate = self;
    [self.priceCalculationManager beginPriceCalculationForTargetRecord:sfmPage];
}

- (void)priceCalculationFinishedSuccessFully:(SFMPage *)sfPage {
    XCTAssert(true);
}

- (void)shouldShowAlertMessage:(NSString *)message {
    
}


@end
