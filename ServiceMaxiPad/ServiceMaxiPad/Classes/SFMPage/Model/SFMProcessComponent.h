//
//  SFMProcessComponent.h
//  ServiceMaxMobile
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SFMProcessComponent.h
 *  @class  SFMProcessComponent
 *
 *  @brief
 *
 *   This is a model class which holds all the info related to SFM Process components. Process Components will be having the information like expression, value mapping, field mapping etc
 *
 *  @author Aparna
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@interface SFMProcessComponent : NSObject

@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *processId;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *expressionId;
@property(nonatomic, strong) NSString *layoutId;
@property(nonatomic, strong) NSString *valueMappingId;
@property(nonatomic, strong) NSString *processNodeId;
@property(nonatomic, strong) NSString *objectMappingId;
@property(nonatomic, strong) NSString *docTemplateId;
@property(nonatomic, strong) NSString *sortingOrder;

- (id)initWithDictionary:(NSDictionary *)processCompDict;

@end
