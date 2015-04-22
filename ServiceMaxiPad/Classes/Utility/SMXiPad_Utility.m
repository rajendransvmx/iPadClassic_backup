//
//  SMXiPad_Utility.m
//  ServiceMaxMobile
//
//  Created by Sahana on 08/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SMXiPad_Utility.h"

@implementation SMXiPad_Utility
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


+ (UIKeyboardType)getKeyBoardTypeForDataType:(NSString*)type
{
    UIKeyboardType keyBoardType = UIKeyboardTypeDefault;
    if([type isEqualToString:kSfDTCurrency]
       || [type isEqualToString:kSfDTDouble]
       || [type isEqualToString:kSfDTPercent])
    {
        keyBoardType = UIKeyboardTypeDecimalPad;
    }
    else if ([type isEqualToString:kSfDTInteger]) {
        
        keyBoardType = UIKeyboardTypeNumberPad;
    }
    else if ([type isEqualToString:kSfDTEmail]){
        keyBoardType = UIKeyboardTypeEmailAddress;
    }
    return keyBoardType;
}

@end
