//
//  ImageCollectionView.h
//  ServiceMaxMobile
//
//  Created by Sahana on 07/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imageCollectionViewCell.h"
#import "AttachmentPopoverViewController.h"
#import "AttachmentViewController.h"

@protocol ImageViewControllerDelegate;
@class AppDelegate;

@interface ImageCollectionView : AttachmentViewController <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate,attachmentPopoverControllerDelegate,UIAlertViewDelegate>
{
    AttachmentPopoverViewController *attachmentPopoverController;
    UIPopoverController *popoverController;

}
@property (retain, nonatomic) IBOutlet UIButton *deleteAction;
@property (retain, nonatomic) NSMutableArray * deletedList;
@property (retain, nonatomic) IBOutlet UILabel *title_label;
@property (retain, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionviewFlowLayout;
@property (retain, nonatomic) IBOutlet UICollectionView *CollectionView;
@property (nonatomic, assign) id <ImageViewControllerDelegate> imageViewDelegate;
@property (retain, nonatomic) IBOutlet UIButton *attachButton;
@property (nonatomic , assign) id Sfmdelegate;
@property (retain, nonatomic) IBOutlet UIButton *EditList;
@property (nonatomic, assign) BOOL compressionCompleted;
@property (retain, nonatomic) IBOutlet UIButton *cancel;
@property (retain, nonatomic) IBOutlet UIButton *share;  //D-00003728
@property (retain, nonatomic) IBOutlet UIImageView *addIcon; //D-00003728
@property (retain, nonatomic) NSMutableDictionary * sharingAttachmentList; //D-00003728


- (IBAction)shareAttachment:(id)sender; //D-00003728
- (IBAction)cancelDeletion:(id)sender;
- (IBAction)performDeletion:(id)sender;
- (IBAction)showPopover:(UIButton *)sender;
-(void) dataFromCapturedImage:(NSData *)capturedImageData;

@property (nonatomic,assign) BOOL isViewMode;
@end


#define ROWS_INSECTION  3

@protocol ImageViewControllerDelegate <NSObject>
-(void) ButtonClick:(int)selectedIndex;
-(void) dismissImageView;
-(void) displayAttachment:(NSString * )attachmentId fielName:(NSString *)fielName;
//D-00003728
-(void) displayAttachmentSharingView:(NSArray *)dataSource viewName:(NSString *)view;
@end
