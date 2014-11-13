//
//  SFHFKeychainUtils.h
//
//  Created by Buzz Andersen on 10/20/08.
//  Based partly on code by Jonathan Wight, Jon Crosby, and Mike Malone.
//  Copyright 2008 Sci-Fi Hi-Fi. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>


@interface SFHFKeychainUtils : NSObject {
  
}

+ (NSString *) getPasswordForUsername: (NSString *) username
                       andServiceName: (NSString *) serviceName
                                error: (NSError **) error;
+ (BOOL) storeUsername: (NSString *) username
           andPassword: (NSString *) password
        forServiceName: (NSString *) serviceName
        updateExisting: (BOOL) updateExisting
                 error: (NSError **) error;

+ (BOOL) deleteItemForUsername: (NSString *) username
                andServiceName: (NSString *) serviceName
                         error: (NSError **) error;

//OAuth.
+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;

+ (NSString*)getValueForIdentifier:(NSString *)identifier;

+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier;


+ (BOOL)updateKeychainValue:(NSString *)refresh_token
              forIdentifier:(NSString *)identifier;

+ (void)deleteKeychainValue:(NSString *)identifier;

+ (BOOL)createKeychainValue:(NSString *)refresh_token
              forIdentifier:(NSString *)identifier;


/**
 * @name  getRefreshToken
 *
 * @author Vipindas Palli
 *
 * @brief Get refresh token from key chain store
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return refreshToken
 *
 */

+ (NSString*)getRefreshToken;

/**
 * @name  storeRefreshToken:
 *
 * @author Vipindas Palli
 *
 * @brief Store new refresh token value in key chain store
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  refreshToken new refresh token
 *
 * @return bool value
 *
 */

+ (BOOL)storeRefreshToken:(NSString *)refreshToken;

/**
 * @name  updatedRefreshToken:
 *
 * @author Vipindas Palli
 *
 * @brief update existing refresh token value in key chain store
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  refreshToken new refresh token
 *
 * @return bool value
 *
 */

+ (BOOL)updatedRefreshToken:(NSString *)refreshToken;

/**
 * @name  deleteRefreshToken
 *
 * @author Vipindas Palli
 *
 * @brief delete existing refresh token value in key chain store
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return bool value
 *
 */

+ (void)deleteRefreshToken;





@end
