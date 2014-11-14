//
//  BaseSFWizard.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFWizardModel.h
 *  @class  SFWizardModel
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

@interface SFWizardModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic, copy) NSString *objectName;
@property(nonatomic, copy) NSString *wizardId;
@property(nonatomic, copy) NSString *expressionId;
@property(nonatomic, copy) NSString *wizardDescription;
@property(nonatomic, copy) NSString *wizardName;

@property(nonatomic) NSInteger wizardLayoutColumn;
@property(nonatomic) NSInteger wizardLayoutRow;

@property(nonatomic,strong) NSMutableArray *wizardComponents;


- (id)init;

+ (NSDictionary *) getMappingDictionary;

+ (NSDictionary *) getMappingDictionaryForWizardLayout;

@end