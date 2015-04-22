//
//  Utility.h
//  iService
//
//  Created by Shravya shridhar on 2/20/13.
//
//

#import <Foundation/Foundation.h>

@class SBJsonParser;

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

//8915
//get the button size based on the font
+ (CGSize) getBoundSizeForString:(NSString *)text withFont:(UIFont *)someFont andheight:(CGFloat)maxHeight;

//8890
+ (void)setSequenceColoumntrue;
+ (BOOL)hasColumnSequence;

//Formatted File size - 9196
+ (NSString *)formattedFileSizeForAttachment:(long long int)size;
+ (NSString *)formattedFileSize:(long long int)size;

+(NSMutableArray *)getIdsFromJsonString:(NSString *)jsonstrings;
+ (id) getJsonArrayFromString:(NSString *)jsonRecord;

/*Radha - Data Purge*/
+ (NSDate *)getDatetimeFromString:(NSString *)someString;
+ (NSString *)getUserReableStringFromDate:(NSDate *)date;
- (NSDateComponents *) getDateComponents;
+ (NSString *)getStringFromDate:(NSDate *)someDate;
+ (NSString *)getValueForTagFromTagDict:(NSString *)key;
+ (NSString *)getValueForSettingIdFromDict:(NSString *)key;
+ (NSTimeInterval)getTimerIntervalForDataPurge;
+ (NSDate *)getDateTimeForNextDataPurge:(NSDate *)date;

//Data Purge - ProductManual File Path - 10181
+ (NSString*)pathForProductManual;

//10312 - Defect Fix
+ (BOOL)iSDeviceTime24HourFormat;
+ (NSDate *) getDateFromStringFromPlist:(NSString *)value userRedable:(BOOL)boolValue;
+ (BOOL) isString24HrFormat:(NSString *)value;
+ (NSString *) getStringFromDateForDeviceTime:(NSDate *)date;

//10346
+ (NSMutableString *) appendOrRemoveZeroToDecimalPoint:(NSMutableString *)value decimalPoint:(NSInteger)scale;
+ (NSMutableString *) appendZeroToDecimalPoint:(NSMutableString *)value decimalPoint:(NSInteger)scale;
+ (NSInteger) getZeroDecimalValueToAppend:(NSMutableString *)value scale:(NSInteger)scale;
+ (NSString *) getFormattedString:(NSString *)value decimalPoint:(NSInteger)scale;
+ (NSString *) removeTheExtraDecimalValueFromMapping:(NSMutableString *)value scale:(NSInteger)scale;
+ (BOOL) isValueNotANumber:(NSString *)string;

@end