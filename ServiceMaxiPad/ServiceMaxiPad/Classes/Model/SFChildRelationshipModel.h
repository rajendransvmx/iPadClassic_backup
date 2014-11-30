//
//  BaseSFChildRelationship.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//


/**
 *  @file   SFChildRelationshipModel.h
 *  @class  SFChildRelationshipModel
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


@interface SFChildRelationshipModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic, strong) NSString *objectNameParent;
@property(nonatomic, strong) NSString *objectNameChild;
@property(nonatomic, strong) NSString *fieldName;

- (id)init;
- (id)initWithDictionary:(NSDictionary *)jsonDictionary;


@end