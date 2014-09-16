//
//  OptimizedSyncCalls.m
//  iService
//
//  Created by Radha S on 7/17/13.
//
//

#import "OptimizedSyncCalls.h"
#import "WSInterface.h"
#import "AppDelegate.h"
#import "WSIntfGlobals.h"
#import "INTF_WebServicesDefServiceSvc.h"
#import "Globals.h"



@interface OptimizedSyncCalls ()


-(INTF_WebServicesDefServiceSvc_INTF_SFMRequest *) Put:(NSString *)event_name;
- (void) put_insert:(NSString *)event_name valuemap:(NSMutableArray *)insert_array;
- (void) put_update:(NSString *)event_name valuemap:(NSMutableArray *)update_array;
- (void) put_delete:(NSString *)event_name valuemap:(NSMutableArray *)delete_array;
- (void) parseGetOptimizedData:(NSString *)eventname data:(NSMutableArray *)array;

@end;

@implementation OptimizedSyncCalls

@synthesize callBackValue;
@synthesize lastSyncTime;
@synthesize putUpdateSyncTime;
@synthesize purgingEventIdArray;
@synthesize callBackValuemap;

- (id) init
{
	if ([super init] == self)
	{
		appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		callBackValue = FALSE;
		callBackContextKey = @"";
		callBackContextValue = @"";
	}
	
	return self;
}


-(void)GetOptimizedDownloadCriteriaRecordsFor:(NSString *)event_name requestId:(NSString *)requestId;
{
	@try
	{
		syncRequestId = requestId;
		[INTF_WebServicesDefServiceSvc initialize];
		
		INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
		sessionHeader.sessionId = appDelegate.session_Id;
		
		INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
		callOptions.client = nil;
		
		INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
		debuggingHeader.debugLevel = 0;
		
		INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
		allowFieldTruncationHeader.allowFieldTruncation = NO;
		
		INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
		binding.logXMLInOut = [appDelegate enableLogs];
		
		
		INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init] autorelease];
		
		INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
		sfmRequest.eventName = event_name;
		sfmRequest.eventType = SYNC;
		sfmRequest.profileId = appDelegate.current_userId;
		sfmRequest.userId  = appDelegate.current_userId;
		sfmRequest.groupId = appDelegate.organization_Id;
		sfmRequest.value = requestId;
		
		INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMap_lastModified =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
		SVMXDEVMap_lastModified.key = @"LAST_SYNC_TIME";
				
		INTF_WebServicesDefServiceSvc_SVMXMap * put_delete = [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
		
		INTF_WebServicesDefServiceSvc_SVMXMap * put_insert = [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
		
		INTF_WebServicesDefServiceSvc_SVMXMap * put_update = [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
		
		if([event_name isEqualToString:@"ONE_CALL_SYNC"])
		{
			SVMXDEVMap_lastModified.value = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_OSC_TIMESTAMP] == nil ?@"":[appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_OSC_TIMESTAMP];
			//Compressing Putdelete
			if ([appDelegate.dataSync_dict count] > 0)
			{
				put_delete.key = PUT_DELETE;
				[put_delete.lstInternal_Request addObject:[self Put:PUT_DELETE]];
			}
			
			[appDelegate.wsInterface copyTrailertoTempTrailerForOneCallSync:INSERT];                         			
			[appDelegate.wsInterface  getAllRecordsForOperationType:INSERT];
			
			if ([appDelegate.dataSync_dict count] > 0)
			{
				put_insert.key = PUT_INSERT;
				[put_insert.lstInternal_Request addObject:[self Put:PUT_INSERT]];
			}
			[appDelegate.wsInterface copyTrailertoTempTrailerForOneCallSync:UPDATE];
			[appDelegate.wsInterface  getAllRecordsForOperationType:UPDATE];
			
			if ([appDelegate.dataSync_dict count] > 0)
			{
				put_update.key = PUT_UPDATE;
				[put_update.lstInternal_Request addObject:[self Put:PUT_UPDATE]];
				
			}

		}
		NSString * temp_event_name = @"";
        
        //9819 - Defect Fix
        INTF_WebServicesDefServiceSvc_SVMXMap * callBack =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
		callBack.key = @"call_back";
		
		if (callBackValue)
		{
			callBack.value = @"true";
			for (INTF_WebServicesDefServiceSvc_SVMXMap * callBackContext in self.callBackValuemap)
			{
				INTF_WebServicesDefServiceSvc_SVMXMap * callBackVal =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
				callBackVal.key = callBackContext.key;
				callBackVal.value = callBackContext.value;
                temp_event_name = callBackContext.value; //9819 - Defect Fix
				[callBack.valueMap addObject:callBackVal];
			}
		}
		else
		{
			callBack.value = @"false";
            temp_event_name = @""; //9819 - Defect Fix
		}

		//9819 - Defect Fix
		if ([temp_event_name isEqualToString:GET_INSERT_DC_OPTIMZED])
		{
			temp_event_name = GET_INSERT;
		}
		else if ([temp_event_name isEqualToString:GET_UPDATE_DC_OPTIMZED])
		{
			temp_event_name = GET_UPDATE;
		}
		else if ([temp_event_name isEqualToString:GET_DELETE_DC_OPTIMZED])
		{
			temp_event_name = GET_DELETE;
		}
		
		INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMap_last_index =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
		SVMXDEVMap_last_index.key  = @"LAST_INDEX";
		SVMXDEVMap_last_index.value = appDelegate.initial_Sync_last_index;
		[sfmRequest.valueMap addObject:SVMXDEVMap_last_index];
		
		if([appDelegate.initital_sync_object_name length] > 0) //9819 - Defect Fix
		{
			NSArray * all_records = [appDelegate.databaseInterface getAllIdsFromDatabase:temp_event_name forObjectName:appDelegate.initital_sync_object_name];
			
			for(NSString * str in all_records)
			{
				[sfmRequest.values addObject:str];
			}
		}
        [sfmRequest.valueMap addObject:callBack];
		
		[sfmRequest.valueMap addObject:SVMXDEVMap_lastModified];
		[sfmRequest.valueMap addObject:put_delete];
		[sfmRequest.valueMap addObject:put_insert];
		[sfmRequest.valueMap addObject:put_update];
		
		
		INTF_WebServicesDefServiceSvc_SVMXDEVlient  * SVMXDEV_client =  [appDelegate getSVMXDEVlientObject];
		[sfmRequest addClientInfo:SVMXDEV_client];
		[datasync setRequest:sfmRequest];
		
		
		binding.logXMLInOut = [appDelegate enableLogs];
		SMLog(kLogLevelVerbose,@"**************************** Start binding - One call sync *******************************");
		[binding INTF_DataSync_WSAsyncUsingParameters:datasync
										SessionHeader:sessionHeader
										  CallOptions:callOptions
									  DebuggingHeader:debuggingHeader
						   AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:appDelegate.wsInterface];
		SMLog(kLogLevelVerbose,@"**************************** END binding - One call sync *******************************");
    }
	@catch (NSException *exp)
	{
        SMLog(kLogLevelError,@"Exception Name OptimizedSyncCalls :GETDownloadCriteriaRecordsFor %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason OptimizedSyncCalls :GETDownloadCriteriaRecordsFor %@",exp.reason);
    }
	
}
#define START_TIME   @"start_time"
#define END_TIME     @"end_time"

-(INTF_WebServicesDefServiceSvc_INTF_SFMRequest *) Put:(NSString *)event_name
{
	INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];

	@try
	{
		NSString * event_type = @"SYNC";
		
		sfmRequest.eventName = event_name;
		sfmRequest.eventType = event_type;
		sfmRequest.value = syncRequestId;
		
		if([event_name isEqualToString:@"PUT_UPDATE"] && [event_type isEqualToString:@"SYNC"])//PUT_UPDATE
		{
			INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMap_lastModified =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init]  autorelease];
			SVMXDEVMap_lastModified.key = @"SYNC_TIME_STAMP";
			SVMXDEVMap_lastModified.value = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_UPDATE_RESONSE_TIME] == nil ?@"":[appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_UPDATE_RESONSE_TIME];
			
			[sfmRequest.valueMap addObject:SVMXDEVMap_lastModified];
			
			NSArray * all_objects = [appDelegate.dataSync_dict allKeys];
			NSMutableArray * record_id_list = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
			
			for(int i = 0 ; i < [all_objects count]; i++)
			{
				
				NSString * object_name = [all_objects objectAtIndex:i] ;
                
                //////////////////////////// Naveen Vasu : Defect 11366 ////////////////////////////
                NSMutableDictionary * referenceTo = [appDelegate.databaseInterface getReferenceToForObjectapiName:object_name];
                NSString * parent_object_name = @"" ,*parent_column_name = @"";
                BOOL isChild_object =[appDelegate.databaseInterface IsChildObject:object_name];
                if(isChild_object)
                {
                    parent_object_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_name"];
                    
                    parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_column_name"];
                }
                //////////////////////////// Defect 11366 /////////////////////////////////////////
                
				INTF_WebServicesDefServiceSvc_SVMXMap  * SVMXDEVmap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
				NSMutableArray * info_dict = [appDelegate.dataSync_dict objectForKey:object_name];
				
				// get all the fields from the table
				// query object for the id put in in list map
				
				NSDictionary * fields_dict = [appDelegate.databaseInterface getAllObjectFields:object_name tableName:SFOBJECTFIELD];
				NSArray * fields_array ;
				fields_array = [fields_dict allKeys];
				
				NSString * field_string = @"";
				for(int i = 0 ; i< [fields_array count]; i++)
				{
					NSString * field = [fields_array objectAtIndex:i];
					if (i == 0)
						field_string = [field_string stringByAppendingFormat:@"%@",field];
					else
						field_string = [field_string stringByAppendingFormat:@",%@",field];
				}
				
				
				// ADD   FIELDS  method
				INTF_WebServicesDefServiceSvc_SVMXMap  * record_SVMXDEV  = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
				
				record_SVMXDEV.key = @"Fields";

                // Vipindas field merge feature
                // Removing as part of field merging.
				// record_SVMXDEV.value = field_string;
				
                BOOL value_map_count = 0;
                NSMutableArray *beforeSaveFields = [[NSMutableArray alloc] init];
                NSLog(@" 1sync PUT_UP info_dict  : %@", info_dict);
				
				for (NSDictionary * dict in info_dict)
				{
					NSArray * keys = [dict allKeys];
					
					NSString * local_id = @"";
                    
                    //////////////////////////// Naveen Vasu : Defect 11366 ////////////////////////////
					//NSString * parent_object_name = @"";
                    
					NSString * parent_local_id = @"";
					NSString * time_stamp = @"";
					NSString * record_type = @"";
					NSString * sf_id = @"";
					NSString * override_flag = @"";
                    NSString * fields_modified = @"";
                    
					for (int j = 0; j < [keys count]; j++)
					{
						NSString * key = [keys objectAtIndex:j];
						
						if([key isEqualToString:@"local_id"])
						{
							local_id = [dict objectForKey:key];
						}
                        
						if([key isEqualToString:@"time_stamp"])
						{
							time_stamp = [dict objectForKey:@"time_stamp"];
						}
						if([key isEqualToString:@"record_type"])
						{
							record_type = [dict objectForKey:@"record_type"];
							// Master_or_parent = record_type;
						}
						if([key isEqualToString:@"sf_id"])
						{
							sf_id = [dict objectForKey:@"sf_id"];
						}
						if([key isEqualToString:@"override_flag"])
						{
							override_flag = [dict objectForKey:@"override_flag"];
						}
                        
                        // Vipindas field merge feature
                        if([key isEqualToString:@"fields_modified"])
						{
							fields_modified = [dict objectForKey:@"fields_modified"];
						}
						
					}
                    
                    if (sf_id != nil && ([sf_id length] > 0))
                    {
                        NSLog(@" Optimizedsync refetching fields_modified for sf_id : %@", sf_id);
                        fields_modified =  [appDelegate.databaseInterface fieldsModifiedDataFromTrailorTableById:sf_id];
                    }
					
					INTF_WebServicesDefServiceSvc_SVMXMap * testSVMXDEVMap =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
					
					if([record_type isEqualToString:DETAIL] || [record_type isEqualToString:MASTER])
					{
						
						if(appDelegate.speacialSyncIsGoingOn)
						{
							if([sf_id length] == 0)
							{
								
								continue;
							}
						}
						else
						{
							//check for id
							NSString * child_sf_id  = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:object_name local_id:local_id];
							
							if([child_sf_id length] == 0)
							{
                                //10900
								[appDelegate.databaseInterface DeleteUpdateRecordFromTable:SFDATATRAILER Forlocal_id:local_id];
								continue;
							}
						}
					}
					
					if(appDelegate.speacialSyncIsGoingOn)
					{
						if([local_id length] == 0)
							local_id =  [appDelegate.databaseInterface getLocalIdFromSFId:sf_id  tableName:object_name];
					}
					
					NSMutableDictionary * each_record = [appDelegate.databaseInterface getRecordsForRecordId:local_id  ForObjectName:object_name fields:field_string];
                    
                    //////////////////////////// Naveen Vasu : Defect 11366 ////////////////////////////
                    BOOL  replaceSuccess = [appDelegate.wsInterface replaceReferenceLocalIdWithSfidForRecord:each_record isChild:isChild_object referenceTo:referenceTo parentColoumnName:parent_column_name ObjectName:object_name recordLocalId:local_id recordSfId:@""];
                    if(!replaceSuccess)
                    {
                        NSArray * referenceFields = [referenceTo allKeys];
                        NSArray * record_fields = [each_record allKeys];
                        for(NSString * fieldApiName in referenceFields)
                        {
                            if([record_fields containsObject:fieldApiName])
                            {
                                if([fieldApiName isEqualToString:parent_column_name] && isChild_object)
                                {
                                    continue;
                                }
                                
                                NSString * referenceFieldId = [each_record objectForKey:fieldApiName];
                                
                                if([referenceFieldId length] > 30)
                                {
                                    [each_record setObject:@"" forKey:fieldApiName];
                                }
                            }
                        }
                    }
                    //////////////////////////// Defect 11366 ////////////////////////////
                    
                    
					if([record_type isEqualToString:DETAIL])
					{
						NSString * parent_SF_Id = @"";
						//NSString * parent_column_name = @"";
						
                        //////////////////////////// Naveen Vasu : Defect 11366 //////////////////////////// Condition change
                        if([parent_object_name length] == 0  || [parent_object_name isEqualToString:object_name] || appDelegate.speacialSyncIsGoingOn || [parent_column_name length] == 0)
						{
							parent_object_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_name"];
							
                            parent_column_name = [appDelegate.databaseInterface  getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:object_name parentApiName:parent_object_name];
                            //////////////////////////// Defect 11366 ////////////////////////////
						}
                        
                        //////////////////////////// Naveen Vasu : Defect 11366 ////////////////////////////
                        if([parent_local_id length] == 0)
                        {
                            parent_local_id = [each_record objectForKey:parent_column_name];
                        }
                        //////////////////////////// Defect 11366 ////////////////////////////
                        
						NSString * Parent_SF_ID_from_object_table = @"" ,* Parent_SF_ID_from_heap_table = @"";
						Parent_SF_ID_from_object_table = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:parent_object_name local_id:parent_local_id];
						
						Parent_SF_ID_from_heap_table = [appDelegate.databaseInterface getSfid_For_LocalId_FROM_SfHeapTable:parent_local_id];
						if(![Parent_SF_ID_from_object_table isEqualToString:@""])
						{
							parent_SF_Id = Parent_SF_ID_from_object_table;
						}
						else if (![Parent_SF_ID_from_heap_table isEqualToString:@""] && [ parent_SF_Id isEqualToString:@""])
						{
							parent_SF_Id = Parent_SF_ID_from_heap_table;
						}
						
                        if([parent_local_id length] < 30 && [parent_local_id length] != 0)
                        {
                            parent_SF_Id = parent_local_id;
                        }
                        
						NSArray * all_keys = [each_record allKeys];
						
						SMLog(kLogLevelVerbose,@"parent local id %@  parent sf id %@ " , parent_local_id , parent_SF_Id);
						for(NSString * str in all_keys)
						{
							if([str isEqualToString:parent_column_name])
							{
								[each_record setValue:parent_SF_Id  forKey:parent_column_name];
							}
						}
					}
					
					
					//check for the local_id in the record_list
					
					BOOL check_id_exists = FALSE;
					
					if(appDelegate.speacialSyncIsGoingOn)
					{
						for(NSString * id_ in record_id_list)
						{
							if([id_ isEqualToString:sf_id])
							{
								check_id_exists = TRUE;
							}
						}
					}
					else
					{
						for(NSString * id_ in record_id_list)
						{
							if([id_ isEqualToString:local_id])
							{
								check_id_exists = TRUE;
							}
						}
					}
					
					if(!check_id_exists)
					{
						
                        // Vipindas field merge feature
						
                        NSString * json_record = nil;
                        
                        NSLog(@" opt sync call fields_modified :- %@", fields_modified);
                        
                        if ((fields_modified != nil) && ([fields_modified length] > 0))
                        {
                            NSError *error = NULL;
                            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[fields_modified dataUsingEncoding:NSUTF8StringEncoding]
                                                                                           options:NSJSONReadingMutableContainers
                                                                                             error:&error];
                            
                            NSDictionary *afterSaveRecordDetails  = (NSDictionary *) [jsonDictionary objectForKey:kAdvancedFieldMergeAfterSave];
                            NSDictionary *beforeSaveRecordDetails = (NSDictionary *)[jsonDictionary objectForKey:kAdvancedFieldMergeBeforeSave];
                            
                            if ( (afterSaveRecordDetails != nil) && (beforeSaveRecordDetails != nil))
                            {
                                //json_record = afterSaveRecordDetails;
                                
                                SBJsonWriter * localJsonWriter = [[SBJsonWriter alloc] init];
                                json_record = [localJsonWriter stringWithObject:afterSaveRecordDetails];
                                [localJsonWriter release]; localJsonWriter = nil;
                                
                                [beforeSaveFields addObject:beforeSaveRecordDetails];
                            }
                        }
                        
                        
                        if (json_record == nil)
                        {
                            SBJsonWriter * jsonWriter = [[SBJsonWriter alloc] init];
                            
                            json_record= [jsonWriter stringWithObject:each_record ];
                            [jsonWriter release];
                        }
                       
                        
                        if([override_flag isEqualToString:CLIENT_OVERRIDE])
						{
							testSVMXDEVMap.key = @"CLIENT_OVERRIDE";
						}
						else
						{
							testSVMXDEVMap.key = time_stamp;
						}
						
						testSVMXDEVMap.value = json_record;
						
						if(appDelegate.speacialSyncIsGoingOn)
						{
							[record_id_list addObject:sf_id];
						}
						else
						{
							[record_id_list addObject:local_id];
						}
						
						[record_SVMXDEV.valueMap addObject:testSVMXDEVMap];
						value_map_count++;
						
					}
					
					[testSVMXDEVMap release];
					
					if(appDelegate.speacialSyncIsGoingOn)
					{
						[appDelegate.databaseInterface deleterecordsFromConflictTableForOperationType:PUT_UPDATE overrideFlag:override_flag table_name:SYNC_ERROR_CONFLICT id_value:sf_id field_name:@"sf_id"];
					}
					
				}
                
                
                // Vipindas field merge feature
                
                if ([beforeSaveFields count] > 0)
                {
                    INTF_WebServicesDefServiceSvc_SVMXMap * beforeSaveMap = nil;
                    
                    beforeSaveMap =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
                    beforeSaveMap.key = kAdvancedFieldMergeBeforeSave;
                    
                    SBJsonWriter * localJsonWriter = [[SBJsonWriter alloc] init];
                    for (NSDictionary *valueDict in beforeSaveFields)
                    {
                        NSString *jsonRecord = [localJsonWriter stringWithObject:valueDict];
                        [beforeSaveMap addValues:jsonRecord];
                    }
                    [localJsonWriter release]; localJsonWriter = nil;
                    
                    [record_SVMXDEV.valueMap addObject:beforeSaveMap];
                    [beforeSaveMap release];
                    beforeSaveMap = nil;
                }
				
				SVMXDEVmap.key = @"Object_Name";
				SVMXDEVmap.value = object_name;
								
								
				if(value_map_count !=0)
				{
					[SVMXDEVmap.valueMap addObject:record_SVMXDEV];
					[sfmRequest.valueMap addObject:SVMXDEVmap];
				}
				[record_SVMXDEV release];
				[SVMXDEVmap release];
				
			}
			
		}
		
		else if([event_name isEqualToString:@"PUT_INSERT"] && [event_type isEqualToString:@"SYNC"])
		{
            //8590
			NSMutableArray * finalSetOfrecords = [[NSMutableArray alloc] initWithCapacity:0];
            
			NSArray * masterObjects = [appDelegate.databaseInterface getAllObjectsForRecordType:MASTER  forOperation:INSERT];
			NSArray * detailObjects = [appDelegate.databaseInterface getAllObjectsForRecordType:DETAIL forOperation:INSERT];
			NSMutableArray * masterDetailArray = [[NSMutableArray alloc] initWithObjects:masterObjects,detailObjects, nil];
			
			NSArray * all_objects = [appDelegate.dataSync_dict allKeys];
			
			NSInteger count = 0;
			
			INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMap_lastModified =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];         
			SVMXDEVMap_lastModified.key = @"SYNC_TIME_STAMP";
			SVMXDEVMap_lastModified.value = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_INSERT_RESONSE_TIME] == nil ?@"":[appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_INSERT_RESONSE_TIME];
			
			INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMap_startTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];           
			SVMXDEVMap_startTime.key  = @"RANGE_START";
			SVMXDEVMap_startTime.value = [appDelegate.wsInterface getSyncTimeStampWithTheIntervalof15days:START_TIME] == nil ? @"" :[appDelegate.wsInterface getSyncTimeStampWithTheIntervalof15days:START_TIME];
			
			INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMap_endTime =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];             
			SVMXDEVMap_endTime.key  = @"RANGE_END";
			SVMXDEVMap_endTime.value = [appDelegate.wsInterface getSyncTimeStampWithTheIntervalof15days:END_TIME]== nil ? @"" :[appDelegate.wsInterface getSyncTimeStampWithTheIntervalof15days:END_TIME];
			
			[sfmRequest.valueMap addObject:SVMXDEVMap_lastModified];
			
			for(int temp = 0; temp < 2 && count < CHUNCKING_LIMIT ; temp ++)
			{
				NSArray * tempArray = [masterDetailArray objectAtIndex:temp];
				
				NSString * key = @"";
				if(temp == 0)
				{
					key = @"Parent_Object";
				}
				else
				{
					key = @"Child_Object";
				}
				for(int x = 0 ; x < [tempArray count] && count < CHUNCKING_LIMIT ;x++)
				{
					
					NSString * tempMasterOrDetail = [tempArray objectAtIndex:x];
					for(int i = 0 ; i < [all_objects count] && count < CHUNCKING_LIMIT ; i++)
					{
						NSString * object_name = [all_objects objectAtIndex:i] ;
						//find the type of the object name
						
						// BOOL MasterObject = FALSE ;
						if([tempMasterOrDetail isEqualToString:object_name])
						{
							INTF_WebServicesDefServiceSvc_SVMXMap  * SVMXDEVmap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
							
							SVMXDEVmap.key = key ;
							SVMXDEVmap.value = object_name;
							
							NSMutableArray *  info_dict = [appDelegate.dataSync_dict objectForKey:object_name];
							
							// get all the fields from the table
							// query object for the id put in in list map
							
							NSDictionary * fields_dict = [appDelegate.databaseInterface getAllObjectFields:object_name tableName:SFOBJECTFIELD];
							NSArray * fields_array ;
							fields_array = [fields_dict allKeys];
							NSString * field_string = @"";
							for(int i = 0 ; i< [fields_array count]; i++)
							{
								NSString * field = [fields_array objectAtIndex:i];
								if (i == 0)
									field_string = [field_string stringByAppendingFormat:@"%@",field];
								else
									field_string = [field_string stringByAppendingFormat:@",%@",field];
							}
							
							// ADD   FIELDS  method
							INTF_WebServicesDefServiceSvc_SVMXMap  * record_SVMXDEV  = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
							
							record_SVMXDEV.key = @"Fields";
							record_SVMXDEV.value = field_string;
                            
                            //8590
                            NSString * parent_object_name = @"" ,*parent_column_name = @"";
                            
                            BOOL isChild_object =[appDelegate.databaseInterface IsChildObject:object_name];
                            
                            if(isChild_object)
                            {
                                parent_object_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_name"];
                                
                                parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_column_name"];
                            }
                            NSMutableDictionary * referenceTo = [appDelegate.databaseInterface getReferenceToForObjectapiName:object_name];
                            int num_of_records = 0;
							
							for (NSDictionary * dict in info_dict)
							{
								if(count > CHUNCKING_LIMIT)
								{
									break;
								}
								
								NSArray * keys = [dict allKeys];
								
								NSString * local_id = @"";
								NSString * parent_local_id = @"";
								for (int j = 0; j < [keys count]; j++)
								{
									NSString * key = [keys objectAtIndex:j];
									
									if([key isEqualToString:@"local_id"])
									{
										local_id = [dict objectForKey:key];
									}
                                    //8590
									/*if([key isEqualToString:@"parent_object_name"])
									{
										parent_object_name = [dict objectForKey:@"parent_object_name"];
									}
									if([key isEqualToString:@"parent_local_id"])
									{
										parent_local_id = [dict objectForKey:@"parent_local_id"];
									}*/
								}
                                //8590
                                BOOL recordExists = [appDelegate.databaseInterface checkRecordExistForObject:object_name LocalId:local_id];
                                if(!recordExists)
                                {
                                    [appDelegate.databaseInterface DeleterecordFromDataTrailerTableForlocal_id:local_id];
                                    [appDelegate.databaseInterface deleteRecordFromConflictTableForRecord:local_id operation:PUT_INSERT];
                                    [appDelegate.databaseInterface updateDataTrailer_RecordSentForlocalId:local_id operation_type:INSERT];
                                    continue;
                                }
								
								INTF_WebServicesDefServiceSvc_SVMXMap * testSVMXDEVMap =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
								
								NSMutableDictionary * each_record = [appDelegate.databaseInterface getRecordsForRecordId:local_id  ForObjectName:object_name fields:field_string];
                              
                                //8590
                                BOOL  replaceSuccess = [appdelegate.wsInterface replaceReferenceLocalIdWithSfidForRecord:each_record isChild:isChild_object referenceTo:referenceTo parentColoumnName:parent_column_name ObjectName:object_name recordLocalId:local_id recordSfId:@""];
                                
								
								if([key isEqualToString:@"Child_Object"] && replaceSuccess)
								{
                                    //8590
									/*if(appDelegate.speacialSyncIsGoingOn)
									{
										parent_object_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_name"];
										
										NSString * parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:object_name field_name:@"parent_column_name"];
										
										parent_local_id = [appDelegate.databaseInterface getParentIdFrom:object_name WithId:local_id andParentColumnName:parent_column_name id_type:@"local_id"];
									}*/
                                    //8590
                                    NSString * temp_parent_local_id = [each_record objectForKey:parent_column_name];
                                    if([temp_parent_local_id length] == 0)
                                    {
                                        parent_local_id = [appDelegate.databaseInterface getParentIdFrom:object_name WithId:local_id andParentColumnName:parent_column_name id_type:@"local_id"];
                                    }
                                    else
                                    {
                                        parent_local_id = temp_parent_local_id;
                                    }
                                    
									NSString *  Parent_SF_ID_from_object_table = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:parent_object_name local_id:parent_local_id];
                                    //8590
									/*if([Parent_SF_ID_from_object_table isEqualToString:@""])
									{
										Parent_SF_ID_from_object_table = parent_local_id;
									}
									
									NSString * parent_column_name = @"";
									parent_column_name = [appDelegate.databaseInterface  getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:object_name parentApiName:parent_object_name];
									
									NSArray * allKeys_child = [each_record allKeys];
									
									//find parent column Name
									for(NSString * parent_key in allKeys_child)
									{
										if([parent_key isEqualToString:parent_column_name])
										{
											[each_record setValue:Parent_SF_ID_from_object_table forKey:parent_column_name];
										}
									}
									
								}*/
                                    //8590
                                    if([Parent_SF_ID_from_object_table length] == 0)
                                    {
                                        Parent_SF_ID_from_object_table = [appDelegate.databaseInterface getSfid_For_LocalId_FROM_SfHeapTable:parent_local_id];
                                    }
                                    
                                    if([Parent_SF_ID_from_object_table length] == 0)
                                    {
                                        if([parent_local_id length] > 10 && [parent_local_id  length] < 30)
                                        {
                                            Parent_SF_ID_from_object_table = parent_local_id;
                                        }
                                    }
                                    
                                    if(![finalSetOfrecords containsObject:parent_local_id] && [Parent_SF_ID_from_object_table length] == 0)
                                    {
                                        //check if parent exists
                                        BOOL does_referenceRecordExists = [appDelegate.databaseInterface checkRecordExistForObject:parent_object_name LocalId:parent_local_id];
                                        
                                        if(!does_referenceRecordExists)
                                        {
                                            //Do nothing
                                        }
                                        else
                                        {
                                            BOOL conflict_exists_local_id = [appDelegate.dataBase checkIfConflictsExistsForEventWithLocalId:parent_local_id objectName:parent_object_name];
                                            
                                            BOOL ParentrecordNotSent = [appDelegate.databaseInterface checkSentFlagForReferenceId:parent_local_id forOperation:INSERT];
                                            if(conflict_exists_local_id || ParentrecordNotSent ||  [appdelegate.wsInterface.customSync_unsynched_records containsObject:parent_local_id])
                                            {
                                                [appDelegate.databaseInterface updateDataTrailer_RecordSentForlocalId:local_id operation_type:INSERT];
                                            }
                                            continue;
                                        }
                                        
                                    }
                                    
                                    if([Parent_SF_ID_from_object_table length] == 0)
                                    {
                                        Parent_SF_ID_from_object_table = parent_local_id;
                                    }
                                    
                                    NSArray * allKeys_child = [each_record allKeys];
                                    
                                    //find parent column Name
                                    for(NSString * parent_key in allKeys_child)
                                    {
                                        if([parent_key isEqualToString:parent_column_name])
                                        {
                                            [each_record setValue:Parent_SF_ID_from_object_table forKey:parent_column_name];
                                        }
                                    }
                                    
                                }

                                //8590
                                if(replaceSuccess)
                                {
                                    SBJsonWriter * localJsonWriter = [[SBJsonWriter alloc] init];
                                    NSString * json_record = [localJsonWriter stringWithObject:each_record];
                                    
                                    testSVMXDEVMap.key = local_id;
                                    testSVMXDEVMap.value = json_record;
                                    
                                    [record_SVMXDEV.valueMap addObject:testSVMXDEVMap];
                                    
                                    [finalSetOfrecords addObject:local_id];
                                    count ++;
                                    num_of_records++;
                                    //update record is being sent
                                    [appDelegate.databaseInterface updateDataTrailer_RecordSentForlocalId:local_id operation_type:INSERT];
                                    
                                    if(appDelegate.speacialSyncIsGoingOn)
                                    {
                                        [appDelegate.databaseInterface deleterecordsFromConflictTableForOperationType:PUT_INSERT overrideFlag:RETRY table_name:SYNC_ERROR_CONFLICT id_value:local_id field_name:@"local_id"];
                                    }
                                    [localJsonWriter release]; localJsonWriter = nil;
                                }
                                [testSVMXDEVMap release]; testSVMXDEVMap =  nil;
                            }
                            
                            //8590
                            //ISCALLBACK   method
                            INTF_WebServicesDefServiceSvc_SVMXMap  * iscallBack = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
                            iscallBack.key = @"IS_CALLBACK";
                            iscallBack.value = @"YES";
                            if(num_of_records)
                            {
                                [SVMXDEVmap.valueMap addObject:record_SVMXDEV];
                                [SVMXDEVmap.valueMap addObject:iscallBack];
                                [sfmRequest.valueMap addObject:SVMXDEVmap];
                            }
                            [iscallBack release];
                            [record_SVMXDEV release];  //sahana30April
                            [SVMXDEVmap release];       //sahana30April
                            break;
						}
						
					}
					
				}
			}
			
			[masterDetailArray release];
            [finalSetOfrecords release];
		}
		else if ([event_name isEqualToString:@"PUT_DELETE"] && [event_type isEqualToString:@"SYNC"])
		{
			INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMap_lastModified =  [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
			SVMXDEVMap_lastModified.key = @"SYNC_TIME_STAMP";
			SVMXDEVMap_lastModified.value = [appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_DELETE_RESPONSE_TIME] == nil ?@"":[appDelegate.wsInterface get_SYNCHISTORYTime_ForKey:LAST_DELETE_RESPONSE_TIME];
			[sfmRequest.valueMap addObject:SVMXDEVMap_lastModified];
			
			
			NSArray * all_objects = [appDelegate.dataSync_dict allKeys];
			
			for(int i = 0 ; i < [all_objects count]; i++)
			{
				
				NSString * object_name = [all_objects objectAtIndex:i] ;
				
				
				INTF_WebServicesDefServiceSvc_SVMXMap  * SVMXDEVmap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
				
				SVMXDEVmap.key = @"object_name" ;
				SVMXDEVmap.value = object_name;
				
				NSMutableArray *  info_dict = [appDelegate.dataSync_dict objectForKey:object_name];
				

				INTF_WebServicesDefServiceSvc_SVMXMap  * record_SVMXDEV  = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
				
				record_SVMXDEV.key = @"Fields";
				record_SVMXDEV.value = @"";
				
				for (NSDictionary * dict in info_dict)
				{
					NSArray * keys = [dict allKeys];
					
					NSString * local_id = @"";
					NSString * parent_object_name = @"";
					NSString * parent_local_id = @"";
					NSString * time_stamp = @"";
					NSString * record_type = @"";
					for (int j = 0; j < [keys count]; j++)
					{
						NSString * key = [keys objectAtIndex:j];
						
						if([key isEqualToString:@"local_id"])
						{
							local_id = [dict objectForKey:key];
						}
						if([key isEqualToString:@"parent_object_name"])
						{
							parent_object_name = [dict objectForKey:@"parent_object_name"];
						}
						if([key isEqualToString:@"parent_local_id"])
						{
							parent_local_id = [dict objectForKey:@"parent_local_id"];
						}
						if([key isEqualToString:@"time_stamp"])
						{
							time_stamp = [dict objectForKey:@"time_stamp"];
						}
						if([key isEqualToString:@"record_type"])
						{
							record_type = [dict objectForKey:@"record_type"];
						}
					}
					
					
					INTF_WebServicesDefServiceSvc_SVMXMap * testSVMXDEVMap =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
					
					testSVMXDEVMap.key = @"";
					NSString * sf_id = [appDelegate.databaseInterface getSfid_For_LocalId_From_TrailerForlocal_id:local_id];
					//Check the change
					if ( sf_id == nil || [sf_id isEqualToString:@""])
					{
						sf_id = [[info_dict objectAtIndex:0] valueForKey:@"sf_id"];
					}
					testSVMXDEVMap.value = sf_id;
					
					[record_SVMXDEV.valueMap addObject:testSVMXDEVMap];
					[testSVMXDEVMap release];
					
					if(appDelegate.speacialSyncIsGoingOn)
					{
						[appDelegate.databaseInterface deleterecordsFromConflictTableForOperationType:PUT_DELETE overrideFlag:RETRY table_name:SYNC_ERROR_CONFLICT id_value:sf_id field_name:@"sf_id"];
					}
					
				}
				
				
				SVMXDEVmap.key = @"Object_Name";
				SVMXDEVmap.value = object_name;
				
				[SVMXDEVmap.valueMap addObject:record_SVMXDEV];
				[sfmRequest.valueMap addObject:SVMXDEVmap];
				
				[SVMXDEVmap release];
				[record_SVMXDEV release];
			}
			
		}
       
    }
	@catch (NSException *exp)
	{
        SMLog(kLogLevelError,@"Exception Name OptimizedSyncCalls.m :Put %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason OptimizedSyncCalls.m :Put %@",exp.reason);
    }
	
	return sfmRequest;
}

-(void) tx_fetch
{
    @try
	{
		[INTF_WebServicesDefServiceSvc initialize];
		
		INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = [[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init] autorelease];
		sessionHeader.sessionId = appDelegate.session_Id;;
		
		INTF_WebServicesDefServiceSvc_CallOptions * callOptions = [[[INTF_WebServicesDefServiceSvc_CallOptions alloc] init] autorelease];
		callOptions.client = nil;
		
		INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = [[[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init] autorelease];
		debuggingHeader.debugLevel = 0;
		
		INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = [[[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init] autorelease];
		allowFieldTruncationHeader.allowFieldTruncation = NO;
		
		
		INTF_WebServicesDefBinding * binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
		binding.logXMLInOut = [appDelegate enableLogs];
		
		INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  * datasync = [[[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init]   autorelease];
		
		INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init] autorelease];
		sfmRequest.eventName = @"TX_FETCH_OPTIMZED";
		sfmRequest.eventType = @"SYNC";
		
		sfmRequest.profileId = appDelegate.current_userId;
		sfmRequest.userId  = appDelegate.current_userId;
		sfmRequest.groupId = appDelegate.organization_Id;
		sfmRequest.value = syncRequestId;
		
		
		/*Mem Opt*/
		NSMutableDictionary * dict = [[appDelegate.databaseInterface getAllRecordsFromRecordsHeap]retain];
		NSArray * allKeys = [dict allKeys];
		
		//If no records exists dont send the response
		if([allKeys count] == 1)
		{
			SMLog(kLogLevelVerbose,@"NO getRecords ");
			appDelegate.Incremental_sync_status = TX_FETCH_OPTIMIZED_DONE;
			return;
		}
		for(int i = 0 ; i < [allKeys count] ; i++)
		{
			NSString * object_api_name = [allKeys objectAtIndex:i];
			
			if ([object_api_name isEqualToString:@"LAST_BATCH"])
				continue;
			
			if([object_api_name length] != 0 && ![object_api_name isEqualToString:@""])
			{
				INTF_WebServicesDefServiceSvc_SVMXMap  * SVMXDEVmap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
				SVMXDEVmap.key = @"TX_OBJECT" ;
				SVMXDEVmap.value = object_api_name; //object  api name
				NSMutableArray * array_of_record_ids = [dict  objectForKey:object_api_name];
				
				SMLog(kLogLevelVerbose,@"OBJECT = %@, COUNT + %D", object_api_name, [array_of_record_ids count]);
				for(NSString * record_id in array_of_record_ids)
				{
					NSString * record_id_str = (NSString *)record_id;
					
					if(appDelegate.speacialSyncIsGoingOn)
					{
						[appDelegate.databaseInterface DeleterecordFromTableWithSf_Id:SYNC_ERROR_CONFLICT sf_id:record_id_str withColumn:@"sf_id"];
					}
					
					[SVMXDEVmap.values addObject:record_id_str];
				}
				[sfmRequest.valueMap addObject:SVMXDEVmap];
				[SVMXDEVmap release];
			}
		}
		
		//Last Batch
		INTF_WebServicesDefServiceSvc_SVMXMap * lastBatch = [[[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init] autorelease];
		lastBatch.key = @"LAST_BATCH";
		lastBatch.value = [dict objectForKey:@"LAST_BATCH"];
		
		[dict release];
		//ADD SVMXDEVlient : changed krishna
        INTF_WebServicesDefServiceSvc_SVMXDEVlient  * SVMXDEV_client = [appDelegate getSVMXDEVlientObject];
        
        [sfmRequest addClientInfo:SVMXDEV_client];
		[sfmRequest addValueMap:lastBatch];
        [datasync setRequest:sfmRequest];
		
	
		[binding INTF_DataSync_WSAsyncUsingParameters:datasync
										SessionHeader:sessionHeader
										  CallOptions:callOptions
									  DebuggingHeader:debuggingHeader
						   AllowFieldTruncationHeader:allowFieldTruncationHeader delegate:appDelegate.wsInterface];
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name OptimizedSyncCalls :tx_fetch %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason OptimizedSyncCalls :tx_fetch %@",exp.reason);
    }
}



- (void) parseOptimizedDownloadCriteriaResponse:(NSString *)event_name response:(NSMutableArray *) array;
{
	NSString * temp_event_name = @"";
	
	if ([event_name isEqualToString:@"GET_INSERT_DC_OPTIMZED"])
	{
		temp_event_name = GET_INSERT;
	}
	else if ([event_name isEqualToString:@"GET_UPDATE_DC_OPTIMZED"])
	{
		temp_event_name = GET_UPDATE;
	}
	else if ([event_name isEqualToString:@"GET_DELETE_DC_OPTIMZED"])
	{
		temp_event_name = GET_DELETE;
	}
	
	
	callBackValue = FALSE;
	for (int i = 0; i < [array count]; i++)
	{
		INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
		
		NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
		
		if ([key isEqualToString:GET_DELETE_DC_OPTIMZED])
		{
			temp_event_name = GET_DELETE;
			[self parseGetOptimizedData:temp_event_name data:svmxMap.valueMap];
		}
		else if ([key isEqualToString:GET_INSERT_DC_OPTIMZED])
		{
			temp_event_name = GET_INSERT;
			[self parseGetOptimizedData:temp_event_name data:svmxMap.valueMap];
		}
		else if ([key isEqualToString:GET_UPDATE_DC_OPTIMZED])
		{
			temp_event_name = GET_UPDATE;
			[self parseGetOptimizedData:temp_event_name data:svmxMap.valueMap];
		}
		else if ([key isEqualToString:GET_DELETE])
		{
			[self parseGetOptimizedData:key data:svmxMap.valueMap];
		}
		else if ([key isEqualToString:GET_UPDATE])
		{
			[self parseGetOptimizedData:key data:svmxMap.valueMap];
		}
		else if ([key isEqualToString:GET_INSERT])
		{
			[self parseGetOptimizedData:key data:svmxMap.valueMap];
		}
		else if ([key isEqualToString:@"PUT_DELETE"])
		{
			NSString * delete_event_name = key;
			NSMutableArray * internal_response =  svmxMap.lstInternal_Response;
			
			for (int i = 0; i < [internal_response count]; i++)
			{
				INTF_WebServicesDefServiceSvc_INTF_SFMResponse * wsResponse = [internal_response objectAtIndex:i];
				
				NSMutableArray * delete_array = wsResponse.valueMap;
				
				[self put_delete:delete_event_name valuemap:delete_array];
			}

		}
		else if ([key isEqualToString:@"PUT_UPDATE"])
		{
			NSString * updateEvent_name = key;
			NSMutableArray * internal_response =  svmxMap.lstInternal_Response;
			
			for (int i = 0; i < [internal_response count]; i++)
			{
				INTF_WebServicesDefServiceSvc_INTF_SFMResponse * wsResponse = [internal_response objectAtIndex:i];
				
				NSMutableArray * update_array = wsResponse.valueMap;
				
				[self put_update:updateEvent_name valuemap:update_array];
			}
		}
		else if ([key isEqualToString:@"PUT_INSERT"])
		{
			NSString * insertEventName = key;
			
			NSMutableArray * insert_internal_response = svmxMap.lstInternal_Response;
			
			for (int i = 0; i < [insert_internal_response count]; i++)
			{
				INTF_WebServicesDefServiceSvc_INTF_SFMResponse * wsResponse = [insert_internal_response objectAtIndex:i];
				
				NSMutableArray * insert_array = wsResponse.valueMap;
				
				[self put_insert:insertEventName valuemap:insert_array];
				
			}
		}
		else if ([key isEqualToString:@"CALL_BACK"])
		{
			callBackValue = [svmxMap.value boolValue];
			 self.callBackValuemap = svmxMap.valueMap;
		}
		
		else if ([key isEqualToString:@"LAST_SYNC"])
		{
			self.lastSyncTime = svmxMap.value;
		}
	}
	appDelegate.Incremental_sync_status = ONE_CALL_SYNC_DONE;
}

//9644
- (void)deleteRecordIDsFromTrailerAndObjectTables:(NSDictionary *)safeToDeleteIDs
{
    NSArray *objectNames = [safeToDeleteIDs allKeys];
    for(NSString *objectName in objectNames)
    {
        if([appDelegate.dataBase isTabelExistInDB:objectName])
        {
            NSArray *listOfRecordIDs = [safeToDeleteIDs objectForKey:objectName];
            NSString * deleteQuery = [listOfRecordIDs componentsJoinedByString:@","];
            NSArray *columnsList = [NSArray arrayWithObjects:@"local_id", nil];
            NSString *filterCriteria = [NSString stringWithFormat:@"sf_id IN (%@)",deleteQuery];
            NSArray *locaIDsArray = [appDelegate.dataBase getAllRecordsFromTable:SYNC_RECORD_HEAP
                                                                      forColumns:columnsList
                                                                  filterCriteria:filterCriteria
                                                                           limit:nil];
            NSMutableArray *localIds = [[NSMutableArray alloc] init];
            for(NSDictionary *localIDDict in locaIDsArray)
            {
                NSString *localID = [localIDDict objectForKey:@"local_id"];
                if([localID length])
                    [localIds addObject:[NSString stringWithFormat:@"'%@'",localID]];
            }
            NSString *deleteQueryForObjectTable = [localIds componentsJoinedByString:@","];
            [localIds release];
            localIds = nil;
            NSString *dataTrailerDeleteQuery = [NSString stringWithFormat:@"DELETE FROM sync_Records_Heap WHERE sf_id in (%@)",deleteQuery];
            SMLog(kLogLevelVerbose,@" Query to Delete Records from sync_Records_Heap Table = %@",dataTrailerDeleteQuery);
            [appDelegate.dataBase executeQuery:dataTrailerDeleteQuery];
            NSString *objectDeleteQuery = [NSString stringWithFormat:@"DELETE FROM `%@` WHERE local_id in (%@)",objectName,deleteQueryForObjectTable];
            if([appDelegate.databaseInterface ColumnExists:@"Id" tableName:objectName])
            {
                SMLog(kLogLevelVerbose,@" Query to Delete Records from %@ table = %@",objectName,objectDeleteQuery);
                [appDelegate.dataBase executeQuery:objectDeleteQuery];
            }
            NSString *dataTrailerTableDeleteQuery = [NSString stringWithFormat:@"DELETE FROM SFDATATRAILER WHERE local_id in (%@)",deleteQueryForObjectTable];
            SMLog(kLogLevelVerbose,@" Query to Delete Records from SFDATATRAILER Table = %@",dataTrailerTableDeleteQuery);
            [appDelegate.dataBase executeQuery:dataTrailerTableDeleteQuery];
            
            
        }
    }
}

- (void) parseTXFetch:(NSMutableArray *) array
{
	NSAutoreleasePool * autoreleasePool = [[NSAutoreleasePool alloc] init];
	
	SMLog(kLogLevelVerbose,@"  TX_FETCH Response recived: %@", [NSDate date]);
	SMLog(kLogLevelVerbose,@"  TX_FETCH Processing starts: %@", [NSDate date]);
	NSMutableDictionary * record_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
	NSMutableDictionary *safeToDeleteIDs = [[NSMutableDictionary alloc] init];//9644
	NSArray * keys_ = [[NSArray alloc] initWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", nil];
	for (int i = 0; i < [array count]; i++)
	{
		INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
		NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
		
        NSString *safeToDeleteKey = svmxMap.key;
        NSMutableArray * valueMap = [svmxMap valueMap];
        //9644
        if(safeToDeleteKey && ([safeToDeleteKey caseInsensitiveCompare:@"SAFE_TO_DELETE"] == NSOrderedSame))
        {
            for (int j = 0; j < [valueMap count]; j++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
                NSString *objName = record_map.key;
                NSArray * safeToDeleteRecordIDsFromMap = record_map.values;
                NSMutableArray *safeToDeleteRecordIDs = [[NSMutableArray alloc] init];
                for(NSString *record in safeToDeleteRecordIDsFromMap)
                {
                    if(record && [record length])
                        [safeToDeleteRecordIDs addObject:[NSString stringWithFormat:@"'%@'",record]];
                }
                if([safeToDeleteRecordIDs count])
                    [safeToDeleteIDs setObject:safeToDeleteRecordIDs forKey:objName];
                [safeToDeleteRecordIDs release];
            }
            
        }
        else{		
		for (int j = 0; j < [valueMap count]; j++)
		{
			INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
			NSString * key = (record_map.key!= nil) ?record_map.key:@"";//local_id
			NSString * json_record = record_map.value;
			
			//  NSString * temp_json_string = [[NSString alloc] initWithString:json_record];
			
			NSMutableString * temp_json_string = [[NSMutableString alloc] initWithString:json_record];
			//fetch id from the record
			NSString * SF_id = [appDelegate.wsInterface getIdFromJsonString:temp_json_string];
			
			/* For initial sync do not escape the single quote as it is handled by sqlite3_bind :InitialSync-shr*/
			if(appDelegate.do_meta_data_sync != ALLOW_META_AND_DATA_SYNC) {
				
                //008843
                //Commenting the below line as we are using sqlite3_bind function which will escape the single quote on its own.
                // Same has been done in Normal sync
                // NSInteger val =  [temp_json_string replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [temp_json_string length])];
                //SMLog(kLogLevelVerbose,@"%d" , val);
			}
			
			
			NSArray * allkeys = [record_dict allKeys];
			BOOL flag = FALSE;
			
			
			for( NSString * temp in allkeys )
			{
				if([temp isEqualToString:object_name])
				{
					flag = TRUE;
				}
			}
			if(flag)
			{
				NSArray * objects = [[NSArray alloc] initWithObjects:key, temp_json_string,SF_id, nil];
				NSDictionary * dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys_];
				NSMutableArray * array1 = [record_dict objectForKey:object_name];
				[array1 addObject:dict];
				[dict release];
				[objects release];
			}
			else
			{
				NSArray * objects = [[NSArray alloc] initWithObjects:key, temp_json_string,SF_id, nil];
				NSDictionary * dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys_];
				NSMutableArray * array1 = [[NSMutableArray alloc] initWithCapacity:0];
				[array1 addObject:dict];
				[record_dict setObject:array1 forKey:object_name];
				[array1 release];
				[dict release];
				[objects release];
			}
			[SF_id release];
			[temp_json_string release];
		}
    }
	}
	
	[keys_ release];
    if([safeToDeleteIDs count])//9644
        [self deleteRecordIDsFromTrailerAndObjectTables:safeToDeleteIDs];
    [safeToDeleteIDs release];
    safeToDeleteIDs = nil;

	SMLog(kLogLevelVerbose,@"  TX_FETCH Processing ends: %@", [NSDate date]);
	[appDelegate.databaseInterface updateAllRecordsToSyncRecordsHeap:record_dict];
	
	[record_dict release];
	
	[self tx_fetch];      	
	[autoreleasePool drain];

}

- (void) parseGetOptimizedData:(NSString *)eventname data:(NSMutableArray *)array
{
	NSMutableDictionary * record_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	
	for (int i = 0; i < [array count]; i++)
	{
		INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [array objectAtIndex:i];
		
		NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
		NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
	
	
		if([key isEqualToString:@"LAST_SYNC"] || [key isEqualToString:@"SYNC_TIME_STAMP"])
		{
			if([eventname isEqualToString:GET_INSERT])
			{
				appDelegate.wsInterface.insert_last_sync_time = object_name;
			}
			else if([eventname isEqualToString:GET_UPDATE])
			{
				appDelegate.wsInterface.update_last_sync_time = object_name;
			}
			else if ([eventname isEqualToString:GET_DELETE])
			{
				appDelegate.wsInterface.delete_last_sync_time = object_name;
			}
		}
        else if([key isEqualToString:GET_UPDATE_LAST_SYNC_TIME]) // Damodar : Defect 8593
        {
            appDelegate.wsInterface.get_update_last_sync_time = object_name;
        }
		else if ([key isEqualToString:@"CALL_BACK"])
		{
			callBackValue = [svmxMap.value boolValue];
		}
		else if ([key isEqualToString:@"PARTIAL_EXECUTED_OBJECT"])
		{
			appDelegate.initital_sync_object_name = (svmxMap.value != nil)?svmxMap.value:@"";
		}
		else if([key isEqualToString:@"LAST_INDEX"])
		{
			appDelegate.initial_Sync_last_index = (svmxMap.value != nil)?svmxMap.value:@"";
		}
		else if([key isEqualToString:DOWNLOAD_CRITERIA_OBJECTS])
		{
			NSMutableArray * dc_objects = svmxMap.values;
			for(NSString  * str in dc_objects)
			{
				NSArray * arr = [str componentsSeparatedByString:@","];
				if([arr count] <= 2)
				{
					NSString * objectName =[arr objectAtIndex:0];
					NSString * whereclause = [arr objectAtIndex:1];
					[appDelegate.wsInterface.dcobjects_incrementalSync setObject:whereclause forKey:objectName];
				}
			}
		}
		else if ([key isEqualToString:@"ALL_EVENTS"])
		{
			NSMutableArray * allEvents = [svmxMap valueMap];
			
			for (INTF_WebServicesDefServiceSvc_SVMXMap * eventId in allEvents)
			{
				NSString * eventString = eventId.value;
				self.purgingEventIdArray =  [appDelegate.wsInterface getIdsFromJsonString:eventString];
				
			}
		}
		else if([key isEqualToString:@"Object_Name"] ||[key isEqualToString:@"Parent_Object"] || [key isEqualToString:@"Child_Object"])
		{
			NSString * record_type = @"";
			BOOL isChild = [appDelegate.databaseInterface  IsChildObject:object_name];
			if(isChild)
			{
				record_type = DETAIL;
			}
			else                   //Child_Object
			{
				record_type = MASTER;
			}
			
			NSMutableArray * valueMap = [svmxMap valueMap];
			
			for (int j = 0; j < [valueMap count]; j++)
			{
				INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
				NSString * field = (record_map.key!= nil) ?record_map.key:@"";//local_id
				NSString * fieldValue    = (record_map.value != nil) ? record_map.value:@"";
				
				if([field isEqualToString:@"Fields"])
				{
					NSMutableArray * values =  [[appDelegate.wsInterface getIdsFromJsonString:fieldValue] retain];
					
					for (int k = 0; k < [values count]; k++)
					{
						
						NSString * local_id = @"";
						NSString * sf_id    = [values objectAtIndex:k];
						
						NSArray * allkeys = [record_dict allKeys];
						BOOL flag = FALSE;
						
						for( NSString * temp in allkeys )
						{
							if([temp isEqualToString:object_name])
							{
								flag = TRUE;
								break;
							}
						}
						//NSString * sync_type =
						if(flag)
						{
							NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,eventname,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
							NSMutableArray * array = [record_dict objectForKey:object_name];
							[array addObject:dict];
						}
						else
						{
							NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,eventname,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
							NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
							[array addObject:dict];
							[record_dict setObject:array forKey:object_name];
						}
						
					}
					[values release];
					
				}
				
			}
		}
	}
	[appDelegate.databaseInterface  insertRecordIdsIntosyncRecordHeap:record_dict];
}


- (void) put_insert:(NSString *)event_name valuemap:(NSMutableArray *)insert_array
{
	NSString * insertEventName = event_name;
	NSMutableDictionary * record_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	NSMutableDictionary * conflict_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	
	for (int insert = 0; insert < [insert_array count]; insert++)
	{
		INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [insert_array objectAtIndex:insert];
		
		NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
		NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
		
		if([key isEqualToString:@"LAST_SYNC"])
		{
			appDelegate.wsInterface.insert_last_sync_time = object_name ;
		}
		else  if([key isEqualToString:@"Parent_Object"] || [key isEqualToString:@"Child_Object"])
		{
			NSString * record_type = @"";
			if([key isEqualToString:@"Parent_Object"])
			{
				record_type = MASTER;
			}
			else if ([key isEqualToString:@"Child_Object"])//Child_Object
			{
				record_type = DETAIL;
			}
			
			NSMutableArray * valueMap = [svmxMap valueMap];
			
			for (int j = 0; j < [valueMap count]; j++)
			{
				INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
				NSString * local_id = (record_map.key!= nil) ?record_map.key:@"";//local_id
				NSString * sf_id    = (record_map.value != nil) ? record_map.value:@"";
				
				NSArray * allkeys = [record_dict allKeys];
				BOOL flag = FALSE;
				
				for( NSString * temp in allkeys )
				{
					if([temp isEqualToString:object_name])
					{
						flag = TRUE;
						break;
					}
				}
				if(flag)
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
					NSMutableArray * array = [record_dict objectForKey:object_name];
					[array addObject:dict];
				}
				else
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
					NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
					[array addObject:dict];
					[record_dict setObject:array forKey:object_name];
				}
				
			}
		}
		else if ( [key isEqualToString:@"ERROR"])
		{
			NSMutableArray * valueMap = [svmxMap valueMap];
			for (int j = 0; j < [valueMap count]; j++)
			{
				INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
				
				NSString * record_type = @"";
				NSString * object_name  = (record_map.key!= nil) ?record_map.key:@"";//local_id
				NSString * sf_id = @""  , * local_id = @"";
				
				NSString * error_message =  (record_map.value != nil) ? record_map.value:@"";
				
				NSMutableArray *  errorvaluemap  = record_map.valueMap;
				
				for(int w = 0 ; w < [errorvaluemap count]; w++)
				{
					INTF_WebServicesDefServiceSvc_SVMXMap * error_SVMXDEV_map = [errorvaluemap objectAtIndex:w];
					local_id = (error_SVMXDEV_map.key!= nil )?error_SVMXDEV_map.key:@"";
					sf_id    = (error_SVMXDEV_map.value != nil)? error_SVMXDEV_map.value:@"";
				}
				
				
				BOOL isChild = [appDelegate.databaseInterface  IsChildObject:object_name];
				if(isChild)
				{
					record_type = DETAIL;
				}
				else                   //Child_Object
				{
					record_type = MASTER;
				}
				
				NSArray * allkeys = [conflict_dict allKeys];
				BOOL flag = FALSE;
				
				for( NSString * temp in allkeys)
				{
					if([temp isEqualToString:object_name])
					{
						flag = TRUE;
						break;
					}
				}
				if(flag)
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id ,sf_id,insertEventName,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
					NSMutableArray * array = [conflict_dict objectForKey:object_name];
					[array addObject:dict];
				}
				else
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id ,sf_id,insertEventName,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
					NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
					[array addObject:dict];
					[conflict_dict setObject:array forKey:object_name];
				}
			}
		}
	}
	SMLog(kLogLevelVerbose,@"  GET_INSERT/PUT_INSERT Processing ends: %@", [NSDate date]);
	[appDelegate.databaseInterface insertRecordIdsIntosyncRecordHeap:record_dict];
	[appDelegate.databaseInterface insertSyncConflictsIntoSYNC_CONFLICT:conflict_dict];
}

- (void) put_update:(NSString *)event_name valuemap:(NSMutableArray *)update_array
{
	NSString * updateEvent_name = event_name;
	NSMutableDictionary * record_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	NSMutableDictionary * conflict_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
		
	for (int up = 0; up < [update_array count]; up++)
	{
		INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [update_array objectAtIndex:up];
		
		NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
		NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
		
		if([key isEqualToString:@"LAST_SYNC"] || [key isEqualToString:@"SYNC_TIME_STAMP"])
		{
			self.putUpdateSyncTime = object_name;
		}
		else if([key isEqualToString:@"Object_Name"] ||[key isEqualToString:@"Parent_Object"] || [key isEqualToString:@"Child_Object"])
		{
			NSString * record_type = @"";
			BOOL isChild = [appDelegate.databaseInterface  IsChildObject:object_name];
			if(isChild)
			{
				record_type = DETAIL;
			}
			else                   //Child_Object
			{
				record_type = MASTER;
			}
			
			NSMutableArray * valueMap = [svmxMap valueMap];
			for (int j = 0; j < [valueMap count]; j++)
			{
				INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
				NSString * local_id = (record_map.key!= nil) ?record_map.key:@"";//local_id
				NSString * sf_id    = (record_map.value != nil) ? record_map.value:@"";
				
				NSArray * allkeys = [record_dict allKeys];
				BOOL flag = FALSE;
				
				for( NSString * temp in allkeys )
				{
					if([temp isEqualToString:object_name])
					{
						flag = TRUE;
						break;
					}
				}
				if(flag)
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,updateEvent_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
					NSMutableArray * array = [record_dict objectForKey:object_name];
					[array addObject:dict];
				}
				else
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,updateEvent_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
					NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
					[array addObject:dict];
					[record_dict setObject:array forKey:object_name];
				}
			}
		}
		else if ([key isEqualToString:@"CONFLICT"] || [key isEqualToString:@"ERROR"])
		{
			NSMutableArray * valueMap = [svmxMap valueMap];
			for (int j = 0; j < [valueMap count]; j++)
			{
				INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
				
				NSString * record_type = @"";
				NSString * object_name  = (record_map.key!= nil) ?record_map.key:@"";//local_id
				NSString * sf_id = @""  , * local_id = @"";
				
				NSString * error_message =  (record_map.value != nil) ? record_map.value:@"";
				
				NSMutableArray *  errorvaluemap  = record_map.valueMap;
				
				for(int w = 0 ; w < [errorvaluemap count]; w++)
				{
					INTF_WebServicesDefServiceSvc_SVMXMap * error_SVMXDEV_map = [errorvaluemap objectAtIndex:w];
					local_id = (error_SVMXDEV_map.key!= nil )?error_SVMXDEV_map.key:@"";
					sf_id    = (error_SVMXDEV_map.value != nil)? error_SVMXDEV_map.value:@"";
				}
				
				
				BOOL isChild = [appDelegate.databaseInterface  IsChildObject:object_name];
				if(isChild)
				{
					record_type = DETAIL;
				}
				else                   //Child_Object
				{
					record_type = MASTER;
				}
				
				NSArray * allkeys = [conflict_dict allKeys];
				BOOL flag = FALSE;
				
				for( NSString * temp in allkeys)
				{
					if([temp isEqualToString:object_name])
					{
						flag = TRUE;
						break;
					}
				}
				if(flag)
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id ,sf_id,updateEvent_name,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
					NSMutableArray * array = [conflict_dict objectForKey:object_name];
					[array addObject:dict];
				}
				else
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id,sf_id,updateEvent_name,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
					NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
					[array addObject:dict];
					[conflict_dict setObject:array forKey:object_name];
				}
				
			}
		}
	}
	
	SMLog(kLogLevelVerbose,@"UPDATE %@", record_dict);
	[appDelegate.databaseInterface  insertRecordIdsIntosyncRecordHeap:record_dict];
	[appDelegate.databaseInterface  insertSyncConflictsIntoSYNC_CONFLICT:conflict_dict];
}
- (void) put_delete:(NSString *)event_name valuemap:(NSMutableArray *)delete_array
{
	NSString * delete_event_name = event_name;
	NSMutableDictionary * record_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	NSMutableDictionary * conflict_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
		
	for (int del = 0; del < [delete_array count]; del++)
	{
		INTF_WebServicesDefServiceSvc_SVMXMap * svmxMap = [delete_array objectAtIndex:del];
		
		NSString * key = (svmxMap.key != nil)?(svmxMap.key):@"";
		NSString * object_name = (svmxMap.value != nil)?(svmxMap.value):@"";
		
		if([key isEqualToString:@"LAST_SYNC"] || [key isEqualToString:@"SYNC_TIME_STAMP"])
		{
			appDelegate.wsInterface.delete_last_sync_time = object_name;
		}
		else  if([key isEqualToString:@"Object_Name"] ||[key isEqualToString:@"Parent_Object"] || [key isEqualToString:@"Child_Object"])
		{
			NSString * record_type = DETAIL;
			
			NSMutableArray * valueMap = [svmxMap valueMap];
			for (int j = 0; j < [valueMap count]; j++)
			{
				INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
				NSString * local_id = (record_map.key!= nil) ?record_map.key:@"";//local_id
				NSString * sf_id    = (record_map.value != nil) ? record_map.value:@"";
				
				NSArray * allkeys = [record_dict allKeys];
				BOOL flag = FALSE;
				
				for( NSString * temp in allkeys )
				{
					if([temp isEqualToString:object_name])
					{
						flag = TRUE;
					}
				}
				
				if(flag)
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,delete_event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",nil]];
					NSMutableArray * array = [record_dict objectForKey:object_name];
					[array addObject:dict];
				}
				else
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id, @"",sf_id,delete_event_name,record_type,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE", @"RECORD_TYPE",nil]];
					NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
					[array addObject:dict];
					[record_dict setObject:array forKey:object_name];
				}
			}
		}
		else if ([key isEqualToString:@"CONFLICT"] || [key isEqualToString:@"ERROR"])
		{
			NSMutableArray * valueMap = [svmxMap valueMap];
			for (int j = 0; j < [valueMap count]; j++)
			{
				INTF_WebServicesDefServiceSvc_SVMXMap * record_map = [valueMap objectAtIndex:j];
				
				NSString * record_type = @"";
				NSString * object_name  = (record_map.key!= nil) ?record_map.key:@"";//local_id
				NSString * sf_id = @""  , * local_id = @"";
				
				NSString * error_message =  (record_map.value != nil) ? record_map.value:@"";
				
				NSMutableArray *  errorvaluemap  = record_map.valueMap;
				
				for(int w = 0 ; w < [errorvaluemap count]; w++)
				{
					INTF_WebServicesDefServiceSvc_SVMXMap * error_SVMXDEV_map = [errorvaluemap objectAtIndex:w];
					local_id = (error_SVMXDEV_map.key!= nil )?error_SVMXDEV_map.key:@"";
					sf_id    = (error_SVMXDEV_map.value != nil)? error_SVMXDEV_map.value:@"";
				}
				
				
				BOOL isChild = [appDelegate.databaseInterface  IsChildObject:object_name];
				if(isChild)
				{
					record_type = DETAIL;
				}
				else                   //Child_Object
				{
					record_type = MASTER;
				}
				
				NSArray * allkeys = [conflict_dict allKeys];
				BOOL flag = FALSE;
				
				for( NSString * temp in allkeys)
				{
					if([temp isEqualToString:object_name])
					{
						flag = TRUE;
						break;
					}
				}
				if(flag)
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id ,sf_id,delete_event_name,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
					NSMutableArray * array = [conflict_dict objectForKey:object_name];
					[array addObject:dict];
				}
				else
				{
					NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:local_id ,sf_id,delete_event_name,record_type,error_message,key,nil] forKeys:[NSArray arrayWithObjects:@"LOCAL_ID",@"SF_ID",@"SYNC_TYPE", @"RECORD_TYPE",@"ERROR_MSG",@"ERROR_TYPE",nil]];
					NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
					[array addObject:dict];
					[conflict_dict setObject:array forKey:object_name];
				}
			}
		}
	}
	
	[appDelegate.databaseInterface  insertRecordIdsIntosyncRecordHeap:record_dict];
	[appDelegate.databaseInterface  insertSyncConflictsIntoSYNC_CONFLICT:conflict_dict];
}


- (void) dealloc
{
	[callBackContextKey release];
	[callBackContextValue release];
	[syncRequestId release];
	[lastSyncTime release];
	[putUpdateSyncTime release];
	[purgingEventIdArray release];
	[callBackValuemap release];
	[super dealloc];
}


@end
