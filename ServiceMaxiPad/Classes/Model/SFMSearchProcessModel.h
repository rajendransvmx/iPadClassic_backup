//
//  BaseSFM_Search_Process.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFMSearchProcessModel.h
 *  @class  SFMSearchProcessModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

/*
 
 TEMP : sample search process response
 
 Id = a17K0000002VK1HIAW;
 Name = "PN-0000005603";
 RecordTypeId = 012K00000000P4XIAU;
 "SVMXC__Active__c" = 0;
 "SVMXC__IsDefault__c" = 0;
 "SVMXC__IsStandard__c" = 0;
 "SVMXC__Name__c" = ProductStock;
 "SVMXC__ProcessID__c" = ProductStock;
 "SVMXC__Rule_Type__c" = "SRCH_NAMED_SEARCH";
 attributes =     {
 type = "SVMXC__ServiceMax_Processes__c";
 url = "/services/data/v31.0/sobjects/SVMXC__ServiceMax_Processes__c/a17K0000002VK1HIAW";
 };
 
 But we are storing only whatever is required.
 */


@class SFMSearchProcessModel;

// 029883
typedef enum : NSUInteger {
    SearchCriteriaContains,
    SearchCriteriaExactMatch,
    SearchCriteriaEndsWith,
    SearchCriteriaStartsWith
} SearchCriteria;


@interface SFMSearchProcessModel : NSObject
/**
 string which represents local id of the search process
 */
@property (nonatomic, strong) NSString *localId;

/**
 string which represents salesforce id of the search process
 */
@property (nonatomic, strong) NSString *identifier;

/**
 string which represents name of the search process
 */
@property (nonatomic, strong) NSString *name;

/**
 string which represents process name of the search process
 */
@property (nonatomic, strong) NSString *processName;

/**
 string which represents description of search process
 */
@property (nonatomic, strong) NSString *processDescription;

/**
 Array of search objects
 */
@property (nonatomic, strong) NSArray *searchObjects;

@property (nonatomic, strong) NSString *searchCriteria;


+ (NSDictionary *) getMappingDictionary;
@end