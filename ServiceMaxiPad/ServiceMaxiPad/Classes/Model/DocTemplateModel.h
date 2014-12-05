//
//  BaseDOC_TEMPLATE.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DocTemplateModel.h
 *  @class  DocTemplateModel
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

@interface DocTemplateModel : NSObject

@property(nonatomic, strong) NSString *docTemplateName;
@property(nonatomic, strong) NSString *idTable;
@property(nonatomic, strong) NSString *docTemplateId;
@property(nonatomic) BOOL isStandard;
@property(nonatomic) NSInteger detailObjectCount;
@property(nonatomic, strong) NSString *mediaResources;

- (id)init;

- (void)explainMe;

+ (NSDictionary*)getMappingDictionary;

@end