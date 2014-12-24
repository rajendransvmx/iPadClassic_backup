//
//  PageEditMasterViewController.h
//  ServiceMaxMobile
//
//  Created by shravya on 29/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


/**
 *  @file   PageEditMasterViewController.h
 *  @class  PageEditMasterViewController
 *
 *  @brief SFM edit Root View controller
 *
 *   Responsible as the master for SFM edit view controller
 *
 *
 *  @author Krishna shanbhag
 *  @author Shravya S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <UIKit/UIKit.h>
#import "SFMPage.h"
#import "PageEditViewController.h"
#import "SFMPageMasterSectionView.h"

typedef enum SFMPageEditMasterSectionType : NSUInteger
{
    SFMEditPageMasterSectionTypeHeader = 0,
    SFMEditPageMasterSectionTypeChild = 1,
    SFMEditPageMasterSectionTypeAttachment = 2
    
}
SFMPageEditMasterSectionType;

@interface PageEditMasterViewController : UIViewController <PageEditViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,SFMPageMasterSectionViewDelegate>


@property (nonatomic, assign) NSInteger selectedSection;
@property (nonatomic, strong) SFMPageLayout *pageLayout;

@property (nonatomic,strong)  SFMPage *sfmPage;
@property (nonatomic,assign)  id  containerViewControlerDelegate;
@property (retain, nonatomic) IBOutlet UITableView *masterTableView;


- (id)initWithSFPage:(SFMPage *)sfPage;

- (void)selectMasterTableViewCellWithIndexPath:(NSIndexPath*)indexPath;

@end
