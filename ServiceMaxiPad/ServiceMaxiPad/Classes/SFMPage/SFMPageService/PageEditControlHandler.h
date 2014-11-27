//
//  PageEditControlHandler.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 08/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPage.h"
#import "SFMPageEditManager.h"
#import "PageEditControlDelegate.h"

@interface PageEditControlHandler : NSObject <PageEditControlDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong)SFMPage *sfmPage;
@property (nonatomic, strong)SFMPageEditManager *pageManager;
@property (nonatomic, assign)BOOL isChild;
@property (nonatomic, weak)id  viewControllerDelegate;

- (void)showPopoverForView:(id)view indexPath:(NSIndexPath *)indexPath
                     field:(SFMPageField *)pageField
                recordObjectName:(NSString *)objectName;
- (NSArray *)dependentPicklistsForField:(NSString *)fieldName indexPath:(NSIndexPath *)indexPath;
- (void)dismissPopover;

@end
