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

@protocol PageEditViewControllerDelegate <NSObject>

- (void)reloadData;
- (void)loadSFMViewPageLayoutForRecordId:(NSString *)recordId andObjectName:(NSString *)objectName;


@end

@interface PageEditViewController : SMSplitViewController

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


@end


