//
//  SFMCustomActionHelper.h
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizardComponentModel.h"
#import "SFMPage.h"

@interface SFMCustomActionHelper : NSObject

@property(nonatomic, strong)SFMPage *sfmPageModel;
@property(nonatomic, strong)WizardComponentModel *wizardCompModel;

-(NSString *)loadURL;
-(id)initWithSFMPage:(SFMPage *)sfmPageModel
               wizardComponent:(WizardComponentModel*)wizardModel;
@end
