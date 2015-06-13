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

-(void)loadURL:(NSString *)url withParams:(NSArray *)params;
-(void)callWebService:(WizardComponentModel *)model withparams:(NSArray *)params;
-(id)init;
@end
