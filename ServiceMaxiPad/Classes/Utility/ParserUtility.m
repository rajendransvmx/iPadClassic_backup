//
//  ParserUtility.m
//
//
//  Created by Himanshi Sharma on 12/08/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "ParserUtility.h"
#import "ModifiedRecordModel.h"

@implementation ParserUtility


+(id) parseJSON:(NSDictionary *)jsonDict toModelObject:(id)modelObject withMappingDict:(NSDictionary *)mappingDict
{
    NSArray *propArray1 =  [self getPropertiesOfClass: modelObject];
    
    //Step1 : get the common items from JSon Dict and Model Object properties
    NSMutableSet *mutableSet1 = [NSMutableSet setWithArray:propArray1];
    NSMutableSet *mutableSet2 = [NSMutableSet setWithArray:[jsonDict allKeys]];
    
    [mutableSet2 intersectSet:mutableSet1];
    NSArray *commonArray  = [mutableSet2 allObjects];
    //NSLog(@"Common Array is %@",commonArray);
    
    NSDictionary *commonDict  = [jsonDict dictionaryWithValuesForKeys:commonArray];
    //NSLog(@"common items Dict is %@",commonDict);
    
    //Step 2 : Change the key name based on what is required from Model Object i.e. i want to map value of "id" from JSON to "employeeId" in model
  
    //Add the Key value of id in Common Dict
    NSMutableDictionary *commonMutDict = [commonDict mutableCopy];
    
    // propertyName => JsonKey
    // key - value
    if ([[mappingDict allKeys]count ] > 0)
    {
        // Iterate through mapping dictionary
        for (NSString *key in [mappingDict allKeys])
        {
            id value = [mappingDict valueForKey:key];
            
            if ([value isKindOfClass:[NSNull class]]) {
                value = nil;
            }
            
            [commonMutDict setValue:[jsonDict valueForKey:value] forKey:key];
        }
    }
    
    //Step 3]
    
    //Niraj conflict problem
    //Here modelObject is <ModifiedRecordModel: 0x190cbbb0>
    if ([modelObject isKindOfClass:[ModifiedRecordModel class]]){
        [modelObject addValuefromDictionary:commonMutDict];
    }else{
        [modelObject setValuesForKeysWithDictionary:commonMutDict];
    }
    //NSLog(@"Final Model Object is %@",modelObject);
    return modelObject;
    
}


+(NSArray*)getPropertiesOfClass:(id)objectClass
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([objectClass class], &outCount);
    NSMutableArray *gather = [NSMutableArray arrayWithCapacity:outCount];
    for(i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString* propName = [NSString stringWithUTF8String:property_getName(property)];
        //const char *type = property_getAttributes(property);
        
        //NSString *typeString = [NSString stringWithUTF8String:type];
        //NSArray *attributes = [typeString componentsSeparatedByString:@","];
        //NSString *typeAttribute = [attributes objectAtIndex:0];
        
        /* will use later
        if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 3)
        {
            NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
            Class typeClass = NSClassFromString(typeClassName);
            if(!self.propertyClasses)
                self.propertyClasses = [[NSMutableDictionary alloc] init];
            [self.propertyClasses setObject:typeClass forKey:propName];
        }
         */
        [gather addObject:propName];
    }
    free(properties);
    if([objectClass superclass] && [objectClass superclass] != [NSObject class])
        [gather addObjectsFromArray:[self getPropertiesOfClass:[objectClass superclass]]];
    return gather;
}

/* Method needs to implement from each Model Objects if there is any different mapping required from JSON to Model
 -(NSMutableDictionary *)getMappingDict
 {
 //Setting Mapping with  propertyName => JsonKey
 mappingDict = [[NSMutableDictionary alloc]initWithCapacity:0];
 //[self setMappingValue:@"id" forKey:@"employeeId"];
 [mappingDict  setValue:@"id" forKey:@"employeeId"];
 
 return mappingDict;
 }
*/

@end
