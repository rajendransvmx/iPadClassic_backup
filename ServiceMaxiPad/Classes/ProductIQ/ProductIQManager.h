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
#import "SFObjectModel.h"
#import "FlowDelegate.h"

@interface ProductIQManager : NSObject <FlowDelegate>


@property(nonatomic, strong) NSMutableArray *recordIds;
@property(nonatomic, assign) BOOL isProdIQSyncInProgress;
@property(nonatomic, assign) NSString *prodIQTaskId;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

+ (instancetype)sharedInstance;

- (BOOL)isProductIQEnabledForSFMPage:(SFMPageViewModel*)sfmPageView;
- (NSMutableArray*)addProductIQWizardForAllWizardArray:(NSMutableArray*)allWizards withWizardComponetService:(SFMWizardComponentService*)wizardComponentService;
- (BOOL)isProductIQEnabledForStandaAloneObject:(SFObjectModel*)sfObject;
- (BOOL)loadDataIntoInstalledBaseObject;
- (BOOL)isProductIQSettingEnable;
- (NSArray *)getProdIQRelatedObjects;
- (NSDictionary *)getProdIQTxFetcRequestParamsForRequestCount1:(NSArray *)fileds andTableName:(NSString *)tableName andId:(NSString *)sfId ;

-(void)initiateProdIQDataSync;
-(void)cancelProdIQDataSync;

@end
