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
#import "TagConstant.h"
#import "MobileDeviceSettingService.h"

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
    NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    //Set the timezone to GMT.
    NSDateFormatter *svmxDateFormatter = [[NSDateFormatter alloc] init];
    //Set the date format.
    [svmxDateFormatter setDateFormat:@"yyyy-MM-dd"];
    //Set the timezone of the dateformatter to GMT.
    [svmxDateFormatter setTimeZone:gmtTimeZone];
    //Get the date from the formatter string.
    NSDate *someDate = [svmxDateFormatter dateFromString:someDateString];
    svmxDateFormatter = nil;
    return someDate;
}

+ (NSString *)currentDateInGMTForOPDoc {
    NSDate *currentDate = [NSDate date];
    //Get current date.
    NSDateFormatter *svmxDateFormatter = [[NSDateFormatter alloc] init];
    //GMT TimeZone.
    NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    //Set DateFormatter to GMT TimeZone.
    [svmxDateFormatter setTimeZone:gmtTimeZone];
    //Set the date format.
    [svmxDateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    //Get the date string from the formatter.
    NSString *someDate = [svmxDateFormatter stringFromDate:currentDate];
    return someDate;
}

+ (NSDate *)todayDateInGMT {
    NSDate *currentDate = [NSDate date];
    //Get the current date
    NSDateFormatter *svmxDateFormatter = [[NSDateFormatter alloc] init];
    //Set the timezone to GMT
    NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    //Date formatter set to GMT
    [svmxDateFormatter setTimeZone:gmtTimeZone];
    //Set the date format
    [svmxDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //Get the date string from formatter
    NSString *someDate = [svmxDateFormatter stringFromDate:currentDate];
    //Append time values for the date string
    NSString *newDateString = [NSString stringWithFormat:@"%@ 00:00:00",[someDate substringToIndex:10]];
    //Get the new date
    NSDate *newDate = [svmxDateFormatter dateFromString:newDateString];
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
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeIntervalToBeAdded = 60* 60.0 * 24 * numberOfDays;
    NSDate *finalDate = [currentDate dateByAddingTimeInterval:timeIntervalToBeAdded];
    NSDateFormatter *svmxDateFormatter = [[NSDateFormatter alloc] init];
    //Set the timezone to GMT.
    NSTimeZone *gmtTimezone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    //Set the dateformatter to GMT timezone.
    [svmxDateFormatter setTimeZone:gmtTimezone];
    //Set the date format.
    [svmxDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //Get the date from the final date.
    NSString *someDate = [svmxDateFormatter stringFromDate:finalDate];
    
    NSString *newDateString = nil;
    if (isDateOnly) {
        newDateString = [NSString stringWithFormat:@"%@ 00:00:00",[someDate substringToIndex:10]];
    }
    else {
        newDateString = someDate;
    }
    newDateString = [newDateString stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    svmxDateFormatter = nil;
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

// SECSCAN-260
+(BOOL)isSSLPinningEnabled
{
    BOOL isPinningEnabled = NO;
    
    NSString *pinningEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:kSSLPinningEnabled];
    
    if(pinningEnabled)
    {
        isPinningEnabled = [pinningEnabled boolValue];
    }
    else
    {
        MobileDeviceSettingService *mobileDeviceSettingService = [[MobileDeviceSettingService alloc]init];
        MobileDeviceSettingsModel *mobDeviceSettings = [mobileDeviceSettingService fetchDataForSettingId:@"IPAD018_SET023"];
        isPinningEnabled = [StringUtil isItTrue:mobDeviceSettings.value];
    }
    
    return isPinningEnabled;
}


@end
