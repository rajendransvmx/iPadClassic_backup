//
//  BaseSettingsInfo.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SettingsInfoModel.h
 *  @class  SettingsInfoModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 
 
 
 @author Vipindas Palli
 *
 **/


@interface SettingsInfoModel : NSObject

@property(nonatomic, strong) NSString *Id;
@property(nonatomic) BOOL SVMXC__Active__c;
@property(nonatomic, strong) NSString *SVMXC__Data_Type__c;
@property(nonatomic, strong) NSString *SVMXC__Default_Value__c;
@property(nonatomic, strong) NSString *SVMXC__Description__c;
@property(nonatomic) BOOL SVMXC__IsPrivate__c;
@property(nonatomic) BOOL SVMXC__IsStandard__c;
@property(nonatomic, strong) NSString *SVMXC__Search_Order__c;
@property(nonatomic, strong) NSString *SVMXC__SettingID__c;
@property(nonatomic, strong) NSString *SVMXC__Setting_Type__c;
@property(nonatomic, strong) NSString *SVMXC__Setting_Unique_ID__c;
@property(nonatomic, strong) NSString *SVMXC__Settings_Name__c;
@property(nonatomic, strong) NSString *SVMXC__SubmoduleID__c;
@property(nonatomic, strong) NSString *SVMXC__Submodule__c;
@property(nonatomic, strong) NSString *SVMXC__Values__c;

- (id)init;

@end