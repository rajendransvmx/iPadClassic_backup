//
//  NumberUtility.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   NumberUtility.h
 *  @class  NumberUtility
 *
 *  @brief  Utility class for number
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>

/*
 *  NumberSystemLimit
 *
 *  Discussion:
 *      Enumerates the different possible number limitation in the system.
 *  
    MAX_iOS_int = 2147483647
    MAX_iOS_DOUBLE = 9223372036854775808.0
    MAX_iOS_Long_Long = 9223372036854775807
    MAX_iOS_Long_Long = 9223372036854775807
 
    SQLite_INTEGER 9223372036854775807, - 9223372036854775807;
    SQLite_REAL    9223372036854775807.0, - 9223372036854775807.0;
 
    SALESFORCE_number Length - 18;
    SALESFORCE_number Lenht - 19;
 *
 *
 */

enum {
    
    NSLimitValid = 101,                          // Number Valid
    NSLimitExceedingSalesForceRealLimit = 1,     // Number Exceeding SalesForce Real Number limit
    NSLimitExceedingSalesForceIntgerLimit = 2,   // Number Exceeding SalesForce Integer Number limit
    NSLimitExceedingSQLiteIntgerLimit = 3,       // Number Exceeding SQLite Integer Number limit
    NSLimitExceedingSQLiteRealLimit = 4,         // Number Exceeding SQLite Real Number limit
    NSLimitExceedingiOSIntLimit = 5,             // Number Exceeding iOS int Number limit
    NSLimitExceedingiOSLonLongLimit = 6,         // Number Exceeding iOS Long Long Number limit
    NSLimitExceedingiOSDoubleLimit = 7,          // Number Exceeding iOS Double Number limit
    NSLimitOverFlowConfiguredPrecisionLimit = 8, // Number Exceeding configured precision limit

};
typedef NSInteger NumberSystemLimit;

/*

*/


@interface NumberUtility : NSObject

/**
 * @name   (NumberSystemLimit)isValidRealNumber:(NSString *)realNumber withPrecision:(int)precision
 *
 * @author Vipindas Palli
 *
 * @brief  Validate given real number meeting matching criteria of sales force limit, SQLite limit and iOS limit
 *
 * \par
 *  <Longer description starts here>
 * @param1 realNumber a number in string format
 * @param1 precision  a number in string format  which represnets in precision part of the real number
 * @return NumberSystemLimit value
 *
 */

+ (NumberSystemLimit)isValidRealNumber:(NSString *)realNumber withPrecision:(int)precision;

/**
 * @name   (NumberSystemLimit)isValidInteger:(NSString *)intValue;
 *
 * @author Vipindas Palli
 *
 * @brief  Validate given integer number meeting matching criteria of sales force limit, SQLite limit and iOS limit
 *
 * \par
 *  <Longer description starts here>
 * @param1 intValue a number in string format
 * @return NumberSystemLimit value
 *
 */

+ (NumberSystemLimit)isValidInteger:(NSString *)intValue;

+ (NumberSystemLimit)isValidInteger:(NSString *)intValue withEnabledLangLimit:(BOOL)bolean;

@end
