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
@property(nonatomic,strong)NSString *ObjectFieldname;
-(NSString *)loadURL:(WizardComponentModel *)model;
-(NSDictionary *)fetchWebServiceParams:(WizardComponentModel *)model withparams:(NSArray *)params;
-(id)init;
@end
