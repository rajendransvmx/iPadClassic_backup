//
//  DocumentDAO.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 27/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@protocol DocumentDAO <CommonServiceDAO>

- (NSArray*)getListOfDocument;
- (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames
                       andCriteria:(DBCriteria *)criteria
                  withDistinctFlag:(BOOL)isDistinct;


-(void)updateDocumentTableWithModelArray:(NSArray*)modelArray;
- (NSArray*)getListOfDocumentToDownload;
-(NSString *)insertIntoDocumentsTableWithTheProductDetails:(NSArray *)productDetails;
-(NSString *)getTheProductIdDetailsFromTheDocumentTableWithTheProductId:(NSString *)productId;
- (NSArray *)getDocumentDetails:(NSString *)docId;
@end
