//
//  RecentsPlistUtility.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "RecentsPlistUtility.h"
#import "FileManager.h"
#import "PlistManager.h"

@implementation RecentsPlistUtility

#define OBJECT_HISTORY_PLIST @"ObjectHistory.plist"

- (void)writeIntoRecentPList:(NSString*)objectName andRecordId:(NSString*)recordId
{
    NSMutableDictionary *recentsDictionary = [RecentsPlistUtility getRecentsFromPlist];
    
    NSDictionary *recordIdWithDateDict = [[NSDictionary alloc]initWithObjectsAndKeys:@[recordId],@[[NSDate date]], nil];
    
    NSMutableArray *listOfObject;
    
    if ([recentsDictionary objectForKey:objectName] != nil) {
        //if the objectname present modify inner dictionary
        listOfObject = [recentsDictionary objectForKey:objectName];
    } else {
        //if object name does not exist create new dict
        listOfObject = [[NSMutableArray alloc]init];
    }
    [listOfObject addObject:recordIdWithDateDict];
    [recentsDictionary setObject:listOfObject forKey:objectName];
    [PlistManager writeIntoPlist:OBJECT_HISTORY_PLIST data:recentsDictionary];
}

+ (NSMutableDictionary*)getRecentsFromPlist
{
    NSMutableDictionary *recentDict = [NSMutableDictionary dictionaryWithContentsOfFile:[FileManager getFilePathForPlist:OBJECT_HISTORY_PLIST]];
    return recentDict;
}

+ (void)clearPlist
{
    NSMutableDictionary *recentDict  = [RecentsPlistUtility getRecentsFromPlist];
    [recentDict removeAllObjects];
    [PlistManager writeIntoPlist:OBJECT_HISTORY_PLIST data:recentDict];
}


@end
