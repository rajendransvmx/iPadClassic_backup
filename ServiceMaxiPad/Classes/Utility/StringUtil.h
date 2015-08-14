//
//  StringUtil.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/11/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtil : NSObject

+ (BOOL)checkIfStringEmpty:(NSString *)str;
+ (BOOL)isStringEmpty:(NSString *)string;

+ (BOOL)isValidOrZeroLengthString:(NSString *)string;
+ (BOOL)isStringNotNULL:(NSString *)value;

+ (BOOL)containsString:(NSString *)subString inString:(NSString *)metaString;
+ (NSString *)getConcatenatedStringFromArray:(NSArray *)arayOfString withSingleQuotesAndBraces:(BOOL)isRequired;

+ (BOOL)isItTrue:(NSString *)stringTrue ;
+ (CGSize)getSizeOfText:(NSString*)text withFont:(UIFont*)font;
+ (CGSize)getSizeOfText:(NSString*)text withFont:(UIFont*)font andRect:(CGRect)rect;
+ (NSArray *)splitString:(NSString *)stringToBeSplit byString:(NSString *)subString;
+(NSString *)appendOrgNameSpaceToString:(NSString *)toString;

+ (BOOL)isStringNumber:(NSString *)string;
+ (BOOL)containsStringinErrorMsg:(NSString *)subString inString:(NSString *)metaString;
@end
