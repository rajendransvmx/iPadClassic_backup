//
//  Utility.m
//  iService
//
//  Created by Shravya shridhar on 2/20/13.
//
//

#import "Utility.h"
#import "SVMXSystemConstant.h"
#import "StringUtil.h"


void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);
@implementation Utility

+ (BOOL)checkIfStringEmpty:(NSString *)str {
    
    if (str != nil && !([[str class] isEqual:[NSNull class]]) && [str isKindOfClass:[NSString class]]) {
        
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![str isEqualToString:@""] && !([str isEqualToString:@" "] ) ) {
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)isStringEmpty:(NSString *)newString {
    
    return [Utility checkIfStringEmpty:newString];
}

+ (NSDate *)getDateFromString:(NSString *)someDateString {
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    [dateFormater setTimeZone:gmt];
    NSDate *someDate = [dateFormater dateFromString:someDateString];
    dateFormater = nil;
    return someDate;
}

+ (NSString *)currentDateInGMTForOPDoc {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *someDate = [dateFormatter stringFromDate:date];
//    NSString *newDateString = [NSString stringWithFormat:@"%@ 00:00:00",[someDate substringToIndex:10]];
//    NSDate *newDate = [dateFormatter dateFromString:newDateString];
    return someDate;
}

+ (NSDate *)todayDateInGMT {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *someDate = [dateFormatter stringFromDate:date];
    NSString *newDateString = [NSString stringWithFormat:@"%@ 00:00:00",[someDate substringToIndex:10]];
    NSDate *newDate = [dateFormatter dateFromString:newDateString];
    return newDate;
}

+ (BOOL)checkIfDate:(NSDate *)todayDate betweenDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NSTimeInterval startTI = [startDate timeIntervalSinceReferenceDate];
    NSTimeInterval endTI = [endDate timeIntervalSinceReferenceDate];
    NSTimeInterval todayTI = [todayDate timeIntervalSinceReferenceDate];
    
    if (startTI <= todayTI &&  todayTI <= endTI  ) {
        return YES;
    }
    return NO;
}

+ (NSDictionary *)getTheParameterFromUrlParameterString:(NSString*)urlParam {
    
    NSArray *stringArray = [urlParam componentsSeparatedByString:@"&"];
    NSMutableDictionary *keysDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *paramString in stringArray) {
        NSArray *valueArray =  [paramString componentsSeparatedByString:@"="];
        
        NSString *key = nil,*value = @"";
        if ([valueArray count] > 0) {
            key = [valueArray objectAtIndex:0];
        }
        
        if ([valueArray count] > 1) {
            value = [valueArray objectAtIndex:1];
        }
        if (key != nil) {
            [keysDictionary setObject:value forKey:key];
        }
    }
    return keysDictionary;
}

+ (NSString *)replaceTinDateBySpace:(NSString *)stringToBeChanged {
   
    stringToBeChanged = [stringToBeChanged stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger length =  [stringToBeChanged rangeOfString:@"T"].length;
    if (length > 0 ) {
        stringToBeChanged = [stringToBeChanged stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    }
    return stringToBeChanged;
}
+ (NSString *)replaceSpaceinDateByT:(NSString *)stringToBeChanged {
    stringToBeChanged = [stringToBeChanged stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger length =  [stringToBeChanged rangeOfString:@" "].length;
    if (length > 0 ) {
        stringToBeChanged = [stringToBeChanged stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    }
    return stringToBeChanged;
}

+ (BOOL)containsString:(NSString *)someString inString:(NSString *)parentString {
   NSRange range = [parentString rangeOfString:someString];
    if( NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) ) {
            return NO;
    }
    return YES;
}

+ (BOOL)isItTrue:(NSString *)stringTrue {
     stringTrue = [stringTrue lowercaseString];
    if ([stringTrue isEqualToString:@"true"]  || [stringTrue isEqualToString:@"True"] ||  [stringTrue isEqualToString:@"1"] ) {
        return YES;
    }
    return NO;
}

+ (BOOL)isStringNotNULL:(NSString *)value {
    NSString *someString = [NSString stringWithFormat:@"%@",value];
    value = [someString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    value = [value lowercaseString];
    if([value isEqualToString:@"<null>"] || [value isEqualToString:@"<NULL>"] || [value isEqualToString:@"Null"] || [value isEqualToString:@"null"]){
        return NO;
    }
    return YES;
}

+ (NSString *)getConcatenatedStringFromArray:(NSArray *)arayOfString withSingleQuotesAndBraces:(BOOL)isRequired {
    if ([arayOfString count] <= 0) {
        return nil;
    }
    NSMutableString *concatenatedString = [[NSMutableString alloc] init];
    
    if (isRequired) {
        for (int counter = 0; counter < [arayOfString count]; counter++) {
            
            NSString *tempStr = [arayOfString objectAtIndex:counter];
            if (counter == 0) {
                [concatenatedString appendFormat:@"('%@'",tempStr];
            }
            else{
                [concatenatedString appendFormat:@",'%@'",tempStr];
            }
        }
        [concatenatedString appendFormat:@")"];
    }
    else {
        for (int counter = 0; counter < [arayOfString count]; counter++) {
            
            NSString *tempStr = [arayOfString objectAtIndex:counter];
            if (counter == 0) {
                [concatenatedString appendFormat:@"%@",tempStr];
            }
            else{
                [concatenatedString appendFormat:@",%@",tempStr];
            }
        }
    }
    
    return concatenatedString;
}

+ (NSString *)getMeLocalHTML {
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"temp" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)getPriceDownloadStatus {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"GP_DL_STATUS"];
}

+ (void )setPriceDownloadStatus:(NSString *)statusValue {
    [[NSUserDefaults standardUserDefaults] setObject:statusValue forKey:@"GP_DL_STATUS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void )removePriceDownloadStatus {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GP_DL_STATUS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark-
#pragma mark Literal utilities
+ (NSString *)today:(NSInteger)numberOfDays andJusDate:(BOOL)isDateOnly{
    NSDate *date = [NSDate date];
    NSTimeInterval timeIntervalToBeAdded = 60* 60.0 * 24 * numberOfDays;
    NSDate *finalDate = [date dateByAddingTimeInterval:timeIntervalToBeAdded];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *someDate = [dateFormatter stringFromDate:finalDate];
    
    NSString *newDateString = nil;
    if (isDateOnly) {
        newDateString = [NSString stringWithFormat:@"%@ 00:00:00",[someDate substringToIndex:10]];
    }
    else {
        newDateString = someDate;
    }
    newDateString = [newDateString stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    dateFormatter = nil;
    return newDateString;
}

+ (NSString *)getUserTrunkRequestStatus {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_TRUNK_LOCATION"];
}

+ (void )setUserTrunkRequestStatus:(NSString *)statusValue {
    [[NSUserDefaults standardUserDefaults] setObject:statusValue forKey:@"USER_TRUNK_LOCATION"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)splitString:(NSString *)stringToBeSplit byString:(NSString *)subString {
    stringToBeSplit = [stringToBeSplit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *componentsArray = [stringToBeSplit componentsSeparatedByString:subString];
    return componentsArray;
}



#pragma mark - 7751
+ (void)setRefreshCalendarView {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"REFRESH_CALENDAR_VIEW"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)getRefreshCalendarView {
     return [[NSUserDefaults standardUserDefaults] boolForKey:@"REFRESH_CALENDAR_VIEW"];
}
+ (void)clearRefreshCalendarView {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"REFRESH_CALENDAR_VIEW"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*ios7_support shravya*/
#pragma mark-
#pragma mark -
+ (BOOL)notIOS7 {
    
    double systemVersion =  [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion < 7) {
        return YES;
    }
    return NO;
}
+ (BOOL)isDeviceIOS8 {
    
    double systemVersion =  [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8) {
        return YES;
    }
    return NO;
}
+ (UIImage *)getLeftNavigationBarImage {
    UIImage *navImage = [UIImage imageNamed:@"navigation-bar-320-x-44.png"];
    navImage = [navImage resizableImageWithCapInsets:UIEdgeInsetsMake(8, 11, 0, 0) resizingMode:UIImageResizingModeStretch];
    return navImage;
}

+ (UIImage *)getRightNavigationBarImage {
    
    UIImage *navImage = [UIImage imageNamed:@"navigation-bar-703-x-44.png"];
    navImage = [navImage resizableImageWithCapInsets:UIEdgeInsetsMake(8, 11, 0, 0) resizingMode:UIImageResizingModeStretch];
    return navImage;
}


#pragma mark - //8890

+ (BOOL)hasColumnSequence {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"SEQUENCE_SFWIZARD_COMPONENT"];
}

+ (void)setSequenceColoumntrue {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SEQUENCE_SFWIZARD_COMPONENT"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//9196
+ (NSString *)formattedFileSize:(long long int)size
{
    
    double value = (double)size;
    int factor = 0;
    
    NSArray *fileSizeUnits = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (value > 1024)
    {
        value /= 1024;
        factor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",value, [fileSizeUnits objectAtIndex:factor]];
}

//9196
+ (NSString *)formattedFileSizeForAttachment:(long long int)size
{
   
    NSString * formattedString = nil;
   
    if (size <= 1024)
    {
        formattedString = @"1.00 KB";
    }
    else
    {
        formattedString = [Utility formattedFileSize:size];
    }
    return formattedString;
}

+ (BOOL)isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
}

+ (NSString *)jsonStringFromObject:(id)object
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    NSString *result = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    return result;
}

+ (id)objectFromJsonString:(NSString *)jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return json;
}


+(NSInteger)requestTimeOutValueFromSetting
{
    NSInteger requestTimeOutInSec = 180;
    NSString *stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"reqTimeout_Setting"];
    NSInteger requestTimeOut = 0;
    if ([StringUtil isStringEmpty:stringValue])
    {
        requestTimeOut = [stringValue integerValue];
        requestTimeOutInSec = requestTimeOut * 60;
    }
    return requestTimeOutInSec;
}


@end
