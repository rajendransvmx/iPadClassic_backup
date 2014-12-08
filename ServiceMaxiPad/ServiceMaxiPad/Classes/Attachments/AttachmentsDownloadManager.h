//
//  DocumentsDownloadManager.h
//  ServiceMaxiPad
//
//  Created by Anoop on 11/3/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AttachmentDownloadError) {
    AttachmentDownloadErrorUserCancelled = 1041,
    AttachmentDownloadErrorUserForceQuit = 1042
};

extern NSString * const kDocumentsDownloadKeyDocuments;
extern NSString * const kDocumentsDownloadKeyImagesVideos;
extern NSString * const kDocumentsDownloadKeyContentLength;
extern NSString * const kDocumentsDownloadKeyFileType;
extern NSString * const kDocumentsDownloadKeyFileId;
extern NSString * const kDocumentsDownloadKeyFileName;
extern NSString * const kDocumentsDownloadKeyFileExtension;
extern NSString * const kDocumentsDownloadKeyProgress;
extern NSString * const kDocumentsDownloadKeyURL;
extern NSString * const kDocumentsDownloadKeyStartTime;
extern NSString * const kDocumentsDownloadKeyTask;
extern NSString * const kDocumentsDownloadKeyStatus;
extern NSString * const kDocumentsDownloadKeyDetails;
extern NSString * const kDocumentsDownloadKeyResumeData;
extern NSString * const kDocumentsDownloadKeyErrorCode;

extern NSString * const RequestStatusDownloading;
extern NSString * const RequestStatusPaused;
extern NSString * const RequestStatusFailed;


@protocol DocumentsDownloadDelegate <NSObject>

/**A delegate method called each time whenever new download task is start downloading
 */
- (void)documentDownloadRequestStarted:(NSDictionary *)downloadInfoDict;

/**A delegate method called each time whenever new download task progress downloading
 */
- (void)documentDownloadRequestProgress:(NSDictionary *)downloadInfoDict;

/**A delegate method called each time whenever any download task is finished successfully
 */
- (void)documentDownloadRequestFinished:(NSDictionary *)downloadInfoDict;

/**A delegate method called each time whenever any download task is cancelled by the user
 */
- (void)documentDownloadRequestCanceled:(NSDictionary *)downloadInfoDict;

@end


@protocol ImagesVideosDownloadDelegate <NSObject>

/**A delegate method called each time whenever new download task is start downloading
 */
- (void)imagesVideosDownloadRequestStarted:(NSDictionary *)downloadInfoDict;

/**A delegate method called each time whenever new download task progress downloading
 */
- (void)imagesVideosDownloadRequestProgress:(NSDictionary *)downloadInfoDict;

/**A delegate method called each time whenever any download task is finished successfully
 */
- (void)imagesVideosDownloadRequestFinished:(NSDictionary *)downloadInfoDict;

/**A delegate method called each time whenever any download task is cancelled by the user
 */
- (void)imagesVideosDownloadRequestCanceled:(NSDictionary *)downloadInfoDict;

@end




@class AttachmentTXModel;

@interface AttachmentsDownloadManager : NSObject
/** The dictionary that holds valueMap for media(Images/videos) types.
 */
@property(nonatomic, strong) NSDictionary *imgDict;
@property(nonatomic, strong) NSDictionary *videoDict;

/** The dictionary that holds the information about all downloading tasks.
 */
@property(nonatomic, strong) NSMutableDictionary *downloadingDictionary;

/**A session manager for background downloading.
 */
@property(nonatomic, strong) NSURLSession *sessionManager;
@property(nonatomic, weak) id<DocumentsDownloadDelegate> documentsDelegate;
@property(nonatomic, weak) id<ImagesVideosDownloadDelegate> imagesVideosDelegate;


+ (AttachmentsDownloadManager *)sharedManager;

- (NSURLSession *)backgroundSession;

+ (NSString*)attachmentIdFromDownloadInfo:(NSMutableDictionary*)downloadDict;

/**A method for adding new download task.
 @param AttachmentTXModel
 */
- (void)addDocumentAttachmentForDownload:(AttachmentTXModel *)attachmentModel;

/**A method for restoring any interrupted download tasks e.g user force quits the app or any network error occurred.
 */
- (void)populateOtherDownloadTasks;

/**A method for pausing all downloads
 */
- (void)pauseAllDownloads;

/**A method for resuming all paused downloads
 */
- (void)resumeAllDownloads;

/**A method for cancelling all paused downloads
 */
- (void)cancelAllDownloads;

- (void)cancelDownloadWithId:(NSString*)attachmentId;

- (void)pauseOrRetry:(NSString*)attachmentId;

@end
