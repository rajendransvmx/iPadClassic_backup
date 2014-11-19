//
//  BaseDOC_TEMPLATE_DETAILS.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DocTemplateDetailModel.h
 *  @class  DocTemplateDetailModel
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

@interface DocTemplateDetailModel : NSObject

@property(nonatomic, strong) NSString *docTemplate;
@property(nonatomic, strong) NSString *docTemplateDetailId;
@property(nonatomic, strong) NSString *headerReferenceField;
@property(nonatomic, strong) NSString *alias;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *soql;
@property(nonatomic, strong) NSString *docTemplateDetailUniqueId;
@property(nonatomic, strong) NSString *fields;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *idTable;

- (id)init;

- (void)explainMe;

+ (NSDictionary*)getMappingDictionary;

@end