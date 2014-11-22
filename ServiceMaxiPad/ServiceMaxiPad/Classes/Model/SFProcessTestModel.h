//
//  BaseSFProcess_test.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFProcessTestModel.h
 *  @class  SFProcessTestModel
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

@interface SFProcessTestModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic) BOOL enable_attachment;

@property(nonatomic, strong) NSString *processId;
@property(nonatomic, strong) NSString *layoutId;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *expressionId;
@property(nonatomic, strong) NSString *objectMappingId;
@property(nonatomic, strong) NSString *componentType;
@property(nonatomic, strong) NSString *parentColumn;
@property(nonatomic, strong) NSString *valueId;
@property(nonatomic, strong) NSString *parentObject;
@property(nonatomic, strong) NSString *sortingOrder;
@property(nonatomic, strong) NSString *processNodeId;
@property(nonatomic, strong) NSString *docTemplateDetailId;
@property(nonatomic, strong) NSString *targetObjectLabel;
@property(nonatomic, strong) NSString *sfID;

- (id)init; 
- (id)initWithArray:(NSArray *)dataArray; /* initialize the values to the respective property using array*/
@end