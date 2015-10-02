//
//  ProductIQManager.h
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 02/10/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPageViewModel.h"
#import "SFMWizardComponentService.h"


@interface ProductIQManager : NSObject

+ (BOOL)isProductIQEnabledForSFMPage:(SFMPageViewModel*)sfmPageView;
+ (NSMutableArray*)addProductIQWizardForAllWizardArray:(NSMutableArray*)allWizards withWizardComponetService:(SFMWizardComponentService*)wizardComponentService;

@end