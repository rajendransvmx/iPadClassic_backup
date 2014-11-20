//
//  SFMSearchDataHandler.h
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 7/2/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMSearchObjectModel.h"

@interface SFMSearchDataHandler : NSObject


- (NSMutableArray *)searchResultsForSearchObject:(SFMSearchObjectModel *)newSearchObject
                                withSearchString:(NSString *)newSearchStr;
- (NSMutableDictionary *)searchResultsForSearchObjects:(NSArray *)searchObjects
                                      withSearchString:(NSString *)newSearchStr;

- (NSMutableDictionary*)getSfidVsLocalIdDictionaryForSFids:(NSArray*)listOfSfid andObjectName:(NSString*)objectName;

@end
