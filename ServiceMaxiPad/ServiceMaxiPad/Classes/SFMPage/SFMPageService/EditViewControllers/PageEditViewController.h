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


@interface PageEditViewController : SMSplitViewController


/* This initialization for EDIT process */
- (id)initWithProcessId:(NSString *)processId
         withObjectName:(NSString *)objectName
           andRecordId:(NSString *)recordId;



@end


@protocol PageEditViewControllerDelegate <NSObject>

- (void)reloadData;

@end