//
//  BeforeSaveManager.h
//  ServiceMaxiPad
//
//  Created by Padmashree on 10/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPage.h"

@protocol PageEventProcessManagerDelegate <NSObject>

-(void)pageEventProcessCalculationFinishedSuccessFully:(SFMPage *)sfPage;
-(void)shouldShowAlertMessageForPageEventProcess:(NSString *)message;

@end

@interface PageEventProcessManager : NSObject {
    
}

@property(nonatomic,assign) id <PageEventProcessManagerDelegate>managerDelegate;

-(id)initWithSFMPage:(SFMPage *)aSfmPage;
-(BOOL)pageEventProcessExists;
-(BOOL)startPageEventProcessWithParentView:(UIView *)aView;
-(BOOL)isWebserviceEnabled;
-(BOOL)isBeforeSaveEnabled;
-(BOOL)isAfterSaveInsertEnabled;
-(BOOL)isAfterSaveUpdateEnabled;


@end
