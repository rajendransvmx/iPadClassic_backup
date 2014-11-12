//
//  BaseSFProcessComponent.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFProcessComponentModel.h
 *  @class  SFProcessComponentModel
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

@interface SFProcessComponentModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic) NSInteger sequence;



@property(nonatomic, strong) NSString *processId;
@property(nonatomic, strong) NSString *layoutId;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *sourceObjectName;
@property(nonatomic, strong) NSString *expressionId;
@property(nonatomic, strong) NSString *objectMappingId;
@property(nonatomic, strong) NSString *componentType;
@property(nonatomic, strong) NSString *parentColumnName;
@property(nonatomic, strong) NSString *valueMappingId;
@property(nonatomic, strong) NSString *sortingOrder;
@property(nonatomic, strong) NSString *processNodeId;
@property(nonatomic, strong) NSString *docTemplateDetailId;
@property(nonatomic, strong) NSString *targetObjectLabel;
@property(nonatomic, strong) NSString *sfId;
@property(nonatomic, strong )NSString *parentObjectId;
@property(nonatomic, strong )NSString *parentObjectName;
@property(nonatomic,assign)BOOL enableAttachment;

- (id)init;
+ (NSDictionary *)getMappingDictionary;


@end