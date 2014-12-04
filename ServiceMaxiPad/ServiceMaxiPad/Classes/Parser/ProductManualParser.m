//
//  ProductManualParser.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ProductManualParser.h"
#import "DatabaseConstant.h"
#import "DocumentModel.h"
#import "ProductManualDAO.h"
#import "ProductManualModel.h"
#import "FactoryDAO.h"
#import "DBRequestSelect.h"
#import "DBCriteria.h"
#import "DocumentService.h"
#import "CacheManager.h"

@implementation ProductManualParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                      responseData:(id)responseData
{
    @synchronized([self class])
    {
        ResponseCallback * callBackObj = [[ResponseCallback alloc] init];
        @autoreleasepool
        {
            {NSDictionary *responseDict = (NSDictionary *)responseData;
                NSArray *array = [responseDict objectForKey:@"records"];
                
                NSMutableArray *resulrArray = [NSMutableArray new];
                
                for (NSDictionary *dataDict in array)
                {
                    ProductManualModel *model = [[ProductManualModel alloc] init];
                    model.prod_manual_Id = [dataDict objectForKey:@"Id"];
                    model.prod_manual_name = [dataDict objectForKey:@"Name"];
                    NSString *productId = [[CacheManager sharedInstance] getCachedObjectByKey:@"pMId"];
                    model.ProductId  = productId;
                    [resulrArray addObject:model];
                }
                [self updateOrInsertDetailsIntoDocumentsTableWithTheDetails:resulrArray];
            }
        }
         return callBackObj;
    }
}

- (void)updateOrInsertDetailsIntoDocumentsTableWithTheDetails:(NSMutableArray *)detailsArray
{
    id settingsService = [FactoryDAO serviceByServiceType:ServiceTypeProductManual];
    
    if ([settingsService conformsToProtocol:@protocol(ProductManualDAO)])
    {
        for (ProductManualModel *model in detailsArray)
        { 
            if ([settingsService conformsToProtocol:@protocol(ProductManualDAO)])
            {
                NSArray *array = [settingsService getTheProductIdDetailsForTheProductId:model.prod_manual_Id];
                if([ array count] > 0)
                {
                    ProductManualModel *model1 = [array objectAtIndex:0];
                    NSString *resultString = model1.prod_manual_Id;
                    if([resultString isEqualToString:model.prod_manual_Id])
                    {
                        DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"prod_manual_Id" operatorType:SQLOperatorEqual andFieldValue:model.prod_manual_Id];
                        [settingsService updateRecords:@[model] withFields:@[@"prod_manual_Id",@"prod_manual_name",@"ProductId" ] withCriteria:@[criteria]];
                    }
                }
                else
                {
                    BOOL resultStatus = [settingsService saveRecordModel:model];
                    if(resultStatus)
                    {
                        //SXLogDebug(@" value inserted sucessFully");
                    }
                    else
                    {
                        //SXLogWarning(@" value inserted failure");
                    }
                }
            }
        }
    }
}




@end
