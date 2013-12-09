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
+ (NSString *)currentDateInGMTForOPDoc;
+ (NSDate *)todayDateInGMT;
+ (BOOL)checkIfDate:(NSDate *)todayDate betweenDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;
+ (NSDictionary *)getTheParameterFromUrlParameterString:(NSString*)urlParam;
+ (NSString *)replaceSpaceinDateByT:(NSString *)stringToBeChanged;
+ (NSString *)replaceTinDateBySpace:(NSString *)stringToBeChanged;
+ (BOOL)containsString:(NSString *)someString inString:(NSString *)parentString ;
+ (BOOL)isItTrue:(NSString *)stringTrue;
+ (BOOL)isStringNotNULL:(NSString *)value;
+ (NSString *)getConcatenatedStringFromArray:(NSArray *)arayOfString withSingleQuotesAndBraces:(BOOL)isRequired;

+ (NSString *)getPriceDownloadStatus ;
+ (void )setPriceDownloadStatus:(NSString *)statusValue;
+ (void )removePriceDownloadStatus;
+ (void)showLog:(NSString *)loggedMessage;

//+ (NSDictionary *) getParameterDictionaryFromURL:(NSString *) urlParams;//  Unused Methods

+ (NSString *)getUserTrunkRequestStatus ;
+ (void )setUserTrunkRequestStatus:(NSString *)statusValue;
//+ (void )removeUserTrunkRequestStatus ;//  Unused Methods
+ (NSString *)today:(NSInteger)numberOfDays andJusDate:(BOOL)isDateOnly;
+ (NSArray *)splitString:(NSString *)stringToBeSplit byString:(NSString *)subString;

+ (void)setRefreshCalendarView;
+ (BOOL)getRefreshCalendarView ;
+ (void)clearRefreshCalendarView;
+ (BOOL)notIOS7;

/*ios7_support shravya*/
+ (UIImage *)getLeftNavigationBarImage;
+ (UIImage *)getRightNavigationBarImage;


@end
