//
//  SFMViewPageManager.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageManager.h"
#import "SFMPageViewModel.h"


@interface SFMViewPageManager : SFMPageManager

@property(nonatomic, strong) SFMPageViewModel *sfmPageView;

- (id)initWithObjectName:(NSString *)objectName
                recordId:(NSString *)recordLocalId;

- (SFMPageViewModel *) sfmPageView;

@end
