//
//  UTStringUtil.m
//  ServiceMaxiPad
//
//  Created by Anoop on 6/10/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "StringUtil.h"
#import "DatabaseConstant.h"

@interface UTStringUtil : XCTestCase


@end

@implementation UTStringUtil

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void)testStringEmpty
{
    XCTAssertTrue([StringUtil checkIfStringEmpty:@""], @"String Empty method pass");
    XCTAssertTrue([StringUtil checkIfStringEmpty:@"  "], @"String Empty method pass");
    XCTAssertTrue([StringUtil checkIfStringEmpty:nil], @"String Empty method pass");
    XCTAssertTrue([StringUtil checkIfStringEmpty:NULL], @"String Empty method pass");
}

-(void)testisValidOrZeroLengthString
{
    XCTAssertFalse([StringUtil isValidOrZeroLengthString:nil], @"String is not of valid Length");
    XCTAssertFalse([StringUtil isValidOrZeroLengthString:NULL], @"String is not of valid Length");
}

-(void)testStringNotNull
{
    XCTAssert([StringUtil isStringNotNULL:@"Test"], @"To check Whether String is not NULL");
    XCTAssertFalse([StringUtil isStringNotNULL:@"null"], @"Return False on NULL ");
}

-(void)testContainsString
{
    XCTAssertFalse([StringUtil containsString:@"Hi" inString:@"Test"], @"Should return false");
    XCTAssertTrue([StringUtil containsString:@"Hi" inString:@"Hi Test"], @"Should return true");
}

-(void)testConcatnateString
{
    NSArray *testArray = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
    XCTAssertNotNil([StringUtil getConcatenatedStringFromArray:testArray withSingleQuotesAndBraces:YES], @"Should return String");
    XCTAssertNil([StringUtil getConcatenatedStringFromArray:nil withSingleQuotesAndBraces:YES], @"nil");
}

-(void)testIsTrue
{
    XCTAssertTrue([StringUtil isItTrue:@"1"], @"Should return true");
    XCTAssertTrue([StringUtil isItTrue:@"true"], @"Should return true");
    XCTAssertFalse([StringUtil isItTrue:@"0"], @"Should return false");
    XCTAssertFalse([StringUtil isItTrue:@"false"], @"Should return false");
}

-(void)testStringToSplit
{
    NSString *stringTest = @"Test Test Test";
    XCTAssertNotNil([StringUtil splitString:stringTest byString:@" "], @"Array should hav some value");
}

-(void)testAppendOrgNameSpace
{
    XCTAssertNotNil([StringUtil appendOrgNameSpaceToString:@"_Test__C"], @"Org Name Space Should get appended");
}

-(void)testStringNumber
{
    XCTAssertTrue([StringUtil isStringNumber:@"3"],@"True, String is number");
    XCTAssertFalse([StringUtil isStringNumber:@"OOPS"],@"False, String is not number");
}

/*
- (void)testPerformanceExample {

    [self measureBlock:^{
        [StringUtil checkIfStringEmpty:@"      "];
    }];
}
*/

@end
