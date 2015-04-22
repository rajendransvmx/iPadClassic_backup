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
#import "FactoryDAO.h"
#import "TroubleshootingDAO.h"
#import "TroubleshootDataModel.h"
#import "FileManager.h"

@implementation TroubleshootingDataHelper

+ (NSArray *)fetchProductDetailsbyProductName:(NSString *)productName
{
    NSArray *fields = [[NSArray alloc] initWithObjects:KDocId,KDocName,KDocKeyWords,@"Type", nil];
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:KDocKeyWords operatorType:SQLOperatorLike andFieldValue:productName];
    id <TroubleshootingDAO>  settingsService = [FactoryDAO serviceByServiceType:ServiceTypeTroubleshooting];
    NSArray *resultArray = [settingsService fetchRecordsByFields:fields andCriteria:criteria withDistinctFlag:NO];
    return resultArray;
}

+ (NSArray *)fetchProductDetailsByProductIds:(NSArray *)sFIds
{
    id <TroubleshootingDAO>  settingsService = [FactoryDAO serviceByServiceType:ServiceTypeTroubleshooting];
    NSArray *resultArray = [settingsService getProductNamesForTheIds:sFIds withDistinctFlag:NO];
    return resultArray;
}

+ (void)deleteTroubleShootFilesForTheIds:(NSArray *)sFIdArray
{
    NSArray *productDetailsArray  =  [[self class] fetchProductDetailsByProductIds:sFIdArray];
    
    NSString *troubleShootPath = [FileManager getTroubleshootingSubDirectoryPath];
    
    for(TroubleshootDataModel *model in productDetailsArray)
    {
        NSString *path = [troubleShootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",model.Id,model.Type]];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
        NSError *error = nil;
        
        if(fileExists)
        {
            [[NSFileManager defaultManager] removeItemAtPath: path error: &error];
        }
        
        NSString *folderPath = [troubleShootPath stringByAppendingPathComponent:model.Id];
        BOOL folderExists = [[NSFileManager defaultManager] fileExistsAtPath:folderPath];
        if(folderExists)
        {
            [[NSFileManager defaultManager] removeItemAtPath:folderPath error: &error];
        }
    }
}







@end
