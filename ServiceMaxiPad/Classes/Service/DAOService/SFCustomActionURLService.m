//
//  SFCustomActionURLService.m
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFCustomActionURLService.h"
#import "CustomActionURLModel.h"
#import "SFExpressionParser.h"

@implementation SFCustomActionURLService

- (NSString *)tableName
{
    return @"CustomActionParams";
}

- (NSArray *)fieldNamesToBeRemovedFromQuery
{
    return @[@"isEntryCriteriaMatching"];
}
- (void)getCustomActionURL:(NSMutableArray *)CustomActionURLArray{
    //NSMutableArray *wizardComponentsArray = [[NSMutableArray alloc]init];
    
    for (CustomActionURLModel *wizard in CustomActionURLArray) {
        
        DBCriteria * criteriaOne = [[DBCriteria alloc] initWithFieldName:@"Id"
                                                            operatorType:SQLOperatorEqual
                                                           andFieldValue:wizard.Id];
        NSArray * fieldNames = [[NSArray alloc] initWithObjects:@"Id",@"expressionId",@"DispatchProcessId",@"ParameterName",@"ParameterType",@"Name",nil];
        
        
    }
    /// return wizardComponentsArray;
}
-(void)updateWizardComponentWithModelArray:(NSArray*)modelArray
{
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"wizardComponentId"];
    
    if([modelArray count] >0)
    {
        [self updateRecords:modelArray withFields:@[@"className",@"methodName"] withCriteria:@[criteria1]];
    }
}
@end
