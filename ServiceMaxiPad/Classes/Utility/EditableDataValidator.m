//
//  EditableCellValidator.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 25/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "EditableDataValidator.h"
#import "NumberUtility.h"
#import "StringUtil.h"

@implementation EditableDataValidator

+ (BOOL)validateNumberString:(NSString*)string
              inParentString:(NSString*)parentString
                   withRange:(NSRange)range
                 andDataType:(NSString*)dataType
{
    BOOL isTextAllowed = NO;
    
    if([dataType isEqualToString:kSfDTCurrency]  //Including integer other numberfields should consider.
       || [dataType isEqualToString:kSfDTDouble]
       || [dataType isEqualToString:kSfDTPercent] ||[dataType isEqualToString:kSfDTInteger]) {
        
        isTextAllowed =   [NumberUtility isValidIntegerValue:string];
        if ([string isEqualToString:@""]) //Checking for backspace key
        {
            isTextAllowed = YES;
        }
        if ([string isEqualToString:@"-"]) //Handling negative numbers. (- can come only in first position)
        {
            if (range.location == 0)
                isTextAllowed  = YES;
        }
    if([dataType isEqualToString:kSfDTCurrency]  //Except integer for other numberfields should consider.
       || [dataType isEqualToString:kSfDTDouble]
       || [dataType isEqualToString:kSfDTPercent]){
        
        if([string isEqualToString: @"."]) {
            
            BOOL isDotAlreadyPresent = [NumberUtility isDotFoundInText:parentString]; //Only one dot should be allowed
            if (!isDotAlreadyPresent) {
                isTextAllowed = YES;
            }
        }
    }
    } else {
        
        isTextAllowed = YES;
    }
    
   
    
    return isTextAllowed;
}
+ (BOOL)precisionHandlingNumberString:(NSString*)string
                       inParentString:(NSString*)parentString
                            withRange:(NSRange)range
                          andDataType:(NSString*)dataType
                            precision:(NSInteger)precision
                                scale:(NSInteger)scaleParam
{
    if ([string isEqualToString:@""]) //Checking for backspace key
    {
        return YES;
    }
    
    if([dataType isEqualToString:kSfDTCurrency]  //Except integer for other numberfields should consider.
       || [dataType isEqualToString:kSfDTDouble]
       || [dataType isEqualToString:kSfDTPercent]){
        
        NSInteger totoalLenghth = precision - scaleParam;
        NSInteger scale;
        scale = scaleParam;
        
        NSMutableString * mutableStr = [[NSMutableString alloc] initWithString:parentString];
        [mutableStr insertString:string atIndex:range.location];
        
        NSString * finalStr = mutableStr;
        
        NSArray * comp = [finalStr componentsSeparatedByString:@"."];
        
        NSString * precisionStr = nil, *scaleStr = nil;
        
        for (int counter = 0; counter < [comp count]; counter++) {
           NSString * tempStr = [comp objectAtIndex:counter];

            if(counter == 0){
                precisionStr = tempStr;
            }
            else if (counter == 1){
                scaleStr = tempStr;
            }
        }
        
        NSInteger noOfSpecialChar = [EditableDataValidator numberOfSpecialCharacters:precisionStr];
        
        NSInteger finalPrecisionLength =  precisionStr.length - noOfSpecialChar;
        
        if(finalPrecisionLength  > totoalLenghth )
        {
            return NO;
        }
        //Defect Fix 041025
        if(scaleStr.length > scale){
            return NO;
        }
        
       
        
      //  NSInteger finalPreclength = ([finalStr containsString:@"."])?precision+1:precision;
        
        NSInteger finalPreclength = ([StringUtil containsString:@"." inString:finalStr])?precision+1:precision;
        finalPreclength = ([StringUtil containsString:@"-" inString:finalStr])?finalPreclength+1:finalPreclength;//Defect Fix 041025
        if(finalStr.length > finalPreclength){
            return NO;
        }
        
        return YES;
    }
    
    return YES;
}
+(BOOL)testRegularExpression:(NSString *)finalStr{
    
   NSInteger noOfMatches = [EditableDataValidator numberOfSpecialCharacters:finalStr];
    if(noOfMatches > 0){
        return YES;
    }
    return NO;
}

+(NSInteger)numberOfSpecialCharacters:(NSString *)finalStr{
    
    NSRegularExpression * reg = [[NSRegularExpression alloc] initWithPattern:@"[!\"#$%&'()*+,./:;<=>?@\\^_`{|}~-]" options:0 error:nil];
    
    NSUInteger  noOfMatches = [reg numberOfMatchesInString:finalStr options:NSMatchingReportProgress range:NSMakeRange(0, finalStr.length)];
    
    return noOfMatches;
    
}


@end
