//
//  PageEditViewController.h
//  ServiceMaxMobile
//
//  Created by shravya on 29/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"
#import "SFMPage.h"
#import "SFMPageEditManager.h"
#import "PriceCalculationManager.h"
#import "BusinessRuleManager.h"
#import "LinkedProcess.h"

@protocol PageEditViewControllerDelegate <NSObject>

@optional
- (void)loadSFMViewPageLayoutForRecordId:(NSString *)recordId andObjectName:(NSString *)objectName;


- (void)resignAnyFirstResponders;
- (void)reloadData;

- (BOOL)isEntrtCriteriaMatchesForProcessId:(LinkedProcess *)process;
- (void)invokeLinkedSFMEDitProcess:(LinkedProcess *)process;
- (void)loadLinkedSFMViewProcess:(NSString *)recordId andObjectName:(NSString *)objectName;
- (void)refreshEventInCalendarView;

@end

@interface PageEditViewController : SMSplitViewController <PriceCalculationManagerDelegate,BusinessRuleManagerDelegate>

@property (assign, nonatomic)  id <PageEditViewControllerDelegate> editViewControllerDelegate;

/* This initialization for EDIT process */
- (id)initWithProcessId:(NSString *)processId
         withObjectName:(NSString *)objectName
           andRecordId:(NSString *)recordId;

- (id)initWithProcessId:(NSString *)processId
       sourceObjectName:(NSString *)srcObjName
      andSourceRecordId:(NSString *)srcRecordId;

/* This initialization for CREATE NEW process */
- (id)initWithProcessId:(NSString *)processId
          andObjectName:(NSString *)objectName;


/*Source To Target Child*/
- (id)initWithProcessIdForSTC:(NSString *)processId
               withObjectName:(NSString *)objectName
                  andRecordId:(NSString *)recordId;

/*Linked SFM*/
- (void)showLinkedSFMProcessForProcessInfo:(LinkedProcess *)process;
-(void)refreshBizRuleData;
@end


