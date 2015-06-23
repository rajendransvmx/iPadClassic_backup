//
//  SFMCustomActionWebServiceHelper.h
//  ServiceMaxiPad
//
//  Created by Apple on 22/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizardComponentModel.h"
#import "CustomActionWebserviceModel.h"

@interface SFMCustomActionWebServiceHelper : NSObject

@property(nonatomic,strong)NSString *className;
@property(nonatomic,strong)NSString *methodName;
@property(nonatomic,strong)NSString *objectName;
@property(nonatomic,strong)NSString *objectFieldId;
@property(nonatomic,strong)NSString *objectFieldname;
-(void)addModelToTaskMaster;
+(void)setcustomActionWebserviceModel:(CustomActionWebserviceModel *)WizardComponentModel;
+(CustomActionWebserviceModel *)getCustomActionWebServiceHelper;
@end
