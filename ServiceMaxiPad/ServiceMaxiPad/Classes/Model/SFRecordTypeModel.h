//
//  BaseSFRecordType.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFRecordTypeModel.h
 *  @class  SFRecordTypeModel
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

@interface SFRecordTypeModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic, strong) NSString *recordTypeId;
@property(nonatomic, strong) NSString *objectApiName;
@property(nonatomic, strong) NSString *recordType;
@property(nonatomic, strong) NSString *recordtypeLabel;

- (id)initWithDictionary:(NSDictionary *)jsonDictionary;

@end