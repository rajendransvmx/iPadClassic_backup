//
//  SMXiPad_Utility.h
//  ServiceMaxMobile
//
//  Created by Sahana on 08/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMXiPad_Utility : NSObject
+ (NSString *)getConcatenatedStringFromArray:(NSArray *)arayOfString withSingleQuotesAndBraces:(BOOL)isRequired;

+(UIKeyboardType)getKeyBoardTypeForDataType:(NSString*)type;

@end
