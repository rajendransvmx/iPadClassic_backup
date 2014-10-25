 //
//  TroubleShootingParser.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 11/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TroubleshootingParser.h"
#import "DatabaseConstant.h"
#import "DocumentModel.h"
#import "DocumentDAO.h"
#import "FactoryDAO.h"
#import "DBRequestSelect.h"
#import "DBCriteria.h"
#import "DocumentService.h"

@implementation TroubleshootingParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData
{
    @synchronized([self class])
    {
        ResponseCallback * callBackObj = [[ResponseCallback alloc] init];
        @autoreleasepool
        {
            NSDictionary *responseDict = (NSDictionary *)responseData;
            NSArray *array = [responseDict objectForKey:@"records"];
            
            NSMutableArray *resulrArray = [NSMutableArray new];
            
            for (NSDictionary *dataDict in array)
            {
                DocumentModel *model = [[DocumentModel alloc] init];
                
                model.Id = [dataDict objectForKey:@"Id"];
                model.keywords = [dataDict objectForKey:@"Keywords"];
                model.name = [dataDict objectForKey:@"Name"];
                model.type = [dataDict objectForKey:@"Type"];
                
                [resulrArray addObject:model];
            }
            [self updateOrInsertDetailsIntoDocumentsTableWithTheDetails:resulrArray];
        }
        return callBackObj;
    }
}
-(void)updateOrInsertDetailsIntoDocumentsTableWithTheDetails:(NSMutableArray *)detailsArray
{
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeDocument];
    
    if ([daoService conformsToProtocol:@protocol(DocumentDAO)])
    {
        for (DocumentModel *model in detailsArray)
        {
            id  settingsService = [FactoryDAO serviceByServiceType:ServiceTypeDocument];
            if ([settingsService conformsToProtocol:@protocol(DocumentDAO)])
            {
                NSString *resultString = [settingsService getTheProductIdDetailsFromTheDocumentTableWithTheProductId :model.Id];
                if([resultString isEqualToString:model.Id])
                {
                    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:KDocId operatorType:SQLOperatorEqual andFieldValue:model.Id];
                    [daoService updateRecords:@[model] withFields:@[KDocId,KDocKeyWords,KDocName, @"type"] withCriteria:@[criteria]];
                }
                else
                {
                    BOOL resultStatus = [daoService saveRecordModel:model];
                    if(resultStatus)
                    {
                    NSLog(@" value inserted sucessFully");
                    }
                    else
                    {
                        NSLog(@" value inserted failure");
                    }
                }
            }
        }
    }
}


@end
