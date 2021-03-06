 //
//  TroubleShootingParser.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 11/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TroubleshootingParser.h"
#import "DatabaseConstant.h"
#import "TroubleshootDataModel.h"
#import "TroubleshootingDAO.h"
#import "FactoryDAO.h"
#import "DBRequestSelect.h"
#import "DBCriteria.h"
#import "DocumentService.h"

@implementation TroubleshootingParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData
{
    if (![responseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
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
                TroubleshootDataModel *model = [[TroubleshootDataModel alloc] init];
                
                model.Id = [dataDict objectForKey:KDocId];
                model.Keywords = [dataDict objectForKey:KDocKeyWords];
                model.Name = [dataDict objectForKey:KDocName];
                model.Type = [dataDict objectForKey:@"Type"];
                
                [resulrArray addObject:model];
            }
            [self updateOrInsertTroubleshootDetails:resulrArray];
        }
        return callBackObj;
    }
}
- (void)updateOrInsertTroubleshootDetails:(NSMutableArray *)detailsArray
{
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeTroubleshooting];
    
    if ([daoService conformsToProtocol:@protocol(TroubleshootingDAO)])
    {
        for (TroubleshootDataModel *model in detailsArray)
        {
                NSString *resultString = [daoService getTheProductIdDetailsFromTheDocumentTableWithTheProductId :model.Id];
                if([resultString isEqualToString:model.Id])
                {
                    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:KDocId operatorType:SQLOperatorEqual andFieldValue:model.Id];
                    [daoService updateRecords:@[model] withFields:@[KDocId,KDocKeyWords,KDocName, @"Type"] withCriteria:@[criteria]];
                }
                else
                {
                   BOOL resultStatus = [daoService saveRecordModel:model];
                    if(resultStatus)
                    {
                       // SXLogDebug(@"value inserted sucessFully");
                    }
                    else
                    {
                       //SXLogDebug(@"value inserted failed");
                    }
                }
            
        }
    }
}


@end
