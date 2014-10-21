//
//  plistUtility.h
//  iService
//
//  Created by Sahana BM on 16/07/13.
//
//

#import <Foundation/Foundation.h>

@interface plistUtility : NSObject
+(void)writeIntoPlist:(NSString *)plistName data:(NSMutableDictionary *)dict;
+(NSMutableDictionary *)readFromPlist:(NSString *)plistName;
//+(void)deletePlist:(NSString*)plistName;//  Unused Methods
+(NSString *)getFilePath:(NSString *)fileName;
+(BOOL)DoesFileExist:(NSString *)fileName;
+(void)clearPlist:(NSString *)clearPlist;
@end
