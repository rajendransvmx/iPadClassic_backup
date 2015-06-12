//
//  BaseSFWizardComponent.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   WizardComponentModel.h
 *  @class  WizardComponentModel
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


@interface WizardComponentModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic) double sequence;

@property(nonatomic, copy) NSString *wizardId;
@property(nonatomic, copy) NSString *wizardComponentId;
@property(nonatomic, copy) NSString *actionDescription;
@property(nonatomic, copy) NSString *expressionId;
@property(nonatomic, copy) NSString *processId;
@property(nonatomic, copy) NSString *actionType;
@property(nonatomic, copy) NSString *performSync;
@property(nonatomic, copy) NSString *className;
@property(nonatomic, copy) NSString *methodName;
@property(nonatomic, copy) NSString *wizardStepId;
@property(nonatomic, copy) NSString *actionName;
@property(nonatomic, copy) NSString *customActionType;
@property(nonatomic, copy) NSString *customUrl;
@property(nonatomic, copy) NSString *ProcessId_c;

@property(nonatomic,assign) BOOL isEntryCriteriaMatching; 


- (id)init;

+ (NSDictionary *)getMappingDictionary;

+ (NSDictionary *) getMappingDictionaryForWizardLayoutClassName;

+ (NSDictionary *) getMappingDictionaryForWizardLayoutUrl ;

@end