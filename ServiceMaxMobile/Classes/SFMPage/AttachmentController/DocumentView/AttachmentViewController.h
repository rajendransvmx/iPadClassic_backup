//
//  AttachmentViewController.h
//  ServiceMaxMobile
//
//  Created by Shravya shridhar on 11/17/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DOWNLOAD_CANCEL_ALERT   57361

//D-00003728
#define COLLECTIONVIEW  @"CollectionView"
#define DOCUMENTVIEW    @"DocumentView"


@interface AttachmentViewController : UIViewController {
    
    NSMutableDictionary *attachmentProgressBarsDictionary;
      NSDictionary *selectAttachmentForCancel;
}

@property(nonatomic,retain) NSMutableDictionary *attachmentProgressBarsDictionary;
@property(atomic,retain) NSDictionary *selectAttachmentForCancel;


- (void)addAttachmentDownloadObserver;
- (void)removeAttachmentDownloadObserver;

- (void)addProgressBar:(UIProgressView *)progressBar ForId:(NSString *)attachmentId;
- (void)updateProgressBarWithValue:(CGFloat)value forId:(NSString *)attachmentId;
- (void)removeProgressbarForId:(NSString *)attachmentId;

- (void)updateStatusProgress:(CGFloat)progress forId:(NSString *)attachmentId;
- (void)downloadCompleteForId:(NSString *)attachmentId ;
- (void)downloadFailedForId:(NSString *)attachmentId withError:(NSError *)error;
- (void)showInternetnotAvailableAlert:(NSString *)title ;
- (void)cleanUpBeforeUnload;
- (void)downloadAttachment:(NSDictionary *)attachment;
- (float)getProgress:(NSString *)progressString;

- (void)addDataSyncObserver;
- (void)removeDataSyncObserver;
- (UIProgressView *)createProgressBar;
/*- (void)handleError:(NSError *)error forAttachmentId:(NSString *)attachmentId;*/

- (void)reloadViewData;
- (void)cancelDownloadForAttachment:(NSDictionary *)attachmentDict;

- (void)showAlertForCancelConfirmationAlert:(NSString *)title
                                 andMessage:(NSString *)message;



//Attachment Sharing //Defect 11338
- (void)deleteDuplicateAttachmentsCreated:(NSArray *)fielnames;
- (void)createDuplicateAttachmentFile:(NSMutableDictionary *)attachmentDict;
- (NSMutableArray *)getAttachemntUrlsForSharing:(NSArray *)attachmentFiles;
@end
