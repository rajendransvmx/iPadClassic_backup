//
//  TroubleShootDatahelper.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TroubleshootingDataHelper.h"
#import "DBCriteria.h"
#import "DatabaseConstant.h"
#import "DocumentDAO.h"
#import "FactoryDAO.h"

@implementation TroubleshootingDataHelper


+ (NSArray *)fetchProductDetailsbyProductName:(NSString *)productName
{
    NSArray *fields = [[NSArray alloc] initWithObjects:KDocId,KDocName,KDocKeyWords, nil];
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:KDocKeyWords operatorType:SQLOperatorLike andFieldValue:productName];
    id <DocumentDAO>  settingsService = [FactoryDAO serviceByServiceType:ServiceTypeDocument];
    NSArray *resultArray = [settingsService fetchRecordsByFields:fields andCriteria:criteria withDistinctFlag:NO];
    return resultArray;
    
}



@end
