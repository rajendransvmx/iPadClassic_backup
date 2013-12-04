//
//  SMRestAPIManager.h
//  iService
//
//  Created by Vipindas on 11/17/13.
//
//

#import <Foundation/Foundation.h>
#import "SMRestRequest.h"
#import "SVMXSystemConstant.h"
#import "SMAttachmentModel.h"



typedef enum Attachment_Staus
{
    ATTACHMENT_STATUS_EXISTS = 1,
    ATTACHMENT_STATUS_YET_TO_DOWNLOAD = 2,
    ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS = 3,
    ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD = 4,
    ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE = 5,
    ATTACHMENT_STATUS_UPLOAD_IN_PROGRESS = 6,
    ATTACHMENT_STATUS_ERROR_IN_UPLOAD = 7,
    ATTACHMENT_STATUS_UPLOAD_IN_QUEUE = 8,
    ATTACHMENT_STATUS_UNKNOWN = 99,
    
}ATTACHMENT_STATUS;


typedef enum ManagerProcessActionStatus
{
    ActionStatus_Completed = 1,
    ActionStatus_In_Memory = 2,
    ActionStatus_Now_Memory_Next_DB = 3,
    ActionStatus_DB_Upload = 4,
    ActionStatus_DB_Download = 5,
    ActionStatus_Cancelled_By_Sync = 6,
    ActionStatus_Cancelled_By_User = 7,
    ActionStatus_Restart_Pending_Items = 8,
    
}ManagerProcessActionStatus;


@interface SMAttachmentRequestManager : NSObject <SMRestRequestDelegate>
{   
    NSMutableDictionary *requestDictionary;
    NSMutableArray      *requestQueue;
    SMAttachmentModel   *currentActiveModel;
}

@property(nonatomic, retain) NSMutableDictionary *requestDictionary;
@property(nonatomic, retain) NSMutableArray      *requestQueue;
@property(nonatomic, retain) SMAttachmentModel   *currentActiveModel;

@property (nonatomic) ManagerProcessActionStatus processCurrentStatus;
@property (nonatomic) ManagerProcessActionStatus processNextStatus;

+ (SMAttachmentRequestManager *)sharedInstance;

- (void)downloadAttachment:(NSDictionary *)params;

- (void)downloadAttachment:(NSString *)sfId  withFileName:(NSString *)fileName withSize:(NSString *)size andLocalId:(NSString *)localId;

- (void)uploadAttachment:(NSArray *)items;
- (void)uploadResponseResult:(NSArray *)result withError:(NSError *)error andContext:(NSString *)context;

- (BOOL)cancelAttachmentRequestByLocalId:(NSString *)localId;
- (void)restartAllPendingAttachmentRequest;

@end
