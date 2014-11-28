//
//  BaseSFNamedSearch.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFNamedSearchModel.h
 *  @class  SFNamedSearchModel
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

@interface SFNamedSearchModel : NSObject

@property(nonatomic) BOOL isDefault;
@property(nonatomic) BOOL isStandard;

@property(nonatomic, strong) NSString *namedSearchId;
@property(nonatomic, strong) NSString *searchSfid;
@property(nonatomic, strong) NSString *searchName;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *searchType;
@property(nonatomic, strong) NSString *noOfLookupRecords;
@property(nonatomic, strong) NSString *defaultLookupColumn;

- (id)init;

- (void)explainMe;

+ (NSDictionary*)getMappingDictionary;

@end