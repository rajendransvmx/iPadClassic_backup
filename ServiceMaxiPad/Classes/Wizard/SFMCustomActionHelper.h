//
//  SFMCustomActionHelper.h
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizardComponentModel.h"

@interface SFMCustomActionHelper : NSObject

@property(nonatomic,strong)NSString *objectId;
@property(nonatomic,strong)NSString *objectName;
@property(nonatomic,strong)NSString *URLValue;
@property(nonatomic,strong)NSString *ObjectFieldname;
-(void)loadURL:(WizardComponentModel *)model withParams:(NSArray *)params;
-(void)callWebService:(WizardComponentModel *)model withparams:(NSArray *)params;
-(void)loadApp:(WizardComponentModel *)model withparams:(NSArray *)params;
-(id)init;
@end
