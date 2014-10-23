//
//  TroubleShootDatahelper.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TroubleshootingDatahelper.h"
#import "DBCriteria.h"
#import "DatabaseConstant.h"
#import "DocumentDAO.h"
#import "FactoryDAO.h"

@implementation TroubleshootingDatahelper


+ (NSArray *)getProductDetailsFromDbForProductName:(NSString *)productname
{
    NSArray *fieldsArray = [[NSArray alloc]initWithObjects:KDocId,KDocName,KDocKeyWords, nil];
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:KDocKeyWords operatorType:SQLOperatorLike andFieldValue:productname];
    id <DocumentDAO>  settingsService = [FactoryDAO serviceByServiceType:ServiceTypeDocument];
    NSArray *resultArray = [settingsService fetchRecordsByFields:fieldsArray andCriteria:criteria withDistinctFlag:NO];
    return resultArray;
}



@end
