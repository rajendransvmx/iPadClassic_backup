//
//  SMADVDownoadCriteriaResponse.m
//  iService
//
//  Created by keerti bhatnagar on 03/07/13.
//
//

#import "SMADVDownoadCriteriaResponse.h"
#import "INTF_WebServicesDefServiceSvc.h"
#import "databaseIntefaceSfm.h"

@implementation SMADVDownoadCriteriaResponse
@synthesize partialExecutedObjects;
- (BOOL) parseResponse:(NSArray *)result
{
    BOOL callBack = FALSE;
    NSString * local_id = @"";
    NSString *record_type;
    NSMutableDictionary * record_dict = [[NSMutableDictionary alloc] init];
    NSMutableArray * array = [[NSMutableArray alloc] init];
    NSString * event_name=@"";
    partialExecutedObjects=[[NSMutableDictionary alloc]init];
    for(int i=0; i<[result count]; i++)
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapObject = [result objectAtIndex:i];
        NSString *key = svmxMapObject.key;
        
        if([key isEqualToString:@"DELETE"])
        {
            
            NSArray *arrayOfDeleteObj=svmxMapObject.valueMap;
            NSArray *keys = [NSArray
                             arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE",
                             @"RECORD_TYPE",nil];

            for (INTF_WebServicesDefServiceSvc_SVMXMap * obj in arrayOfDeleteObj)
            {
                BOOL isChild = [self.dataBaseInterface IsChildObject:obj.key];
                if(isChild)
                    record_type = @"DETAIL";
                else
                    record_type = @"MASTER";
                
                NSArray *arrayOfDeleteIds = obj.values;
                for (NSMutableString *sf_id in arrayOfDeleteIds)
                {
                    event_name = @"GET_DELETE";
                    NSLog(@"%@",sf_id);
                    NSArray *values =[NSArray arrayWithObjects:local_id,
                                      @"",sf_id,event_name,record_type,nil];
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                    
                    [array addObject:dict];
                    [record_dict setObject:array forKey:obj.key];
                }
            }
          
        }
        else if ([key isEqualToString:@"CALL_BACK"])
        {
             callBack=[svmxMapObject.value boolValue];
        }
        else if ([key isEqualToString:@"PARTIAL_EXECUTED_OBJECT"])
        {
            NSString *objectName=svmxMapObject.value;
            [partialExecutedObjects setObject:objectName forKey:@"partialObject"];
        }
        else
        {
            NSArray *arrayOfObjects=svmxMapObject.valueMap;
            for (INTF_WebServicesDefServiceSvc_SVMXMap * obj in arrayOfObjects)
            {
                NSString * sf_Id = [obj.value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                SMLog(@"%@",sf_Id);
                BOOL isChild = [self.dataBaseInterface IsChildObject:key];
                if(isChild)
                    record_type = @"DETAIL";
                else
                    record_type = @"MASTER";
                
                NSArray *keys = [NSArray
                                 arrayWithObjects:@"LOCAL_ID",@"JSON_RECORD",@"SF_ID", @"SYNC_TYPE",
                                 @"RECORD_TYPE",nil];
                event_name=@"DATA_SYNC";
                NSArray *values =[NSArray arrayWithObjects:local_id,
                                  @"",sf_Id,event_name,record_type,nil];
                NSDictionary * dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                
                [array addObject:dict];
                [record_dict setObject:array forKey:key];
                
            }
        }
        
    }
    [array release];

    if(record_dict !=nil && [record_dict count]>0)
    {
        [self.dataBaseInterface insertRecordIdsIntosyncRecordHeap:record_dict];
    }
    [record_dict release];

    return callBack;
}
- (id) getRequiredData:(NSString *)key
{
    return [partialExecutedObjects objectForKey:key];
}
-(void)dealloc
{
    [partialExecutedObjects release];
    partialExecutedObjects=nil;
    [super dealloc];

}

@end
