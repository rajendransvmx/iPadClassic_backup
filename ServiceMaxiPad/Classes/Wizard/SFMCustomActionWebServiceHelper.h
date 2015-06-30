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
#import "SFMPage.h"

@interface SFMCustomActionWebServiceHelper : NSObject

@property(nonatomic, strong) WizardComponentModel *wizardCompModel;
@property(nonatomic,strong) SFMPage *sfmPage;

-(id)initWithSFMPage:(SFMPage *)sfmPageModel
     wizardComponent:(WizardComponentModel*)wizardModel;
-(void)initiateCustomWebServiceWithDelegate:(id)delegate;
-(id)initWithSFMPageRequestData:(NSString *)requestData requestType:(int)requestType;

@end
