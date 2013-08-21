//
//  plistUtility.m
//  iService
//
//  Created by Sahana BM on 16/07/13.
//
//

#import "plistUtility.h"

@implementation plistUtility


+(void)writeIntoPlist:(NSString *)plistName data:(NSMutableDictionary *)dict
{
    NSString * filepath = [plistUtility getFilePath:plistName];
    [dict writeToFile:filepath atomically:YES];
}
//  Unused Methods
//+(void)deletePlist:(NSString *)plistName
//{
//    NSString * filePath = [plistUtility getFilePath:plistName];
//    NSFileManager * fileManager = [NSFileManager defaultManager];
//    NSError * error = nil;
//    [fileManager removeItemAtPath:filePath error:&error];
//}
+(void)clearPlist:(NSString *)clearPlist
{
    if([plistUtility DoesFileExist:clearPlist])
    {
        NSMutableDictionary * dict = [plistUtility readFromPlist:clearPlist];
        [dict removeAllObjects];
        [plistUtility writeIntoPlist:clearPlist data:dict];
    }
}
+(NSMutableDictionary *)readFromPlist:(NSString *)plistName
{
    //create SYNC_HISTORY PLIST
    NSString * FilePath = [plistUtility getFilePath:plistName];
    NSMutableDictionary * dict = [[[NSMutableDictionary alloc] initWithContentsOfFile:FilePath] autorelease];
    return dict;
}
+(NSString *)getFilePath:(NSString *)fileName;
{
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:fileName];
    return plistPath_SYNHIST;
}
+(BOOL)DoesFileExist:(NSString *)fileName
{
    NSString * filePath = [plistUtility getFilePath:fileName];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
