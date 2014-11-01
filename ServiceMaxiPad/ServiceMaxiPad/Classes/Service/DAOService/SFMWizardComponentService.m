//
//  SFMWizardComponentService.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMWizardComponentService.h"
#import "WizardComponentModel.h"
#import "SFExpressionParser.h"
#import "WizardComponentModel.h"
#import "SFWizardModel.h"

@implementation SFMWizardComponentService

- (NSString *)tableName
{
    return @"SFWizardComponent";
}

- (NSArray *)fieldNamesToBeRemovedFromQuery
{
    return @[@"isEntryCriteriaMatching"];
}

- (NSArray * )fetchWizardComponentInfoByFields:(NSArray *)fieldNames
                                   andCriteria:(NSArray *)criteria
                                 andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
   
    [requestSelect setDistinctRowsOnly];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            WizardComponentModel * model = [[WizardComponentModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}

- (void)getWizardComponentsForWizards:(NSMutableArray *)wizardArray recordId:(NSString *)recordId
{
    //NSMutableArray *wizardComponentsArray = [[NSMutableArray alloc]init];
    
    for (SFWizardModel *wizard in wizardArray) {
        
        DBCriteria * criteriaOne = [[DBCriteria alloc] initWithFieldName:@"wizardId"
                                                            operatorType:SQLOperatorEqual
                                                           andFieldValue:wizard.wizardId];
        NSArray * fieldNames = [[NSArray alloc] initWithObjects:@"actionDescription",@"expressionId",@"processId",@"actionType",@"actionName",nil];
        
        NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaOne, nil];
        
        NSArray * wizardComponentArray = [self fetchWizardComponentInfoByFields:fieldNames andCriteria:criteriaObjects andExpression:nil];
        
        SFExpressionParser *parser = [[SFExpressionParser alloc] initWithExpressionId:nil objectName:nil];
        
        NSMutableArray *wizardComponentsWithEntryCriteria = [[NSMutableArray alloc]init];
        
        for (WizardComponentModel *wizardComponet in wizardComponentArray) {
            /*Check whether the wizard component matches the enrty criteria*/
            if ([wizardComponet.expressionId length] > 0)
            {
                parser.objectName = wizard.objectName;
                parser.expressionId = wizardComponet.expressionId;
                wizardComponet.isEntryCriteriaMatching = [parser isEntryCriteriaMatchingForRecordId:recordId];
            }
            else
            {
                wizardComponet.isEntryCriteriaMatching = TRUE;
            }
            
            [wizardComponentsWithEntryCriteria addObject:wizardComponet];
        }
        
        wizard.wizardComponents = wizardComponentsWithEntryCriteria;
    
        //[wizardComponentsArray addObject:wizardComponentsWithEntryCriteria];
    }
   /// return wizardComponentsArray;
}

@end
