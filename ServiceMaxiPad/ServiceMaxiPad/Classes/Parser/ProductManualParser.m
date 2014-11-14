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
                    // model.type = [dataDict objectForKey:@"Type"];
                    
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
                NSString *resultString = [settingsService getTheProductIdDetailsFromTheDocumentTableWithTheProductId :model.prod_manual_Id];
                if([resultString isEqualToString:model.ProductId])
                {
                    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"ProductId" operatorType:SQLOperatorEqual andFieldValue:model.ProductId];
                    [settingsService updateRecords:@[model] withFields:@[@"prod_manual_Id",@"prod_manual_name",@"ProductId" ] withCriteria:@[criteria]];
                }
                else
                {
                    BOOL resultStatus = [settingsService saveRecordModel:model];
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
