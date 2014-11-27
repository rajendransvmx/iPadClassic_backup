//
//  DocumentsViewController.h
//  ServiceMaxiPad
//
//  Created by Anoop on 10/27/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachmentsDownloadManager.h"
#import "AttachmentWebView.h"
#import "ChildEditViewController.h"

@interface DocumentsViewController : ChildEditViewController <UITableViewDataSource, UITableViewDelegate, DocumentsDownloadDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate, AttachmentWebviewdelegate>

@property (strong, nonatomic) IBOutlet UITableView *documentsTableView;

@property (strong, nonatomic) IBOutlet UIView *viewProcessHeaderView;
@property (strong, nonatomic) IBOutlet UIButton *selectButton;

@property (strong, nonatomic) IBOutlet UIView *editProcessHeaderView;
@property (strong, nonatomic) IBOutlet UILabel *editProcessHeaderLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic, copy) NSString *recordId;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *parentObjectName;
@property (nonatomic, copy) NSString *parentSFObjectName;
@property (nonatomic, assign) BOOL isViewMode;


- (IBAction)selectAction:(UIButton *)sender;
- (IBAction)cancelAction:(UIButton *)sender;
- (IBAction)shareAction:(UIButton *)sender;
- (IBAction)deleteAction:(UIButton *)sender;


@end
