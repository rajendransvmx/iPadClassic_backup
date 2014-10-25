//
//  SFMSearchFieldService.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMSearchFieldService.h"
#import "SFMSearchObjectModel.h"
#import "SFMSearchFieldModel.h"
#import "DatabaseConstant.h"

@implementation SFMSearchFieldService

- (NSString *)tableName {

    return kSFMSearchFieldTableName;

}


- (NSArray *)getAllFieldsForSearchObject:(SFMSearchObjectModel *)searchObject
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"expressionRule" operatorType:SQLOperatorEqual andFieldValue:searchObject.objectId];
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:@"identifier",@"fieldName",@"relatedObjectName",@"fieldType",@"displayType",@"objectID",@"expressionRule",@"objectName",@"lookupFieldAPIName",@"fieldRelationshipName",@"sortOrder", nil] whereCriteria:criteria];
    [requestSelect setDistinctRowsOnly];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            SFMSearchFieldModel * model = [[SFMSearchFieldModel alloc] init];
            [resultSet kvcMagic:model];
            model.displayType = [model.displayType lowercaseString];
            if([self doesObjectHavePermission:model.objectName])
                [records addObject:model];
        }
    }
    return records;
}

@end
