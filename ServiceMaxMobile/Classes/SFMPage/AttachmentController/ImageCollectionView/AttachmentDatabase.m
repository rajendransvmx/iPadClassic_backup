//
//  AttachmentDatabase.m
//  ServiceMaxMobile
//
//  Created by Kirti on 13/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "AttachmentDatabase.h"
#import "AttachmentUtility.h"
#import "SMAttachmentModel.h"

@implementation AttachmentDatabase

-(void)uploadingAttachment:(NSDictionary*)attachmentDict
{
    [self insertIntoAttachmentTable:attachmentDict];
    [self insertIntoSFAttachmentTrailer:attachmentDict];
}


- (void)insertIntoAttachmentTable:(NSDictionary*)attachmentDict
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSArray *keyAttachment = [NSArray arrayWithObjects:@"local_Id",@"Name",@"ParentId",@"LastModifiedDate", nil];
    
    NSString *date=[NSString stringWithFormat:@"%@",[attachmentDict objectForKey:K_LASTMODIFIEDDATE]];
    
    NSString *parent_Id=([[attachmentDict objectForKey:K_PARENT_SFId] length]>0)?[attachmentDict objectForKey:K_PARENT_SFId]:[attachmentDict objectForKey:K_PARENT_LOCALId];
    
    NSArray *valueAttachment = [NSArray arrayWithObjects:[attachmentDict objectForKey:K_ATTACHMENT_ID],[attachmentDict objectForKey:K_NAME],parent_Id,date,nil];

    [appDelegate.dataBase insertrecordintoAttachmentTable:@"Attachment" recordDict:[NSDictionary dictionaryWithObjects:valueAttachment forKeys:keyAttachment]];
}

- (void)insertIntoSFAttachmentTrailer:(NSDictionary*)attachmentDict
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString * status = [NSString stringWithFormat:@"%d", ATTACHMENT_STATUS_UPLOAD_IN_QUEUE];
    NSArray *keyAttachment = [NSArray arrayWithObjects:@"Action",@"Status",@"Priority",@"Size",@"per_Progress",@"parent_sfid",@"type",@"file_name",@"attachment_id",@"parent_localid",@"objectName", nil];
    
    int prioity=[appDelegate.dataBase getPriorityOfAttachment];
    NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
    NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
    NSArray *valueAttachment = [NSArray arrayWithObjects:
                                ([attachmentDict objectForKey:K_ACTION]== nil)?@"":[attachmentDict objectForKey:K_ACTION],
                                status,
                                [NSString stringWithFormat:@"%d",prioity],
                                ([attachmentDict objectForKey:K_SIZE]== nil)?@"":[attachmentDict objectForKey:K_SIZE],
                                ([attachmentDict objectForKey:K_PERCENTPROGRESS]== nil)?@"":[attachmentDict objectForKey:K_PERCENTPROGRESS],
                                ([attachmentDict objectForKey:K_PARENT_SFId]== nil)?@"":[attachmentDict objectForKey:K_PARENT_SFId],
                                ([attachmentDict objectForKey:K_TYPE]== nil)?@"":[attachmentDict objectForKey:K_TYPE],
                                ([attachmentDict objectForKey:K_NAME]== nil)?@"":[attachmentDict objectForKey:K_NAME],
                                ([attachmentDict objectForKey:K_ATTACHMENT_ID]== nil)?@"":[attachmentDict objectForKey:K_ATTACHMENT_ID],
                                ([attachmentDict objectForKey:K_PARENT_LOCALId]== nil)?@"":[attachmentDict objectForKey:K_PARENT_LOCALId],
                                (headerObjName==nil)?@"":headerObjName,
                                nil];
    
   NSDictionary * dict = [NSDictionary dictionaryWithObjects:valueAttachment forKeys:keyAttachment];
    
    [appDelegate.dataBase insertrecordintoAttachmentTable:@"SFAttachmentTrailer" recordDict:dict];
    //NSLog(@" SFAttachmentTrailer  dict : %@ ", [dict description]);
}

- (void) deleteFromSFAttachmentTrailer:(NSString*)attid
{
    [appDelegate.dataBase deleteFromSFAttachmentTrailerTable:attid];
}

- (NSMutableDictionary *) getAttachmentDictForLocaID:(NSString *)localId
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary * attachmentDict = [appDelegate.SFMPage objectForKey:ATTACHMENT_DICT];
    NSDictionary * documentdict = [attachmentDict objectForKey:DOCUMENT_DICT];
    NSDictionary * captureDict = [attachmentDict objectForKey:IMAGES_DICT];
    NSMutableArray *attachmentArray = [documentdict objectForKey:OBJECT_LIST];
    [attachmentArray addObjectsFromArray:[captureDict objectForKey:OBJECT_LIST]];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for(dict in attachmentArray)
    {
        if([[dict objectForKey:K_ATTACHMENT_ID] isEqualToString:localId])
        {
            return dict;
        }
        
    }
    
    return [dict autorelease];
}

- (void)updateTrailerTableWithDeletedIds:(NSArray*)deletedIds
{
    for (NSString *deletedId in deletedIds)
    {
        
        BOOL recordExists = [appDelegate.databaseInterface checkRecordExistForObject:@"Attachment" LocalId:deletedId];
        
        //If record doesn't exist, then dont try to upload (Eg: A newly created document is deleted immediately. Such documents was causing a crash when the App tries to upload them)
        if(!recordExists){
            continue;
        }
        NSDictionary *attachmentDict = [appDelegate.dataBase getAttachmentLocalIdInfoFromDB:deletedId];
        
        if(attachmentDict != nil)
        {
            AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSString *localID = deletedId;
            NSString *parentLocalID = [attachmentDict objectForKey:@"ParentId"];
            NSString *sfId = [attachmentDict objectForKey:@"sf_id"];
            NSString *sourceObjName = @"Attachment";
            
            if([sfId length]>0 )
            {
                // SFid is not their means attachment is not synced so no need to delete from server
                [appDelegate.databaseInterface insertdataIntoTrailerTableForRecord:localID SF_id:sfId record_type:DETAIL operation:DELETE object_name:sourceObjName sync_flag:@"false" parentObjectName:@"" parent_loacl_id:parentLocalID webserviceName:@"" className:@"" synctype:AGRESSIVESYNC headerLocalId:localID requestData:nil finalEntry:false]; //ask sahana
            }

        }
        [self deleteFromAttachmentTable:deletedId];
    }

}

- (void) saveAttachmentRecords:(NSString *)parentLocalId
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary * attachmentDict = [appDelegate.SFMPage objectForKey:ATTACHMENT_DICT];
    NSDictionary * documentdict = [attachmentDict objectForKey:DOCUMENT_DICT];
    NSDictionary * captureDict = [attachmentDict objectForKey:IMAGES_DICT];
    NSMutableArray *attachmentArray = [documentdict objectForKey:OBJECT_LIST];
    [attachmentArray addObjectsFromArray:[captureDict objectForKey:OBJECT_LIST]];
    NSMutableArray *newids = [documentdict objectForKey:NEW_IDS];
    [newids addObjectsFromArray:[captureDict objectForKey:NEW_IDS]];
    NSArray *deletedIds = [documentdict objectForKey:DELETED_IDS];
    NSArray *deletedIdsForImages = [captureDict objectForKey:DELETED_IDS];
    // Upload
    for (int i=0; i<[newids count]; i++)
    {
        NSString *attachmentLocalID = [newids objectAtIndex:i];
        BOOL isLocalRecord = FALSE;
        NSMutableDictionary *newAttachment = [[self getAttachmentDictForLocaID:attachmentLocalID] retain];
        if(![[newAttachment objectForKey:K_PARENT_LOCALId] length]>0)
        {
            [newAttachment setObject:parentLocalId forKey:K_PARENT_LOCALId];
            isLocalRecord = TRUE;
            // Update SFAttachmentTrailer table
        }
        [self uploadingAttachment:newAttachment];
        if(isLocalRecord)
        {
            [self updateSFAttachmentTableforAttachmentRecord:attachmentLocalID ParentId:parentLocalId];
        }

        [newAttachment release]; newAttachment = nil;
    }
    // Delete
    [self updateTrailerTableWithDeletedIds:deletedIds];
    [AttachmentUtility deleteIdsFromAttachmentlist:deletedIds forType:DOCUMENT_DICT]; // only deleting from Dict Not from DB

    [self updateTrailerTableWithDeletedIds:deletedIdsForImages];
    [AttachmentUtility deleteIdsFromAttachmentlist:deletedIdsForImages forType:IMAGES_DICT];
    
    // If att id exists  -- For Document dict
    NSMutableArray *attIdsToDelete = [NSMutableArray arrayWithArray:deletedIds];
    [attIdsToDelete addObjectsFromArray:deletedIdsForImages];
    for (NSString *attid in attIdsToDelete)
    {
        BOOL exists = [appDelegate.dataBase DoesAttachmentExistsInQueue:attid];
        if(exists)
        {
            // then delete from SFAttachmentTrailer Table
            [self deleteFromSFAttachmentTrailer:attid];
        }
    }
}

-(NSString*)getAttachmentInQueue
{
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT attachment_id FROM SFAttachmentTrailer where parent_sfid != '' OR parent_sfid is  null and Action = 'UPLOAD' Order by priority limit 1"];
    
    sqlite3_stmt * stmt;
    NSString *localId=@"";
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *_localId = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ( _localId != nil )
                localId = [NSString stringWithUTF8String:_localId];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return localId;
}


- (void) deleteFromAttachmentTable:(NSString*)localId
{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM Attachment where local_id ='%@'",localId];
	
    char * err;
	
	if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
	{
		SMLog(kLogLevelVerbose,@"Failed to delete");
        SMLog(kLogLevelVerbose,@"deleteFromAttachmentTable");
		SMLog(kLogLevelVerbose,@"ERROR IN DELETE %s", err);
	}

}

- (void)deleteFromAttachmentTrailerTable:(NSString*)localId
{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM SFAttachmentTrailer where attachment_id ='%@'",localId];
	
    char * err;
	
	if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
	{
		SMLog(kLogLevelVerbose,@"Failed to delete");
        SMLog(kLogLevelVerbose,@"deleteFromAttachmentTable");
		SMLog(kLogLevelVerbose,@"ERROR IN DELETE %s", err);
	}
    
}


-(void)insertIntoSFAttachmentTrailerForDownload:(NSDictionary*)attachmentDict withFileName:(NSString *)fileName
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *keyAttachment = [NSArray arrayWithObjects:@"Action",@"Status",@"Size",@"file_name",@"attachment_id", nil];
    
    NSMutableArray *someArray = [[NSMutableArray alloc] init];
    NSString *someValue = @"DOWNLOAD";
    [someArray addObject:someValue];
    
    NSString *status = [NSString stringWithFormat:@"%d",ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE];
    [someArray addObject:status];
    
    NSString *someSize = [attachmentDict objectForKey:K_SIZE];
    if (someSize == nil) {
        someSize = @"0";
    }
    [someArray addObject:someSize];

    if(fileName != nil)
    {
    [someArray addObject:fileName];
    }
    NSString *someId = [attachmentDict objectForKey:K_ATTACHMENT_ID];
    [someArray addObject:someId];
    
    [appDelegate.dataBase insertrecordintoAttachmentTable:@"SFAttachmentTrailer" recordDict:[NSDictionary dictionaryWithObjects:someArray forKeys:keyAttachment]];
    
    [someArray release];
    someArray = nil;

}

- (NSString *)getSizeForAttachmentId:(NSString *)attachmentId {
    @synchronized(self){
    NSString *selectQuery=[NSString stringWithFormat:@"SELECT BodyLength FROM Attachment where local_id ='%@'",attachmentId];
    
    sqlite3_stmt *statement;
    NSString *sizeStr = @"0";
    
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            float size =  sqlite3_column_int(statement, 0);
            sizeStr = [NSString stringWithFormat:@"%f",size];
           
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    return sizeStr;
    }

}


- (void)loadUploadDataForModel:(SMAttachmentModel *)model
{
    NSString *dataString = [AttachmentUtility getEncodedBlobDataForLocalId:model.localId
                                                            attachmentName:model.fileName];
    model.encodeDataForUploading = dataString;
}


- (NSArray *)getUnfinishedAttachments:(NSString *)action{
    
    NSString * selectQuery = nil;
    
    BOOL isDownloadAction = NO;
    if([action isEqualToString:kAttachmentActionTypeDownload])
    {
        isDownloadAction = YES;
    }
    // Download
    if(isDownloadAction)
    {
        selectQuery = [NSString stringWithFormat:@"Select attachment_id,file_name,size,status,parent_sfid from SFAttachmentTrailer Where  (status = '%@' OR status = '%@') and action = '%@'",[NSString stringWithFormat:@"%d",ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE],[NSString stringWithFormat:@"%d",ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS],action];
    }else
    {
        selectQuery = [NSString stringWithFormat:@"Select attachment_id,file_name,size,status,parent_sfid from SFAttachmentTrailer Where  (parent_sfid != '' or parent_sfid is not null) and (status = '%@' OR status = '%@') and action = '%@'",[NSString stringWithFormat:@"%d",ATTACHMENT_STATUS_UPLOAD_IN_QUEUE],[NSString stringWithFormat:@"%d",ATTACHMENT_STATUS_UPLOAD_IN_PROGRESS],action];
    }
    
    sqlite3_stmt * stmt = nil;
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            SMAttachmentModel *model = [[SMAttachmentModel alloc] init];

            NSString *objString = nil;
            int i=0;
            // Local Id - attachment_id
            NSString *localId = nil;
            char *_someString = (char *) synchronized_sqlite3_column_text(stmt, i);
            if ( _someString != nil ){
                objString = [NSString stringWithUTF8String:_someString];
                if (objString != nil) {
                    model.localId = objString;
                    localId = objString;
                }
            }
            i++;
            
            // File Name
            _someString = (char *) synchronized_sqlite3_column_text(stmt, i);
            if ( _someString != nil ){
                objString = [NSString stringWithUTF8String:_someString];
                if (objString != nil)
                {
                    model.fileName = objString;
                    objString = [objString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (objString.length <= 0) {
                       model.fileName = [self getColoumnFromAttachment:@"Name" forLocalId:localId];
                    }
                }
            }
            i++;
            
            // File Size
            _someString = (char *) synchronized_sqlite3_column_text(stmt, i);
            if ( _someString != nil ){
                objString = [NSString stringWithUTF8String:_someString];
                if (objString != nil)
                {
                      model.fileSize = [objString integerValue];
                  
                }
            }
            i++;
            
            // Action Status
            _someString = (char *) synchronized_sqlite3_column_text(stmt, i);
            if ( _someString != nil ){
                objString = [NSString stringWithUTF8String:_someString];
                if (objString != nil) {
                     model.status = objString;
                }
            }
            i++;
            
            // Only in case Uploading file
            if( !isDownloadAction)
            {
                [self loadUploadDataForModel:model];
                
                // Parent SfId - SalesForce Id

                _someString = (char *) synchronized_sqlite3_column_text(stmt, i);
                if ( _someString != nil ){
                    objString = [NSString stringWithUTF8String:_someString];
                    if (objString != nil)
                    {
                        model.parentSfId = objString;
                    }
                }
                i++;
            }
            
            // SfId - SalesForce Id
            NSString *someId =  [self getColoumnFromAttachment:@"Id" forLocalId:localId];
            if (someId != nil) {
                model.sfId = someId;
            }
        
            if (isDownloadAction)
            {
                // Attachment_id should not be nil
                if ([model.localId length] > 3)
                {
                    [finalArray addObject:model];
                }
            }else
            {
                // In case of uploading, parentSfId required
                if ([model.parentSfId length]> 3)
                {
                    // Attachment_id should not be nil
                    if (([model.localId length] > 3) && ([model.fileName length] > 1))
                    {
                        [finalArray addObject:model];
                    }
                }
            }
            
            [model  release];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return [finalArray autorelease];
}

- (NSString *)getColoumnFromAttachment:(NSString *)columnName forLocalId:(NSString *)localId{
    NSString *selectQuery = [NSString stringWithFormat:@"Select %@ from Attachment Where local_id = '%@'",columnName,localId];
    NSString *columnvalue = nil;
    sqlite3_stmt * stmt = nil;
   
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *_someString = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ( _someString != nil ){
                columnvalue = [NSString stringWithUTF8String:_someString];
            }

        }
    }
    synchronized_sqlite3_finalize(stmt);
    return columnvalue;
}

#pragma mark -
#pragma mark - CRUD AttachmentError

- (void)insertIntoAttachmentErrorTable:(NSDictionary *)attachmentDict {
    
    @synchronized(self){
        AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSArray *keyAttachment = [[NSArray alloc] initWithObjects:@"error_message",@"action",@"error_code",@"status",@"file_name",@"attachment_id",@"parent_sfid", nil];
        
        NSMutableArray *someArray = [[NSMutableArray alloc] init];
        
        NSString *tempString = [attachmentDict objectForKey:kErrorMsg];
        if (tempString == nil) {
            tempString=@"";
        }
        [someArray addObject:tempString];
        
        tempString = [attachmentDict objectForKey:kActon];
        if (tempString == nil) {
            tempString=@"";
        }
        [someArray addObject:tempString];
        
        tempString = [attachmentDict objectForKey:kErrorCode];
        if (tempString == nil) {
            tempString=@"";
        }
        [someArray addObject:tempString];
        
        
        NSString *status = [NSString stringWithFormat:@"%d",ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD];
        [someArray addObject:status];
        
        tempString = [attachmentDict objectForKey:kFileName];
        if (tempString == nil) {
            tempString=@"";
        }
        [someArray addObject:tempString];
        
        tempString = [attachmentDict objectForKey:kAttachmentTrailerId];
        if (tempString == nil) {
            tempString=@"";
        }
        [someArray addObject:tempString];
        
        tempString = [attachmentDict objectForKey:kParentId];
        if (tempString == nil) {
            tempString=@"";
        }
        [someArray addObject:tempString];
        
        [appDelegate.dataBase insertrecordintoAttachmentTable:@"AttachmentError" recordDict:[NSDictionary dictionaryWithObjects:someArray forKeys:keyAttachment]];
        
        [someArray release];
        someArray = nil;
        [keyAttachment release];
        keyAttachment = nil;
    }
}
-(NSMutableArray*)getErrorInAttachmentObject
{

    NSArray * allKeys = [NSArray arrayWithObjects:kAttachmentTrailerId,kErrorMsg,kErrorCode,kFileName,kSyncFlag,kActon,K_PARENT_LOCALId,K_PARENT_SFId,nil];
    NSString * query = [NSString stringWithFormat:@"SELECT attachment_id,error_message, error_code ,file_name,Sync_Flag, action , parent_localid,parent_sfid FROM AttachmentError"];
    sqlite3_stmt * stmt ;
    NSMutableArray *attachmentError=[[NSMutableArray alloc]init];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
            
            for(int counter = 0; counter < [allKeys count]; counter++)
            {
                NSString * key = [allKeys objectAtIndex:counter];

                NSString *objString = nil;
                char * _temp_attachment_id = (char *)synchronized_sqlite3_column_text(stmt, counter);
                if(_temp_attachment_id != nil)
                {
                    objString= [NSString stringWithUTF8String:_temp_attachment_id];
                    if(objString != nil )
                    {
                        [paramDict setObject:objString forKey:key];
                    }
                    else
                    {
                        [paramDict setObject:@"" forKey:key];
                    }
                }
                else
                {
                    [paramDict setObject:@"" forKey:key];
                }
            }
            [attachmentError addObject:paramDict];
            [paramDict release];
            paramDict = nil;
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    return [attachmentError autorelease];
}


-(void)updateAttachmentSfId:(NSString*)attachmentSfId byLocalId:(NSString*)localId
{
    NSString * queryStatement = [NSString stringWithFormat:@"Update Attachment SET Id = '%@' where local_id ='%@'",attachmentSfId,localId];
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        //NSLog(@" updateAttachmentSfId failed with error  %s", err);
    }
}

-(void)updateParentSfidInAttachmentTrailer
{
 
    //Code optimization. We will update the sfid to only those objects that require them - in this case only items that are pending upload (download item doesn't require them)
    NSString *selectQuery=[NSString stringWithFormat:@"SELECT parent_localid,objectName,attachment_id,type FROM SFAttachmentTrailer where  (parent_sfid ='' OR parent_sfid is null ) and action = 'UPLOAD'"];
    
    sqlite3_stmt *statement;
    NSString * parentLocalId=@"", *objName=@"" ,* attId=@"", * type=@"";
    
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            
            parentLocalId=@"", objName=@"" , attId=@"",  type=@"";
            char * _parentLocalid = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((_parentLocalid != nil) && strlen(_parentLocalid))
            {
                parentLocalId = [NSString stringWithUTF8String:_parentLocalid];
            }
            char * _objName = (char *)synchronized_sqlite3_column_text(statement, 1);
            if ((_objName != nil) && strlen(_objName))
            {
                objName = [NSString stringWithUTF8String:_objName];
            }
            char * _attId = (char *)synchronized_sqlite3_column_text(statement, 2);
            if ((_attId != nil) && strlen(_attId))
            {
                attId = [NSString stringWithUTF8String:_attId];
            }
            char * _type = (char *)synchronized_sqlite3_column_text(statement, 3);
            if ((_type != nil) && strlen(_type))
            {
                type = [NSString stringWithUTF8String:_type];
            }
           
            NSString *parentSfId = [self getSfid:parentLocalId fromTable:objName];
            if([parentSfId length]>0)
            {
                // parent is synced
                [self updateSFtrailerTablewithParentIdafterDataSync:parentSfId parentLocalid:parentLocalId];
                [self updateParentSfidInAttachmentTable:parentSfId attLocalid:attId];
            }
            else
            {
                [self deleteFromSFAttachmentTrailer:attId];
                [self deleteFromAttachmentTable:attId];
                NSString *tempFileName=[AttachmentUtility fileName:attId extension:type];
                NSString *path =[AttachmentUtility getFullPath:tempFileName] ;
                [AttachmentUtility removeFileAtPath:path];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
}
-(NSString*)getSfid:(NSString*)localId fromTable:(NSString*)tabelName
{
    NSString *selectQuery=[NSString stringWithFormat:@"SELECT id FROM '%@' where local_id ='%@'",tabelName,localId];
    
    sqlite3_stmt *statement;
    NSString * parentsfId=@"";
    
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            
            char * _parentsfid = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((_parentsfid != nil) && strlen(_parentsfid))
            {
                parentsfId = [NSString stringWithUTF8String:_parentsfid];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    return parentsfId;
}

-(void)updateSFtrailerTablewithParentIdafterDataSync:(NSString *)sfId parentLocalid:(NSString*)parentLocalid
{
    NSString * queryStatement = [NSString stringWithFormat:@"Update SFAttachmentTrailer SET parent_sfid = '%@' where parent_localid ='%@'",sfId,parentLocalid];
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        
        SMLog(kLogLevelVerbose,@"METHOD:updateSFtrailerTablewithParentIdafterDataSync " );
        SMLog(kLogLevelVerbose,@"ERROR IN UPDATING %s", err);
        /*
         [appDelegate printIfError:nil ForQuery:queryStatement type:UPDATEQUERY];
         */
    }
}
-(void)updateParentSfidInAttachmentTable:(NSString *)sfId attLocalid:(NSString*)attLocalid
{
    NSString * queryStatement = [NSString stringWithFormat:@"Update Attachment SET parentId = '%@' where local_id ='%@'",sfId,attLocalid];
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        
        SMLog(kLogLevelVerbose,@"METHOD:updateParentSfidInAttachmentTable " );
        SMLog(kLogLevelVerbose,@"ERROR IN UPDATING %s", err);
        /*
         [appDelegate printIfError:nil ForQuery:queryStatement type:UPDATEQUERY];
         */
    }

}

-(void)updateAttachmentTableforUploadedAttachmentSfid:(NSString*)attSfid localId:(NSString*)attLocalid
{
    NSString * queryStatement = [NSString stringWithFormat:@"Update Attachment SET Id = '%@' where local_id ='%@'",attSfid,attLocalid];
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        
        SMLog(kLogLevelVerbose,@"METHOD:updateAttachmentTableforUploadedAttachmentSfid " );
        SMLog(kLogLevelVerbose,@"ERROR IN UPDATING %s", err);
    }

}

-(void)updateSFAttachmentTableforAttachmentRecord:(NSString*)attachmentLocalId ParentId:(NSString*)parentId
{
    NSString * queryStatement = [NSString stringWithFormat:@"Update SFAttachmentTrailer SET parent_localid = '%@' where attachment_id ='%@'",parentId,attachmentLocalId];
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        
        SMLog(kLogLevelVerbose,@"METHOD:updateSFAttachmentTableforAttachmentRecord" );
        SMLog(kLogLevelVerbose,@"ERROR IN UPDATING %s", err);
    }

}

- (void)updateSyncFlagWithAttachmentId:(NSString *)AttachmentId Withsyncflag:(NSString *)syncflag
{
    NSString * updateQuery = [NSString stringWithFormat:@"Update %@ Set %@ = '%@' Where %@ = '%@'",ATTACHMENT_ERROR,kSyncFlag,syncflag, kAttachmentTrailerId, AttachmentId];
    SMLog(kLogLevelVerbose,@"%@" , updateQuery);
    char *err;
    if (synchronized_sqlite3_exec(appDelegate.db, [updateQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", updateQuery);
		SMLog(kLogLevelError,@"METHOD:updateSyncFlagWithAttachmentId " );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:updateQuery type:UPDATEQUERY];
    }
}


-(void)deleteFromAttachmentErrorTable:(NSString*)localId
{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ where attachment_id ='%@'",ATTACHMENT_ERROR,localId];
	
    char * err;
	if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
	{
		SMLog(kLogLevelVerbose,@"Failed to delete");
        SMLog(kLogLevelVerbose,@"deleteFromAttachmentTable");
		SMLog(kLogLevelVerbose,@"ERROR IN DELETE %s", err);
        //[appDelegate printIfError:nil ForQuery:query type:DELETEQUERY];
	}
    
}

- (BOOL)doesRowsExistsForTable:(NSString *) tableName
{
    BOOL recordsExists = FALSE;
    int count = 0;
    sqlite3_stmt * stmt;
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'", tableName];
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            int temp_count = synchronized_sqlite3_column_int(stmt, 0);
            count = temp_count;
        }
    }else{
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    if(count > 0)
    {
        recordsExists = TRUE;
    }
    return recordsExists;
}
@end
