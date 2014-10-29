//
//  SFMSearchFilterCriteriaService.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMSearchFilterCriteriaService.h"
#import "DatabaseConstant.h"
#import "SFMSearchFilterCriteriaModel.h"

@implementation SFMSearchFilterCriteriaService
- (NSString *)tableName {
    return kSFMSearchFilterCriteriaTableName;
}
- (NSArray *)fetchExpressionComponentForExpressionId:(NSString *)expressionId {
    
    NSMutableArray * searchProcessRecords = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    //TODO : ORDER BY sequence
    
    //SELECT field_name , operator, operand   FROM SFM_Search_Filter_Criteria where expression_rule = '%@' ORDER BY sequence
    
    DBCriteria *selCriteria = [[DBCriteria alloc] initWithFieldName:@"expressionRule"
                                                      operatorType:SQLOperatorEqual
                                                     andFieldValue:expressionId];
    
    DBRequestSelect *requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:@[@"fieldName",@"operatorValue",@"operand",@"displayType"] whereCriteria:selCriteria];
    
    [requestSelect addOrderByFields:@[@"sequence"]];
    
    [requestSelect setDistinctRowsOnly];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            SFMSearchFilterCriteriaModel * model = [[SFMSearchFilterCriteriaModel alloc] init];
            [resultSet kvcMagic:model];
            model.displayType = [model.displayType lowercaseString];
            [searchProcessRecords addObject:model];
        }
    }
    return searchProcessRecords;
}
@end
