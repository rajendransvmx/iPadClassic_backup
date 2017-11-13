//
//  SFMCustomActionTests.m
//  ServiceMaxiPadTests
//
//  Created by Vincent Sagar on 13/11/17.
//  Copyright © 2017 ServiceMax Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ModifiedRecordModel.h"
#import "SFMCustomActionWebServiceHelper.h"
#import "CustomActionXMLRequestHelper.h"
#import "SFMPage.h"
#import "CustomActionWebserviceModel.h"
#import "SFMPageEditManager.h"
#import "CustomActionsDAO.h"
#import "CustomActionRequestService.h"
#import "FactoryDAO.h"
@interface SFMCustomActionTests : XCTestCase{
    ModifiedRecordModel *testSyncRecord;
    ModifiedRecordModel *unModifiedSyncRecord;
    ModifiedRecordModel *childSyncRecord;
    SFMPage *sfmPage;

}
@property (nonatomic, retain) CustomActionWebserviceModel *webServiceModel;
@property (nonatomic, strong) SFMCustomActionWebServiceHelper *customActionHelper;
@property (nonatomic, strong) CustomActionXMLRequestHelper * soapRequest;
@end

@implementation SFMCustomActionTests

- (void)setUp {
    [super setUp];

    
    testSyncRecord=[[ModifiedRecordModel alloc]init];
    testSyncRecord.recordType = @"MASTER";
    testSyncRecord.objectName = @"MyObject";
    testSyncRecord.parentLocalId= @"";
    testSyncRecord.parentObjectName=@"";
    testSyncRecord.customActionFlag=TRUE;
    testSyncRecord.sfId=@"parent1";
    testSyncRecord.operation=@"INSERT";
    testSyncRecord.fieldsModified = nil;
    
    
    unModifiedSyncRecord=[[ModifiedRecordModel alloc]init];
    unModifiedSyncRecord.recordType = @"MASTER";
    unModifiedSyncRecord.objectName = @"MyObject";
    unModifiedSyncRecord.parentLocalId= @"";
    unModifiedSyncRecord.parentObjectName=@"";
    unModifiedSyncRecord.customActionFlag=FALSE;
    unModifiedSyncRecord.sfId=@"parent2";
    unModifiedSyncRecord.operation=@"INSERT";
    unModifiedSyncRecord.fieldsModified = @"{\"AFTER_SAVE\" : {\"Id\" : \"a1L0G000005YTzhUAG\",\"SVMXDEV__Billing_Type__c\"\"Empowerment\"},\"BEFORE_SAVE\" : {\"Id\" : \"a1L0G000005YTzhUAG\",\"SVMXDEV__Billing_Type__c\" : \"Courtesy\"}}";
    
    
    childSyncRecord=[[ModifiedRecordModel alloc]init];
    childSyncRecord.recordType = @"DETAIL";
    childSyncRecord.objectName = @"MyChildObject";
    childSyncRecord.parentLocalId= @"parent1";
    childSyncRecord.parentObjectName=@"";
    childSyncRecord.customActionFlag=FALSE;
    childSyncRecord.sfId=@"child1";
    childSyncRecord.operation=@"UPDATE";
    childSyncRecord.fieldsModified = @"{\"AFTER_SAVE\" : {\"Id\" : \"a1L0G000005YTzhUAG\",\"SVMXDEV__Billing_Type__c\"\"Empowerment\"},\"BEFORE_SAVE\" : {\"Id\" : \"a1L0G000005YTzhUAG\",\"SVMXDEV__Billing_Type__c\" : \"Courtesy\"}}";
    // Put setup code here. This method is called before the invocation of each test method in the class.
}
- (void)testCustomActionRequestHelper{
    CustomActionXMLRequestHelper *helper=[[CustomActionXMLRequestHelper alloc]init];
    NSString * params = [helper getSFMCustomActionsParamsRequest];
    XCTAssertNotNil(params,@" Valid Parameters string for the process");
}

-(void)testDeleteUsingCustomActionDAO{
    id <CustomActionsDAO> customActionParamsService = [FactoryDAO serviceByServiceType:ServiceTypeCustomActionRequestParams];
    [customActionParamsService deleteUpdatedRecordsForModifiedRecordModel:testSyncRecord];
    
     NSArray *recordArray = [customActionParamsService recordForRecordId:testSyncRecord.recordLocalId];
    
    XCTAssertTrue(recordArray.count==0 , @"Records were deleted");
}

-(void)testIftheRecordExists{
    id <CustomActionsDAO> customActionParamsService = [FactoryDAO serviceByServiceType:ServiceTypeCustomActionRequestParams];
    BOOL isParentExists = [customActionParamsService doesRecordExistForId:@"parent1" andOperationType:@"INSERT"];
    
    BOOL isChildExists = [customActionParamsService doesRecordExistForId:@"child1" andOperationType:@"INSERT" andparentID:@"parent1"];
    XCTAssert(isChildExists ,@"Child record exists");
    XCTAssert(isParentExists ,@"Parent record exists");
}

-(void)testCustomActionRecordInsert{
    id <CustomActionsDAO>customActionRequestService = [FactoryDAO serviceByServiceType:ServiceTypeCustomActionRequestParams];
    
    [customActionRequestService saveRecordModel:testSyncRecord];
    
    [customActionRequestService updateFieldsModifed:testSyncRecord];
    
    BOOL doesExist =   [customActionRequestService doesRecordExistForId:testSyncRecord.recordLocalId];
    XCTAssert(doesExist ,@"Record Exist and inserted successfully");
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

@end
