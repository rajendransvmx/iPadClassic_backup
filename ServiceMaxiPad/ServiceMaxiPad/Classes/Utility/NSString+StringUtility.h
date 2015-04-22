//
//  NSString+StringUtility.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 21/05/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   NSString+StringUtility.h
 *  @class  NSString (StringUtility)
 *
 *  @brief  Category on NSString class with handy methods.
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>

@interface NSString (StringUtility)

/**
 * @name custStringWithFormat:
 *
 * @author Pushpak
 *
 * @brief Optimised method for Standard stringWithFormat: method on NSString.
 *
 *
 *
 * @param fmt Format string on which the following variable arguments depend.
 * @param ... Variable arguments based on the format string parameter.
 *
 * @return Formatted NSString object
 *
 */
+ (NSString *)stringWithDefinedFormat:(char *)fmt, ...;

/**
 * @name custAppend:
 *
 * @author Pushpak
 *
 * @brief Method to append multiple NSString objects
 *
 *
 *
 * @param list NSString objects to append following strings given in variable argument.
 * @param ... Variable arguments of NSString objects.
 *
 * ONLY pass NON NULL objects as parameter.
 *
 * @return Appended NSString object.
 *
 */
+ (NSString *)custAppend:(NSString *)list, ...;

/**
 * @name custContains:
 *
 * @author Pushpak
 *
 * @brief Method to check whether passed string is substring of the string.
 *
 *
 *
 * @param string NSString object which you want to check.
 *
 * @return True:if given string is present else False.
 *
 */
- (BOOL)stringContains:(NSString*)string;

/**
 * @name custContainsOnlyLetters
 *
 * @author Pushpak
 *
 * @brief Method to check whether string contains only letters.
 *
 *
 * @return True:if string is made up of only letters else False.
 *
 */
- (BOOL)stringContainsOnlyLetters;

/**
 * @name custContainsOnlyNumbers
 *
 * @author Pushpak
 *
 * @brief Method to check whether string contains only numbers.
 *
 *
 * @return True:if string is made up of only numbers else False.
 *
 */
- (BOOL)stringContainsOnlyNumbers;

/**
 * @name custContainsOnlyNumbersAndLetters
 *
 * @author Pushpak
 *
 * @brief Method to check whether string contains only letters and numbers.
 *
 *
 * @return True:if string is made up of only numbers and letters else False.
 *
 */
- (BOOL)stringContainsOnlyNumbersAndLetters;

/**
 * @name custStringByRemovingPrefix:
 *
 * @author Pushpak
 *
 * @brief Method to remove prefix string.
 *
 *
 *
 * @param prefix NSString object representing prefix characters.
 *
 * @return NSString object without prefix.
 *
 */
- (NSString*)custStringByRemovingPrefix:(NSString*)prefix;

/**
 * @name custStringByRemovingPrefixes:
 *
 * @author Pushpak
 *
 * @brief Method to remove prefix in string from a list of prefixes.
 *
 *
 *
 * @param prefixes Collection of prefixes.
 *
 * @return NSString object without prefix.
 *
 */
- (NSString*)custStringByRemovingPrefixes:(NSArray*)prefixes;

/**
 * @name custHasPrefixes:
 *
 * @author Pushpak
 *
 * @brief Method to check whether string has any prefix among given prefixes.
 *
 *
 * @param prefixes Collection of prefixes
 *
 * @return True:if String has one of the prefix else False.
 *
 */
- (BOOL)custHasPrefixes:(NSArray*)prefixes;

/**
 * @name custIsEqualToOneOf:
 *
 * @author Pushpak
 *
 * @brief Method to check if string is equal to one of strings passed.
 *
 *
 *
 * @param strings collection of strings
 *
 * @return True:if string is equal to one of the strings else False.
 *
 */
- (BOOL)custIsEqualToOneOf:(NSArray*)strings;

/**
 * @name custIsBlank
 *
 * @author Pushpak
 *
 * @brief Method to check string is blank.
 *
 *
 * @return True:if string is blank else False.
 *
 */
- (BOOL)custIsBlank;

/**
 * @name custStringByStrippingWhitespace
 *
 * @author Pushpak
 *
 * @brief Method to remove spaces from string.
 *
 *
 * @return NSString object without spaces.
 *
 */
- (NSString *)custStringByStrippingWhitespace;

/**
 * @name custSubstringFrom:to:
 *
 * @author Pushpak
 *
 * @brief Method to get sub string with given range.
 *
 *
 *
 * @param from Index of Start
 * @param to Index of End
 *
 * @return Substring NSString object.
 *
 */
- (NSString *)custSubstringFrom:(NSInteger)from to:(NSInteger)to;

/**
 * @name custStringWithReplacingOccurrencesOfString:withString:
 *
 * @author Pushpak
 *
 * @brief Replacement of standard NSString method
 * - (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement
 *
 *
 *
 * @param target string that has to be matched
 * @param replacement string that has to be replaced
 *
 * @return Resulting NSString object.
 *
 */
- (NSString *)custStringWithReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement;

- (BOOL)custContainsString:(NSString*)other;

@end
