//
//  EditableCellValidator.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 25/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "EditableDataValidator.h"
#import "NumberUtility.h"

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

@end
