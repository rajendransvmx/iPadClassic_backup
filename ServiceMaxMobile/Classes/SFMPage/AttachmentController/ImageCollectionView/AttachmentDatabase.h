//
//  AttachmentDatabase.h
//  ServiceMaxMobile
//
//  Created by Kirti on 13/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#define kAttachmentTrailerId @"attachment_id"
#define kErrorMsg            @"error_message"
#define kErrorCode           @"error_code"
#define kFileName            @"file_name"
#define kActon               @"action"
#define kSyncFlag            @"Sync_Flag"
#define kParentId            @"parent_sfid"

@interface AttachmentDatabase : NSObject
- (void) saveAttachmentRecords:(NSString *)localId;
- (NSMutableDictionary *) getAttachmentDictForLocaID:(NSString *)localId;
- (void) insertIntoAttachmentTable:(NSDictionary*)attachmentDict;
- (void) insertIntoSFAttachmentTrailer:(NSDictionary*)attachmentDict;
- (void) insertIntoSFAttachmentTrailerForDownload:(NSDictionary*)attachmentDict withFileName:(NSString *)fileName;
- (NSString *) getSizeForAttachmentId:(NSString *)attachmentId;
- (void) deleteFromAttachmentTrailerTable:(NSString*)localId;
- (NSArray *) getUnfinishedAttachments:(NSString *)action;
- (NSString *) getColoumnFromAttachment:(NSString *)columnName forLocalId:(NSString *)localId;
- (void) insertIntoAttachmentErrorTable:(NSDictionary *)attachmentDict;
-(NSMutableArray *) getErrorInAttachmentObject;
- (void) updateAttachmentSfId:(NSString*)attachmentSfId byLocalId:(NSString*)localId;
- (void) uploadingAttachment:(NSDictionary*)attachmentDict;
-(void)updateParentSfidInAttachmentTrailer;
- (void)updateSyncFlagWithAttachmentId:(NSString *)AttachmentId Withsyncflag:(NSString *)syncflag;
-(void)deleteFromAttachmentErrorTable:(NSString*)localId;
- (BOOL)doesRowsExistsForTable:(NSString *) tableName;
-(void)updateSFAttachmentTableforAttachmentRecord:(NSString*)attachmentLocalId ParentId:(NSString*)parentId;
- (int)getErrorCodeForAttachmentId:(NSString *)attachmentId;//9212
//Data Purge
- (void)deleteEntriesFromAttachmentErrorTable:(NSString *)localIDs;
@end
