//
//  ProductManualDataHelper.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ProductManualDataHelper.h"
#import "DBCriteria.h"
#import "FactoryDAO.h"
#import "ProductManualDAO.h"



@implementation ProductManualDataHelper

+ (NSArray *)fetchProductDetailsbyProductID:(NSString *)productId
{
    NSArray *fields = [[NSArray alloc] initWithObjects:@"prod_manual_Id",@"prod_manual_name",@"ProductId", nil];
   
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"ProductId" operatorType:SQLOperatorLike andFieldValue:productId];
    id <ProductManualDAO>  settingsService = [FactoryDAO serviceByServiceType:ServiceTypeProductManual];
    
    NSArray *resultArray = [settingsService fetchRecordsByFields:fields andCriteria:criteria withDistinctFlag:NO];
    return resultArray;
}


@end
