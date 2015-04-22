//
//  SFMPageViewModel.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 20/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLAClock.h"
#import "SFMPage.h"

@interface SFMPageViewModel : NSObject

@property(nonatomic, strong) SFMPage *sfmPage;
@property(nonatomic, strong) SLAClock *slaClock;
@property(nonatomic, strong) NSArray *productHistory;
@property(nonatomic, strong) NSArray *accountHistory;
@property(nonatomic, strong) NSString *contactNUmber;
@property(nonatomic, strong) NSString *contactMail;
@property BOOL isConflictPresent;

@end
