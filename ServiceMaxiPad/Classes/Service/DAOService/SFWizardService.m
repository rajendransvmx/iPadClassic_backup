//
//  SFWizardService.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFWizardService.h"
#import "SFWizardModel.h"
#import "DBRequestInsert.h"
#import "ParserUtility.h"
#import "DatabaseManager.h"
#import "SFWizardModel.h"
#import "SFExpressionParser.h"

@implementation SFWizardService

- (NSString *)tableName
{
    return @"SFWizard";
}

- (NSArray *)fieldNamesToBeRemovedFromQuery
{
    return @[@"wizardComponents"];
}

- (NSArray * )fetchWizardInfoByFields:(NSArray *)fieldNames
                              andCriteria:(NSArray *)criteria
                            andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    [requestSelect addOrderByFields:@[@"wizardLayoutRow",@"wizardLayoutColumn"]];
    
    [requestSelect setDistinctRowsOnly];

    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            SFWizardModel * model = [[SFWizardModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}


- (NSMutableArray *)getWizardsForObjcetName:(NSString *)objectName andRecordId:(NSString *)recordId
{
    
    DBCriteria * objectNameCriteria = [[DBCriteria alloc] initWithFieldName:@"objectName"
                                                               operatorType:SQLOperatorEqual
                                                              andFieldValue:objectName];
    
    NSArray * fieldNames = [[NSArray alloc] initWithObjects:@"wizardId",@"expressionId",@"wizardName",@"objectName", nil];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:objectNameCriteria, nil];
    
    NSArray * wizardArray = [self fetchWizardInfoByFields:fieldNames
                                            andCriteria:criteriaObjects
                                          andExpression:nil];
    
    SFExpressionParser *parser = [[SFExpressionParser alloc]initWithExpressionId:nil objectName:objectName];
    
    //check if entry criteria matches
    
    NSMutableArray *wizardsWithEntryCriteriaMatched = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [wizardArray count]; i++) {
        
        SFWizardModel *wizard = [wizardArray objectAtIndex:i];
        if([wizard.expressionId length] > 0)
        {
            if([wizard.wizardName isEqualToString:@"Work Order Toolbox"])
            {
                NSLog(@"ItCame");
            }
            parser.expressionId = wizard.expressionId;
            BOOL isEntryCriteriaMatched = [parser isEntryCriteriaMatchingForRecordId:recordId];
            if (isEntryCriteriaMatched) {
                [wizardsWithEntryCriteriaMatched addObject:wizard];
            }
        }
        else{
            [wizardsWithEntryCriteriaMatched addObject:wizard];
        }
    }
    
    return wizardsWithEntryCriteriaMatched;
}

-(void)updateWizardWithModelArray:(NSArray*)modelArray
{
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"wizardLayoutColumn",@"wizardLayoutRow",nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"wizardId"];
    
    if([modelArray count] >0)
    {
        [self updateRecords:modelArray withFields:fieldsArray withCriteria:[NSArray arrayWithObjects:criteria1, nil]];
    }
}


@end
