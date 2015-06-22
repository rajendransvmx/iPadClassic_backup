//
//  SFMCustomActionWebServiceHelper.h
//  ServiceMaxiPad
//
//  Created by Apple on 22/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizardComponentModel.h"

@interface SFMCustomActionWebServiceHelper : NSObject

@property(nonatomic,strong)NSString *className;
@property(nonatomic,strong)NSString *methodName;
@property(nonatomic,strong)NSDictionary *ParametersWithKey;
-(void)addModelToTaskMaster;
+(void)setwizardComponent:(WizardComponentModel *)WizardComponentModel;
+(WizardComponentModel *)getWizardComponentModel;
@end
