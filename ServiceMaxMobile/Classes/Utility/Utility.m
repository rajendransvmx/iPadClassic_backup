//
//  Utility.m
//  iService
//
//  Created by Shravya shridhar on 2/20/13.
//
//

#import "Utility.h"
#import "SBJsonParser.h"
#import "AppDelegate.h"
#import "SVMXSystemConstant.h"

//#include <math.h>


void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);
@implementation Utility

+ (BOOL)checkIfStringEmpty:(NSString *)str {
    
    
    if (str != nil && !([[str class] isEqual:[NSNull class]])) {
        
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
    [dateFormater release];
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
    [dateFormatter release];
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
    [dateFormatter release];
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
    return [keysDictionary autorelease];
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
    
    return [concatenatedString autorelease];
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

+ (void)showLog:(NSString *)loggedMessage {
    
    SMLog(kLogLevelVerbose,@"DALAYER: %@ ",loggedMessage);
}
//  Unused Methods
//+ (NSDictionary *) getParameterDictionaryFromURL:(NSString *) urlParams {
//    
//    NSArray *componentsArray =  [urlParams componentsSeparatedByString:@"&"];
//    if ([componentsArray count] <= 0) {
//        return nil;
//    }
//    
//    NSMutableDictionary *parameterDictionary = [[NSMutableDictionary alloc] init];
//    for (NSString *component in componentsArray) {
//        
//        NSArray *subComponents = [component componentsSeparatedByString:@"="];
//        NSString *fieldName = nil, *fieldValue = nil;
//        
//        if ([subComponents count] > 0) {
//            fieldName = [subComponents objectAtIndex:0];
//        }
//        
//        if ([subComponents count] > 1) {
//            fieldValue = [subComponents objectAtIndex:1];
//        }
//        
//        if (![Utility isStringEmpty:fieldName] && ![Utility isStringEmpty:fieldValue] ) {
//            
//            fieldName = [fieldName stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
//            fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
//            [parameterDictionary setObject:fieldValue forKey:fieldName];
//        }
//    }
//    
//    return [parameterDictionary autorelease];
//    
//}

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
    [dateFormatter release];
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
//  Unused Methods
//+ (void )removeUserTrunkRequestStatus {
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_TRUNK_LOCATION"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

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

//8915
+ (CGSize) getBoundSizeForString:(NSString *)text withFont:(UIFont *)someFont andheight:(CGFloat)maxHeight{
    
    CGSize finalSize = CGSizeZero;
    NSDictionary *someDict = [NSDictionary dictionaryWithObjectsAndKeys:someFont,NSFontAttributeName, nil];
    CGSize maxSize = CGSizeMake(CGFLOAT_MAX, maxHeight);
    if ([Utility notIOS7]) {
        finalSize = [text sizeWithFont:someFont constrainedToSize:CGSizeMake(1024, 1024) lineBreakMode:NSLineBreakByWordWrapping];
    }
    else{
        CGRect rect =  [text boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine attributes:someDict context:nil];
        finalSize = rect.size;
    }
    return finalSize;
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


+(NSMutableArray *)getIdsFromJsonString:(NSString *)jsonstrings
{
    //NSArray * records_array = [jsonstrings componentsSeparatedByString:@"}"","];
    jsonstrings = [jsonstrings stringByReplacingOccurrencesOfString:@"[" withString:@""];
    jsonstrings = [jsonstrings stringByReplacingOccurrencesOfString:@"]" withString:@""];
    jsonstrings = [jsonstrings stringByReplacingOccurrencesOfString:@"},{" withString:@"}$,${"];
    NSArray * records_array = [jsonstrings componentsSeparatedByString:@"$,$"];
    
    NSMutableArray * records_list = [[NSMutableArray alloc] initWithCapacity:0] ;
    @try{
        for(NSString * jsonString in records_array)
        {
            NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
            SBJsonParser * jsonParser_ = [[[SBJsonParser alloc] init] autorelease];
            NSDictionary * jsonDict = [jsonParser_ objectWithString:jsonString];
            NSArray * allkeys = [jsonDict allKeys];
            for(id  temp in allkeys)
            {
                if([temp isKindOfClass:[NSString class]])
                {
                    NSString * final_id = (NSString *)temp;
                    if([final_id isEqualToString:@"Id"])
                    {
                        NSString * value =  [jsonDict  objectForKey:final_id];
                        [records_list addObject:value];
                        value = nil;
                    }
                }
            }
            allkeys = nil;
            [autoReleasePool drain];
            //  jsonDict = nil;
        }
        jsonstrings = nil;
        records_array = nil;
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name WSInterface :getIdFromJsonString %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason WSInterface :getIdFromJsonString %@",exp.reason);
    }
    return [records_list autorelease];
}

+ (id ) getJsonArrayFromString:(NSString *)jsonRecord
{
    
    SBJsonParser * jsonParser = [[SBJsonParser alloc] init];
    id json_array = [jsonParser objectWithString:jsonRecord];
    [jsonParser autorelease];
    
    return json_array;
}

/*Radha - Data Purge*/
+ (NSDate *)getDatetimeFromString:(NSString *)someString
{
    NSDate * date = nil;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
   
    date = [dateFormatter dateFromString:someString];
    
    [dateFormatter release];
    
    return date;
    
}

+ (NSString *)getUserReableStringFromDate:(NSDate *)date
{
    NSString * dateInString = nil;
    
    NSDateComponents * dateComponents = [self getDateComponents];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[dateComponents timeZone]];
    [formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [formatter setCalendar:cal];
    [cal release];
    if ([self iSDeviceTime24HourFormat])
    {
        [formatter setDateFormat:DATETIMEFORMAT24HR];
    }
    else
    {
        [formatter setDateFormat:DATETIMEFORMAT];
    }
    dateInString = [formatter stringFromDate:date];
    [formatter release];
    
    return dateInString;
}

+ (NSDateComponents *) getDateComponents
{
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSTimeZoneCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents * dateComponents = [gregorian components:unitFlags fromDate:[NSDate date]];
	
	return dateComponents;
}


+ (NSString *)getStringFromDate:(NSDate *)someDate
{
    NSString * dateString = nil;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    dateString = [dateFormatter stringFromDate:someDate];
    [dateFormatter release];
    
    return dateString;
    
}
+ (NSString *)getValueForTagFromTagDict:(NSString *)key
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return [appDelegate.wsInterface.tagsDictionary objectForKey:key];
}

+ (NSString *)getValueForSettingIdFromDict:(NSString *)key
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return [appDelegate.settingsDict objectForKey:key];
}

+ (NSTimeInterval)getTimerIntervalForDataPurge
{
    NSString * purgeFrequency = [self getValueForSettingIdFromDict:kWSAPIResponseDataPurgeFrequency];
    
    int value = [purgeFrequency intValue];
    
    NSTimeInterval scheduledTimer = 0;
    
    if (value != 0)
    {
        if (![purgeFrequency isEqualToString:@""] && ([purgeFrequency length] > 0) )
        {
            double timeInterval = [purgeFrequency doubleValue];
            
            scheduledTimer = timeInterval * 60 * 60;
        }
    }
    return scheduledTimer;
}


+ (NSDate *)getDateTimeForNextDataPurge:(NSDate *)date
{
    NSDate * nextDPTime  = nil;
    NSLog(@"%@ , %f, %@", date, [self getTimerIntervalForDataPurge], [date dateByAddingTimeInterval:[self getTimerIntervalForDataPurge]]);
    return  nextDPTime = [date dateByAddingTimeInterval:[self getTimerIntervalForDataPurge]];
}


//Data Purge - ProductManual File Path - 10181
+(NSString*)pathForProductManual
{
    AppDelegate *appdelegate=(AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    NSError *readingError;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDir = (NSMutableString*)[appdelegate getAppCustomSubDirectory];
    
    if (![fileManager fileExistsAtPath:documentsDir])
        [fileManager createDirectoryAtPath:documentsDir
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&readingError];
    return documentsDir;
}

//010312 - Defect Fix
+(BOOL)iSDeviceTime24HourFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    
    [formatter release];
    return is24h;
}

+ (NSDate *) getDateFromStringFromPlist:(NSString *)value userRedable:(BOOL)boolValue
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [dateFormatter setCalendar:cal];
    [cal release];
    if (boolValue)
    {
        if ([self isString24HrFormat:value])
        {
            [dateFormatter setDateFormat:DATETIMEFORMAT24HR];
        }
        else
        {
            [dateFormatter setDateFormat:DATETIMEFORMAT];
        }
    }
    else
    {
        if ([self isString24HrFormat:value])
        {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            
        }
        else
        {
            if ([self isString24HrFormat:value])
            {
                 [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
                 [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            }
            else
            {
                 [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
                
            }
           
        }
    }
    NSDate * date = [dateFormatter dateFromString:value];
    
    return date;
}

+ (BOOL) isString24HrFormat:(NSString *)value
{
    BOOL is24HrFormat = NO;
    
    if ([value hasSuffix:@"AM"] || [value hasSuffix:@"am"] || [value hasSuffix:@"PM"] || [value hasSuffix:@"pm"] )
    {
        is24HrFormat = NO;
    }
    else
    {
        is24HrFormat = YES;
    }
    return is24HrFormat;
}

//10312
+ (NSString *) getStringFromDateForDeviceTime:(NSDate *)date
{
    NSString * dateString = nil;
    
    if (date != nil)
    {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        if([Utility iSDeviceTime24HourFormat])
        {
            [dateFormatter setDateFormat:DATETIMEFORMAT24HR];
        }
        else
        {
            [dateFormatter setDateFormat:DATETIMEFORMAT];
        }
        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSTimeZoneCalendarUnit;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents * todayDateComponents = [gregorian components:unitFlags fromDate:[NSDate date]];
        [dateFormatter setTimeZone:[todayDateComponents timeZone]];
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
        [dateFormatter setCalendar:gregorian];
        [gregorian release];
        dateString = [dateFormatter stringFromDate:date];
        [dateFormatter release];
    }
    if (dateString == nil && [dateString length] == 0)
    {
        dateString = @"";
    }
    return dateString;
}

//10346
#pragma mark - Precsion Handling
+ (NSString *) getFormattedString:(NSString *)value decimalPoint:(NSInteger)scale
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    // Use decimal style - this includes grouping
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSDecimalNumber* number = [NSDecimalNumber decimalNumberWithString:value];
    [formatter setMaximumFractionDigits:scale];
    NSString * formattedNumber = [formatter stringFromNumber:number];
    [formatter release];
    
    formattedNumber = [formattedNumber stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    return formattedNumber;
}


+ (NSMutableString *) appendOrRemoveZeroToDecimalPoint:(NSMutableString *)value decimalPoint:(NSInteger)scale;
{
    NSMutableString * someString = [NSMutableString stringWithCapacity:0];
    
    NSInteger zeroValue = [self getZeroDecimalValueToAppend:value scale:scale];
    
    if (zeroValue > 0)
    {
        someString  = [self appendZeroToDecimalPoint:value decimalPoint:zeroValue];
    }
    else
    {
        someString = (NSMutableString *)[self removeTheExtraDecimalValueFromMapping:value scale:scale];
    }
    return someString;
}

/*Considering decimal value can be maximum 4. If it is more than 4 using for loop to append zeros, instead looping throught every time*/
+ (NSMutableString *) appendZeroToDecimalPoint:(NSMutableString *) value decimalPoint:(NSInteger)scale
{
    if (![self containsString:@"." inString:(NSString *)value])
    {
        [value appendFormat:@"."];
    }
    
    switch (scale) {
        case 1:
            [value appendFormat:@"0"];
            break;
            
        case 2:
            [value appendFormat:@"00"];
            break;
            
        case 3:
            [value appendFormat:@"000"];
            break;
            
        case 4:
            [value appendFormat:@"0000"];
            break;
            
        default:
            for (int i = 0; i < scale; i++)
            {
                [value appendString:@"0"];
            }
            break;
    }
    return value;
    
}


+ (NSInteger) getZeroDecimalValueToAppend:(NSMutableString *)value scale:(NSInteger)scale
{
    NSInteger zerovalue = 0;
    
    if ([self containsString:@"." inString:(NSString *)value])
    {
        NSArray * array = [value componentsSeparatedByString:@"."];
        
        if ([array count] == 2)
        {
            NSString * string = [array objectAtIndex:1];
            
            NSInteger lenght = [string length];
            
            if (lenght < scale)
            {
                zerovalue = scale - lenght;
            }
        }
    }
    else
    {
        zerovalue = scale;
    }
    return zerovalue;
}

+ (NSMutableString *) removeTheExtraDecimalValueFromMapping:(NSMutableString *)value scale:(NSInteger)scale
{
    NSMutableString * someString = [NSMutableString stringWithCapacity:0];
    
    if ([self containsString:@"." inString:(NSString *)value])
    {
        NSArray * array = [value componentsSeparatedByString:@"."];
        
        if ([array count] == 2)
        {
            NSString * string = [array objectAtIndex:1];
            
            NSInteger lenght = [string length];
            
            if (lenght > scale && scale != 0)
            {
                NSString * newValue = [string substringToIndex:scale];
                
                if ([newValue length] > 0)
                {
                    [someString appendString:[array objectAtIndex:0]];
                    [someString appendString:@"."];
                    [someString appendString:newValue];
                }
            }
            else if (scale == 0)
            {
                someString = [array objectAtIndex:0];
            }
            else
            {
                someString = value;
            }
        }
    }
    return someString;
}

+ (BOOL) isValueNotANumber:(NSString *)string
{
    BOOL iSNaN = NO;
    
    NSComparisonResult result = [string caseInsensitiveCompare:@"NaN"];
    
    if (result == NSOrderedSame)
    {
        iSNaN = YES;
    }
    
    return iSNaN;
}

#pragma mark - END

@end
