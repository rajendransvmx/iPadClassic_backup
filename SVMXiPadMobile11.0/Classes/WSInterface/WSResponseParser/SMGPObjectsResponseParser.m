//
//  SMGPObjectsResponseParser.m
//  iService
//
//  Created by Siva Manne on 02/01/13.
//
//

#import "SMGPObjectsResponseParser.h"
#import "INTF_WebServicesDefServiceSvc.h"
#import "DataBase.h"

@implementation SMGPObjectsResponseParser
@synthesize objectsWithPermission;
- (BOOL) parseResponse:(NSArray *)result
{
    if(!objectsWithPermission)
        objectsWithPermission = [[NSMutableArray alloc] init];
        
    for(int i=0; i<[result count]; i++)
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapObject = [result objectAtIndex:i];
        NSString *key = svmxMapObject.key;
        if(![key isEqualToString:@"Required_Objects"])
        {
            NSAutoreleasePool *iPool = [[NSAutoreleasePool alloc] init];
            NSString *objectName = svmxMapObject.value;
            [objectsWithPermission addObject:objectName];
            NSString *objName = [NSString stringWithFormat:@"'%@'",objectName];
            NSArray *valueMapArray = [svmxMapObject valueMap];
            for(int j=0; j<[valueMapArray count]; j++)
            {
                NSAutoreleasePool *jPool = [[NSAutoreleasePool alloc] init];
                INTF_WebServicesDefServiceSvc_SVMXMap * objectProperty = [valueMapArray objectAtIndex:j];
                if([objectProperty.key isEqualToString:MOBJECTPROPERTY])
                {
                    NSArray *objectPropertyArray = [objectProperty valueMap];
                    for(int k=0; k<[objectPropertyArray count]; k++)
                    {
                        NSAutoreleasePool *kPool = [[NSAutoreleasePool alloc] init];
                        INTF_WebServicesDefServiceSvc_SVMXMap * objectPropertyObj = [objectPropertyArray objectAtIndex:k];
                        NSString *key = objectPropertyObj.key;
                        if([key isEqualToString:MOBJECTDEFINITION])
                        {
                            NSArray *objDefValueMapArray = [objectPropertyObj valueMap];
                            NSMutableArray *objDefArray = [[NSMutableArray alloc] initWithCapacity:0];
                            NSMutableDictionary *objDefDict = [[NSMutableDictionary alloc] init];
                            for(int l=0; l<[objDefValueMapArray count]; l++)
                            {
                                NSAutoreleasePool *lPool = [[NSAutoreleasePool alloc] init];
                                INTF_WebServicesDefServiceSvc_SVMXMap * objDefObj = [objDefValueMapArray objectAtIndex:l];
                                NSString *key = objDefObj.key;
                                NSString *value = [NSString stringWithFormat:@"'%@'",objDefObj.value];
                                if([key isEqualToString:_MKEYPREFIX])
                                {
                                    [objDefDict setObject:value forKey:MKEY_PREFIX];
                                }
                                else
                                if([key isEqualToString:_MPLURALLABEL] )
                                {
                                    [objDefDict setObject:value forKey:MLABEL_PURAL];
                                }
                                else
                                    if([key isEqualToString:_LABEL] )
                                    {
                                        [objDefDict setObject:value forKey:MLABEL];
                                    }
                                else
                                if([key isEqualToString:MASTERDETAILS] )
                                {
                                    NSArray *masterDetailsValueMapArray = [objDefObj valueMap];
                                    for(int m=0; m<[masterDetailsValueMapArray count]; m++)
                                    {
                                        NSAutoreleasePool *mPool = [[NSAutoreleasePool alloc] init];
                                        INTF_WebServicesDefServiceSvc_SVMXMap * masterDetailObj = [masterDetailsValueMapArray objectAtIndex:m];
                                        
                                        NSString *objectAPINameForChild = [NSString stringWithFormat:@"'%@'",masterDetailObj.key];
                                        NSString *fieldAPIValue = [NSString stringWithFormat:@"'%@'",masterDetailObj.value];
                                        NSMutableArray *masterDetailsArray = [[NSMutableArray alloc] initWithCapacity:0];
                                        NSMutableDictionary *masterDetailsDict = [[NSMutableDictionary alloc] init];
                                        [masterDetailsDict setObject:objectAPINameForChild forKey:@"object_api_name_child"];
                                        [masterDetailsDict setObject:fieldAPIValue forKey:@"field_api_name"];
                                        [masterDetailsDict setObject:objName forKey:@"object_api_name_parent"];
                                        [masterDetailsArray addObject:masterDetailsDict];
                                        [masterDetailsDict release];
                                        [self insertRecords:masterDetailsArray intoTable:SFCHILDRELATIONSHIP];
                                        [masterDetailsArray release];
                                        [mPool drain];
                                    }
                                }
                                [lPool drain];
                            }
                            [objDefDict setObject:objName forKey:MFIELD_API_NAME];
                            [objDefArray addObject:objDefDict];
                            [objDefDict release];
                            if([objDefArray count])
                            {
                                [self insertRecords:objDefArray intoTable:SFOBJECT];
                                [self createTable:objectName];
                            }
                            [objDefArray release];
                        }
                        else
                        if([key isEqualToString:MRECORDTYPE])
                        {
                            NSArray *recordTypeValueMapArray = [objectPropertyObj valueMap];
                            NSMutableArray *recordTypeArray = [[NSMutableArray alloc] init];
                            for(int m=0; m<[recordTypeValueMapArray count]; m++)
                            {
                                NSAutoreleasePool *mPool = [[NSAutoreleasePool alloc] init];
                                NSMutableDictionary *recordDict = [[NSMutableDictionary alloc] init];
                                INTF_WebServicesDefServiceSvc_SVMXMap * recordTypeObj = [recordTypeValueMapArray objectAtIndex:m];
                                NSString *recordTypeId = [NSString stringWithFormat:@"'%@'",recordTypeObj.key];
                                NSString *recordTypeValue = [NSString stringWithFormat:@"'%@'",recordTypeObj.value];
                                //update SFRecord Table with this info
                                [recordDict setObject:recordTypeId forKey:MRECORD_TYPE_ID];
                                [recordDict setObject:recordTypeValue forKey:MRECORDTYPE_LABEL];
                                [recordDict setObject:objName forKey:MOBJECT_API_NAME];
                                [recordTypeArray addObject:recordDict];
                                [recordDict release];
                                [mPool drain];
                            }
                            if([recordTypeArray count])
                            {
                                [self insertRecords:recordTypeArray intoTable:SFRECORDTYPE];
                            }
                            [recordTypeArray release];
                        }
                        [kPool drain];
                    }
                }
                else
                if([objectProperty.key isEqualToString:MFIELDPROPERTY])
                {
                    NSArray *fieldPropertyArray = [objectProperty valueMap];
                    for(int k=0; k<[fieldPropertyArray count]; k++)
                    {
                        NSAutoreleasePool *kPool = [[NSAutoreleasePool alloc] init];
                        INTF_WebServicesDefServiceSvc_SVMXMap * fieldPropertyObj = [fieldPropertyArray objectAtIndex:k];
                        NSString *fieldApiName = fieldPropertyObj.value;
                        NSString *key = fieldPropertyObj.key;
                        NSMutableArray *fieldArray = [[NSMutableArray alloc] init];
                        if([key isEqualToString:FIELD])
                        {
                            NSArray *fieldPropertyObjArray = [fieldPropertyObj valueMap];
                            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                            NSString *fieldName = [NSString stringWithFormat:@"'%@'",fieldApiName];
                            [dict setObject:objName forKey:MOBJECT_API_NAME];
                            [dict setObject:fieldName forKey:MFIELD_API_NAME];
                            for(int l=0; l<[fieldPropertyObjArray count]; l++)
                            {
                                NSAutoreleasePool *lPool = [[NSAutoreleasePool alloc] init];
                                INTF_WebServicesDefServiceSvc_SVMXMap * fieldObj = [fieldPropertyObjArray objectAtIndex:l];
                                NSString *objKey = fieldObj.key;
                                NSString *fieldValue = fieldObj.value;
                                NSString *value = [NSString stringWithFormat:@"'%@'",fieldValue];
                                if([objKey isEqualToString:_LABEL])
                                {
                                    [dict setObject:value forKey:MLABEL];
                                }
                                else
                                if([objKey isEqualToString:_TYPE])
                                {
                                    //get the proper type from db
                                    NSString *dataType = [NSString stringWithFormat:@"'%@'",[fieldValue lowercaseString]];
                                    [dict setObject:dataType forKey:MTYPEM];
                                }
                                else
                                if([objKey isEqualToString:_LENGTH])
                                {
                                   [dict setObject:value forKey:MLENGTH];
                                }
                                else
                                if([objKey isEqualToString:_NAMEFIELD])
                                {
                                   [dict setObject:value forKey:MNAME_FIELD];
                                }
                                else
                                if([objKey isEqualToString:_REFERENCETO])
                                {
                                    [dict setObject:value forKey:MREFERENCE_TO];
                                }
                                else
                                if([objKey isEqualToString:_RELATIONSHIPNAME])
                                {
                                    [dict setObject:value forKey:MRELATIONSHIP_NAME];
                                }
                                [lPool drain];
                            }
                            [fieldArray addObject:dict];
                            [dict release];
                        }
                        if([fieldArray count])
                        {
                            [self insertRecords:fieldArray intoTable:SFOBJECTFIELD];
                        }
                        for(int m=0; m< [fieldArray count]; m++)
                        {
                            NSAutoreleasePool *mPool = [[NSAutoreleasePool alloc] init];
                            NSDictionary *dict = [fieldArray objectAtIndex:m];
                            NSString *objectApiName = [dict objectForKey:MOBJECT_API_NAME];
                            NSString *fieldName = [dict objectForKey:MFIELD_API_NAME];
                            NSString *fieldType = [dict objectForKey:MTYPEM];
                            [self.dataBase insertColoumn:fieldName withType:fieldType inTable:objectApiName];
                            NSString *referenceTo = [dict objectForKey:MREFERENCE_TO];
                            if(referenceTo)
                            {
                                NSString *fieldApiName = [dict objectForKey:MFIELD_API_NAME];
                                NSMutableDictionary *referenceDict = [[NSMutableDictionary alloc] init];
                                [referenceDict setObject:objectApiName forKey:MOBJECT_API_NAME];
                                [referenceDict setObject:fieldApiName forKey:_MFIELD_API_NAME];
                                [referenceDict setObject:referenceTo forKey:MREFERENCE_TO];
                                NSArray *data = [NSArray arrayWithObjects:referenceDict, nil];
                                [referenceDict release];
                               [self insertRecords:data intoTable:SFREFERENCETO];
                            }
                            [mPool drain];
                        }
                        [kPool drain];
                    }
                }
                [jPool drain];
            }
            [iPool drain];
        }
        else
        {
            for(NSString *object in svmxMapObject.values)
            {
                [objectsWithPermission removeObject:object];
            }
        }
    }
    return FALSE;
}

- (id) getRequiredData:(NSString *)key
{
    if([key isEqualToString:@"objectsWithoutPermission"])
        return objectsWithPermission;
    return nil;
}
- (void)dealloc
{
    [super dealloc];
    [objectsWithPermission release];
}
@end
