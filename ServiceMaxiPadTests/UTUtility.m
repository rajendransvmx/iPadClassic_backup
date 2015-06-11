//
//  UTUtils.m
//  ServiceMaxiPad
//
//  Created by Anoop on 6/10/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SVMXSystemConstant.h"
#import "Utility.h"

@interface UTUtility : XCTestCase

@end

@implementation UTUtility

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDateUtility
{
    XCTAssertNil([Utility getDateFromString:@"9237293bb0023@@@"], @"Invalid input should return nil");
    XCTAssertNotNil([Utility getDateFromString:@"2008/11/22"], @"Valid input should return Date");
}

- (void)testOpDocDate
{
    XCTAssertNotNil([Utility currentDateInGMTForOPDoc], @"Should return date for OPDoc");
}

- (void)testTodayInGMT
{
    XCTAssertNotNil([Utility todayDateInGMT], @"Should return today's date in GMT");
}

- (void)testCheckDate
{
    XCTAssertFalse([Utility checkIfDate:[NSDate date] betweenDate:[NSDate date] andEndDate:[NSDate date]], @"False current date doesnt lie between");
}

- (void)testURLParameter
{
    XCTAssertNotNil([Utility getTheParameterFromUrlParameterString:@"3638361#$#%$^$@dsdhjjdhjKKK"], @"Should return, No exception of bad url!!");
}

- (void)testSetPriceDownloadStatus
{
    XCTAssertNoThrow([Utility setPriceDownloadStatus:@"1"], @"Should save");
}

- (void)testFormatData
{
    XCTAssertNotEqual([Utility formattedFileSize:2048], @"1.0 MB", @"Should fail");
}


@end
