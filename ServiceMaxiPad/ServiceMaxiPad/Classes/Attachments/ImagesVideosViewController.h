//
//  ImagesVideosViewController.h
//  ServiceMaxiPad
//
//  Created by Anoop on 10/27/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachmentsDownloadManager.h"
#import "AttachmentWebView.h"
#import "AttachmentPopoverViewController.h"
#import "SVMXImagePickerController.h"
#import "ChildEditViewController.h"

@interface ImagesVideosViewController : ChildEditViewController <UICollectionViewDelegate, UICollectionViewDataSource,UINavigationControllerDelegate, ImagesVideosDownloadDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate, AttachmentWebviewdelegate, AttachmentPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *editProcessHeaderView;
@property (strong, nonatomic) IBOutlet UIView *imageAndVideoView;
@property (strong, nonatomic) IBOutlet UILabel *editProcessHeaderLabel;
@property (strong, nonatomic) IBOutlet UIButton *loadPickerbtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, assign) BOOL isViewMode;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *parentObjectName;
@property (nonatomic, copy) NSString *parentSFObjectName;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIPopoverController *popoverImagePickerController;

- (IBAction)selectAction:(UIButton *)sender;
- (IBAction)cancelAction:(UIButton *)sender;
- (IBAction)shareAction:(UIButton *)sender;
- (IBAction)deleteAction:(UIButton *)sender;
- (IBAction)showimagePicker:(UIButton *)button;

@end
