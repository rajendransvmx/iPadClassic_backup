//
//  GetPriceBookUtil.m
//  iService
//
//  Created by Shravya shridhar on 2/26/13.
//
//

#import "PriceBookData.h"
#import "iServiceAppDelegate.h"
#import "Utility.h"
@interface PriceBookData()

- (NSDictionary *) createTargetRecordFromCurrentContext:(NSDictionary *)sfmpage;
- (NSString *) getAllFieldsForObjectName:(NSString *)hdr_object_name;
- (NSArray *)createPriceBookFromTarget:(NSDictionary *)targetDictionary;


@end
@implementation PriceBookData

@synthesize targetObject;
@synthesize priceBookComponents;
@synthesize jsonRepresentation;

- (void)dealloc {
    [targetObject release];
    [priceBookComponents release];
    [jsonRepresentation release];
    [super dealloc];
}
- (id)initWithSfmPage:(NSDictionary *)sfmPage {
    self = [super init];
    if (self != nil) {
        NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
        NSDictionary *tempDictionary = [self createTargetRecordFromCurrentContext:sfmPage];
        self.targetObject = tempDictionary;
        
        NSArray *componentsArray = [self createPriceBookFromTarget:tempDictionary];
        self.priceBookComponents = componentsArray;
        [aPool release];
        aPool = nil;
    }
    return self;
}
/* GET_PRICE_JS-shr*/
- (NSDictionary *) createTargetRecordFromCurrentContext:(NSDictionary *)sfmpage
{
    
    NSMutableDictionary *targetRecordDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    
    @try{
        
        [targetRecordDictionary setObject:appDelegate.sfmPageController.processId forKey:@"sfmProcessId"];
        
        //Header  object
        NSMutableDictionary *targetHeaderDictionary = [[NSMutableDictionary alloc] init];
        
        
        
        NSDictionary * hdr_object = [sfmpage objectForKey:gHEADER];
        NSString * hdr_object_name = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
        [targetHeaderDictionary setObject:hdr_object_name forKey:@"objName"];
        
        NSMutableDictionary * hdrData = [hdr_object objectForKey:gHEADER_DATA];
        
        
        //get ALL records For  record_id
        NSString *  header_sf_id = [appDelegate.databaseInterface  getSfid_For_LocalId_From_Object_table:hdr_object_name local_id:appDelegate.sfmPageController.recordId];
        
        NSString * field_string = [self getAllFieldsForObjectName:hdr_object_name];
        
        NSMutableDictionary * header_all_fields = [appDelegate.databaseInterface getRecordsGPForRecordId:appDelegate.sfmPageController.recordId ForObjectName:hdr_object_name fields:field_string];
        
        NSArray *   header_All_fields_keys = [header_all_fields allKeys];
        NSArray * headerData_keys = [hdrData allKeys];
        
        for(NSString * key in header_All_fields_keys)
        {
            NSString * value = [header_all_fields objectForKey:key];
            
            if(![headerData_keys containsObject:key])
            {
                [hdrData  setObject:value forKey:key];
            }
        }
        
        NSArray * allkeys_HeaderData = [hdrData allKeys];
        
        //Set header page layout
        NSString * layout_id = [hdr_object objectForKey:gHEADER_HEADER_LAYOUT_ID];
        [targetHeaderDictionary setObject:layout_id forKey:@"pageLayoutId"];
        
        
        NSMutableDictionary *targetDictionary = [[NSMutableDictionary alloc] init];
        
        NSString *headerId = [hdrData objectForKey:@"Id"];
        if (headerId != nil) {
            [targetDictionary setObject:headerId forKey:@"targetRecordId"];
        }
        
        
        
        NSArray *header_sections = [hdr_object objectForKey:gHEADER_SECTIONS];
        NSMutableArray *targetAsKeyValueArray = [[NSMutableArray alloc] init];
        
        for (int i=0;i<[header_sections count];i++)
        {
            NSDictionary * section = [header_sections objectAtIndex:i];
            NSArray *section_fields = [section objectForKey:gSECTION_FIELDS]; 
            for (int j=0;j<[section_fields count];j++)
            {
                NSDictionary *section_field = [section_fields objectAtIndex:j];
                
                NSString * key = [section_field objectForKey:gFIELD_VALUE_KEY];
                NSString * value = [section_field objectForKey:gFIELD_VALUE_VALUE];
                
                NSString * field_data_type = [appDelegate.databaseInterface getFieldDataType:hdr_object_name filedName:[section_field objectForKey:gFIELD_API_NAME]];
                
                if([field_data_type isEqualToString:@"boolean"])
                {
                    if ([value isEqualToString:@"1"] || [value isEqualToString:@"true"] || [value isEqualToString:@"True"])
                    {
                        value = @"true";
                    }
                    else
                    {
                        value = @"false";
                    }
                }
                
                //shr
                NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc] init];
                NSString *tempFieldName = [section_field objectForKey:gFIELD_API_NAME];
                if (tempFieldName != nil) {
                    [currentDictionary setObject:tempFieldName forKey:@"key"];
                }
                
                if (key != nil) {
                    [currentDictionary setObject:key forKey:@"value"];
                }
                if (value != nil) {
                    [currentDictionary setObject:value forKey:@"value1"];
                }
                
                [targetAsKeyValueArray addObject:currentDictionary];
                [currentDictionary release];
                currentDictionary = nil;
                
                NSString * sectionFieldAPI = [section_field objectForKey:gFIELD_API_NAME];
               
                for (NSString * key in allkeys_HeaderData)
                {
                    NSString * uppercaseKey = [key uppercaseString];
                    NSString * uppercaseFieldAPI = [sectionFieldAPI uppercaseString];
                    if([uppercaseKey isEqualToString:uppercaseFieldAPI]) 
                    {
                        
                        [hdrData removeObjectForKey:key];
                        allkeys_HeaderData = [hdrData allKeys];
                    }
                }
            }
        }
        
        //Adding hdrData objects obtained dynamically from sfmPage
        NSArray * allKeys = [hdrData allKeys];
        for (NSString * key in allKeys)
        {
            NSString * value = [hdrData objectForKey:key];
            
            
            NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc] init];
            [currentDictionary setObject:key forKey:@"key"];
            [currentDictionary setObject:value forKey:@"value"];
            [targetAsKeyValueArray addObject:currentDictionary];
            [currentDictionary release];
            currentDictionary = nil;
            
            
        }
        
        NSString * hdr_id = header_sf_id;    
        if (hdr_id != nil && ![hdr_id isKindOfClass:[NSNull class]] && ![hdr_id isEqualToString:@""])
        {
            NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc] init];
            [currentDictionary setObject:@"id" forKey:@"key"];
            [currentDictionary setObject:hdr_id forKey:@"value"];
            [targetAsKeyValueArray addObject:currentDictionary];
            [currentDictionary release];
            currentDictionary = nil;
        }
        
        
        
        [targetDictionary setObject:targetAsKeyValueArray forKey:@"targetRecordAsKeyValue"];
        
        [targetAsKeyValueArray release];
        targetAsKeyValueArray = nil;
        
        NSMutableArray *arrayTemp = [[NSMutableArray alloc] initWithObjects:targetDictionary, nil];
        [targetHeaderDictionary setObject:arrayTemp forKey:@"records"];
        
        [targetDictionary release];
        targetDictionary = nil;
        [arrayTemp release];
        arrayTemp = nil;
        
        /*HEADER record is ready */
        [targetRecordDictionary setObject:targetHeaderDictionary forKey:@"headerRecord"];
        [targetHeaderDictionary release];
        targetHeaderDictionary = nil;
        
        //child records
        NSMutableArray *detailRecordsArray = [[NSMutableArray alloc] init];
        
        NSArray * details = [sfmpage objectForKey:gDETAILS]; //as many as number of lines sections
      
        for (int i = 0; i < [details count]; i++) //parts, labor, expense for instance
        {
            NSDictionary *detail = [details objectAtIndex:i];
            
            
            NSMutableDictionary *targetDetailDictionary = [[NSMutableDictionary alloc] init];
            
            NSString * detail_object_name = [detail objectForKey:gDETAIL_OBJECT_NAME];
            NSString * detail_layout_id = [detail objectForKey:gDETAILS_LAYOUT_ID];
            NSString *parent_column_name = [detail objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
            NSString *aliasName = [detail objectForKey:gDETAIL_OBJECT_ALIAS_NAME];
            
            [targetDetailDictionary setObject:detail_object_name forKey:@"objName"];
            [targetDetailDictionary setObject:detail_layout_id forKey:@"pageLayoutId"];
            [targetDetailDictionary setObject:parent_column_name forKey:@"parentColumnName"];
            [targetDetailDictionary setObject:aliasName forKey:@"aliasName"];
            
            
            
            NSMutableArray * details_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
            NSMutableArray * details_record_ids = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
            
            
            NSMutableArray * details_deleted_records = [detail objectForKey:gDETAIL_DELETED_RECORDS];
            NSMutableArray * detailSObjectDataArray = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
            
            NSArray * detailSobjectKeys = nil;
            
            NSInteger count = 0 ;
             /* Storing the hidden fields */
           for (int j=0;j<[details_values count];j++) //parts for instance
            {
                
                NSString * details_record_id = nil;
                NSString * local_id  = @"";
                if(j < [details_record_ids count])
                {
                    local_id = [details_record_ids objectAtIndex:j];
                    NSString * sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:[detail objectForKey:gDETAIL_OBJECT_NAME] local_id:local_id];
                    details_record_id = sfid;
                    if ([details_record_id isEqualToString:@""])
                        details_record_id = nil;
                }
                
                if([detailSObjectDataArray  objectAtIndex:j] != @"")
                {
                    detailSobjectKeys = [[detailSObjectDataArray  objectAtIndex:j] allKeys];
                }
                else
                    detailSobjectKeys = nil;
                
                NSMutableArray *child_record_fields = [details_values objectAtIndex:j];
                
                NSString * field_string = [self getAllFieldsForObjectName:detail_object_name];
                
                NSMutableDictionary * detail_all_fields = nil;
                if(![local_id isEqualToString:@""])
                {
                    detail_all_fields = [appDelegate.databaseInterface getRecordsGPForRecordId:local_id ForObjectName:detail_object_name fields:field_string];
                }
                else
                {
                    NSMutableDictionary * process_components = [appDelegate.databaseInterface  getProcessComponentsForComponentType:TARGETCHILD process_id:appDelegate.sfmPageController.processId layoutId:detail_layout_id objectName:detail_object_name];
                    detail_all_fields = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
                }
                
                NSMutableArray * all_ApiNames_detail = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                for (int k=0;k<[child_record_fields count];k++) //fields of one part for instance
                {
                    NSDictionary *field = [child_record_fields objectAtIndex:k];
                    NSString * field_api_name = [field objectForKey:gVALUE_FIELD_API_NAME];
                    [all_ApiNames_detail addObject:field_api_name];
                }
                
                NSArray * detailAllRecords = [detail_all_fields  allKeys];
                
                for(NSString * detailRecordField in detailAllRecords)
                {
                    if(![all_ApiNames_detail containsObject:detailRecordField])
                    {
                        NSString * key = [detail_all_fields   objectForKey:detailRecordField];
                        
                        NSDictionary * _dict = [NSMutableDictionary  dictionaryWithObjects:[NSArray arrayWithObjects:detailRecordField, key,key,nil] forKeys:[NSArray arrayWithObjects:gVALUE_FIELD_API_NAME,gVALUE_FIELD_VALUE_KEY, gVALUE_FIELD_VALUE_VALUE,nil]];
                        [child_record_fields addObject:_dict];
                    }
                    
                }
                
            }
            
            
            NSMutableArray *targetRecordsArray = [[NSMutableArray alloc] init];
            for (int j=0;j<[details_values count];j++) //parts for instance
            {
                
                NSMutableDictionary *detailRecordDictionary = [[NSMutableDictionary alloc] init];
                
                NSString * details_record_id = nil;
                if(j < [details_record_ids count])
                {
                    
                    NSString * local_id = [details_record_ids objectAtIndex:j];
                    NSString * sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:[detail objectForKey:gDETAIL_OBJECT_NAME] local_id:local_id];
                    details_record_id = sfid;
                    if ([details_record_id isEqualToString:@""])
                        details_record_id = nil;
                  
                    [detailRecordDictionary setObject:sfid forKey:@"targetRecordId"];
                }
                
                
                if([detailSObjectDataArray  objectAtIndex:j] != @"")
                {
                    detailSobjectKeys = [[detailSObjectDataArray  objectAtIndex:j] allKeys];
                }
                else
                    detailSobjectKeys = nil;
                NSArray *child_record_fields = [details_values objectAtIndex:j];
             
                
                NSMutableArray *detailTargetRecAsKeyValue = [[NSMutableArray alloc] init];
                
                for (int k=0;k<[child_record_fields count];k++) //fields of one part for instance
                {
                    NSDictionary *field = [child_record_fields objectAtIndex:k];
                    
                    
                    NSString * key1 = [field objectForKey:gVALUE_FIELD_VALUE_KEY];
                    NSString * value1 = [field objectForKey:gVALUE_FIELD_VALUE_VALUE];
                    
                    NSString * field_data_type = [appDelegate.databaseInterface getFieldDataType:[detail objectForKey:gDETAIL_OBJECT_NAME] filedName:[field objectForKey:gVALUE_FIELD_API_NAME]];
                    
                    if([field_data_type isEqualToString:@"boolean"])
                    {
                        if ([value1 isEqualToString:@"1"] || [value1 isEqualToString:@"true"] || [value1 isEqualToString:@"True"])
                        {
                            key1 = @"true";
                            value1 = @"true";
                        }
                        else
                        {
                            key1 = @"false";
                            value1 = @"false";
                        }
                    }
                    else {
                        if ([field_data_type isEqualToString:@"datetime"]) {
                            key1 = [Utility replaceTinDateBySpace:key1];
                        }
                    }
                    
                    NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc]init];
                    [currentDictionary setObject:[field objectForKey:gVALUE_FIELD_API_NAME] forKey:@"key"];
                    [currentDictionary setObject:key1 forKey:@"value"];
                    [currentDictionary setObject:value1 forKey:@"value1"];
                    [detailTargetRecAsKeyValue addObject:currentDictionary];
                    [currentDictionary release];
                    currentDictionary = nil;
                    
                    
                    //  Cross Referencing Error
                    NSString * detailFieldApiName = [field objectForKey:gVALUE_FIELD_API_NAME];
                    if(detailSobjectKeys != nil)
                    {
                        NSMutableDictionary * detailSObjectDictionary = [detailSObjectDataArray objectAtIndex:j];
                        for(int i= 0 ; i<[detailSobjectKeys count] ; i++)
                        {
                            NSString * uppercaseString = [[detailSobjectKeys objectAtIndex:i] uppercaseString];
                            NSString * uppercastringDetailApi = [detailFieldApiName uppercaseString];
                            if([uppercaseString  isEqualToString:uppercastringDetailApi])
                            {
                                [detailSObjectDictionary removeObjectForKey:[detailSobjectKeys objectAtIndex:i]];
                                detailSobjectKeys = [[detailSObjectDataArray  objectAtIndex:j] allKeys];
                                break;
                            }
                        }
                    }
                }
                
                if(details_record_id != nil)
                {
                    NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc]init];
                    [currentDictionary setObject:@"_Id" forKey:@"key"];
                    [currentDictionary setObject:details_record_id forKey:@"value"];
                    [detailTargetRecAsKeyValue addObject:currentDictionary];
                    [currentDictionary release];
                    currentDictionary = nil;
                }
                               
                if([detailSObjectDataArray objectAtIndex:j] != @"")
                {                   
                    // Iterate thru gDETAIL_SOBJECT_ARRAY based on current iteration index
                    NSDictionary * detailSObjectDictionary = [detailSObjectDataArray objectAtIndex:j];
                    NSArray * allKeys = [detailSObjectDictionary allKeys];
                    for (NSString * key in allKeys)
                    {
                        NSString * value = [detailSObjectDictionary objectForKey:key];
                        NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc]init];
                        [currentDictionary setObject:key forKey:@"key"];
                        [currentDictionary setObject:value forKey:@"value"];
                        [detailTargetRecAsKeyValue addObject:currentDictionary];
                        [currentDictionary release];
                        currentDictionary = nil;                        
                    }
                    
                }
                
                if(details_record_id == nil )
                {
                    NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc]init];
                    [currentDictionary setObject:gDETAIL_SEQUENCE_NO forKey:@"key"];
                    [currentDictionary setObject:[detail objectForKey:gDETAIL_SEQUENCE_NO] forKey:@"value"];
                    [detailTargetRecAsKeyValue addObject:currentDictionary];
                    [currentDictionary release];
                    currentDictionary = nil;
                    
                    NSString *string = [NSString stringWithFormat:@"%d", count];
                    
                    currentDictionary = [[NSMutableDictionary alloc]init];
                    [currentDictionary setObject:gDETAIL_SEQUENCENO_GETPRICE forKey:@"key"];
                    [currentDictionary setObject:string forKey:@"value"];
                    [detailTargetRecAsKeyValue addObject:currentDictionary];
                    [currentDictionary release];
                    currentDictionary = nil;
                    
                    
                    count++;
                    
                }
                
                
                [detailRecordDictionary setObject:detailTargetRecAsKeyValue forKey:@"targetRecordAsKeyValue"];
                [targetRecordsArray addObject:detailRecordDictionary];
                
                [detailTargetRecAsKeyValue release];
                detailTargetRecAsKeyValue = nil;
                
                [detailRecordDictionary release];
                detailRecordDictionary = nil;
                
                
                
            }
            
            [targetDetailDictionary setObject:targetRecordsArray forKey:@"records"];
            [targetRecordsArray release];
            targetRecordsArray = nil;
            
            
            
            
            [detailRecordsArray addObject:targetDetailDictionary];
            [targetDetailDictionary release];
            targetDetailDictionary = nil;
        }
        
        
        
        [targetRecordDictionary setObject:detailRecordsArray forKey:@"detailRecords"];
        [detailRecordsArray release];
        detailRecordsArray = nil;
        
        
        
        /**/
        NSString *stringTemp =  [targetRecordDictionary JSONRepresentation];
        NSLog(@"%@",stringTemp);
    }@catch (NSException *exp) {
        SMLog(@"Exception Name WSInterface :getTargetRecordsFromSFMPage %@",exp.name);
        SMLog(@"Exception Reason WSInterface :getTargetRecordsFromSFMPage %@",exp.reason);
    }
    
    return targetRecordDictionary;
}

-(NSString *) getAllFieldsForObjectName:(NSString *)hdr_object_name
{
    NSDictionary * fields_dict = [appDelegate.databaseInterface getAllObjectFields:hdr_object_name tableName:SFOBJECTFIELD];
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
    
    return field_string;
    
}

- (NSArray *)createPriceBookFromTarget:(NSDictionary *)targetDictionary {
    
    NSArray *tempArray = [appDelegate.calDataBase getPriceBook:targetDictionary];
    return tempArray;
}

- (NSString *)getJSONRepresentationForJS {
    /*set the json string */
    NSDictionary *dictionartyTemp = [[NSDictionary alloc] initWithObjectsAndKeys:self.targetObject,@"target",self.priceBookComponents,@"data",nil];
    NSString *jsonRepresenationTemp =  [dictionartyTemp JSONRepresentation];
    self.jsonRepresentation = jsonRepresenationTemp;
    [dictionartyTemp release];
    dictionartyTemp = nil;
    return jsonRepresenationTemp;
}
@end
