//
//  ChatterHelper.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductImageDataDAO.h"

@class UserImageModel;

@interface ChatterHelper : NSObject

+ (NSString *)requestQueryForProductIamge;
+ (NSString *)requestQueryForChatterPost;
+ (NSString *)requestQueryForChatterPostDetails;
+ (NSString *)getAttachmentIdForProduct:(NSString *)productId;

+ (id)getdatFromChache:(NSString *)key;

+ (void)clearCacheByKey:(NSString *)key;
+ (void)pushDataToCahcche:(id)value forKey:(NSString *)key;
+ (void)removeAllUserImagesFromDocuments:(NSString *)productId;
+ (void)saveProductAttachmentId:(ProductImageDataModel *)model;

+ (NSDictionary *)getRequstParamFor:(NSString *)key;

+ (BOOL)deleteRecordsForProductId:(NSString *)productId;
+ (BOOL)saveRecods:(NSMutableArray *)records;
+ (BOOL)deleteRecordFromProductImage:(NSString *)productId;

+ (NSMutableArray *)fetchChatterFeedsForProductId:(NSString *)productId;

+ (void)updateUserImage:(UserImageModel *)userImage;

+ (NSData *)getImageDataForUserId:(NSString *)Id;

+ (void)updateUserImageToRefresh:(NSString *)productId;

+ (BOOL)shouldRefreshImage:(NSString *)userId;
@end
