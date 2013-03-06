//
//  Utility.h
//  iService
//
//  Created by Shravya shridhar on 2/20/13.
//
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (BOOL)isStringEmpty:(NSString *)newString;
+ (NSDate *)getDateFromString:(NSString *)someDateString;
+ (NSDate *)todayDateInGMT;
+ (BOOL)checkIfDate:(NSDate *)todayDate betweenDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;
+ (NSDictionary *)getTheParameterFromUrlParameterString:(NSString*)urlParam;
+ (NSString *)replaceSpaceinDateByT:(NSString *)stringToBeChanged;
+ (NSString *)replaceTinDateBySpace:(NSString *)stringToBeChanged;
+ (BOOL)containsString:(NSString *)someString inString:(NSString *)parentString ;

@end
