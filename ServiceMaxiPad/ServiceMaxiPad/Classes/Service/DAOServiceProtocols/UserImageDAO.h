//
//  UserImageDAO.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/26/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   UserImageDAO.h
 *  @class  UserImageDAO
 *
 *  @brief  Function prototypes for the console driver.
 *
 *
 *  This DAO class contains the service methods related to UserImage services
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>

@class UserImageModel;

@protocol UserImageDAO <NSObject>

/**
 * @name  - (BOOL)addUserImage:(UserImageModel *)userImage
 *
 * @author Vipindas Palli
 *
 * @brief Store new user Image
 *
 *
 *
 * @param  userImage Object of UserImageModel class
 *
 * @return bool 'Yes' incase of success , otherwise NO.
 *
 */
- (BOOL)addUserImage:(UserImageModel *)userImage;

/**
 * @name  - (BOOL)updateUserImage:(UserImageModel *)userImage
 *
 * @author Vipindas Palli
 *
 * @brief update existing user image
 *
 *
 *
 * @param  userImage Object of UserImageModel class
 *
 * @return bool 'Yes' incase of success , otherwise NO.
 *
 */

- (BOOL)updateUserImage:(UserImageModel *)userImage;

/**
 * @name  - (BOOL)removeUserImage:(UserImageModel *)userImage
 *
 * @author Vipindas Palli
 *
 * @brief Remove user image from storage
 *
 *
 *
 * @param  userImage Object of UserImageModel class
 *
 * @return bool 'Yes' incase of success , otherwise NO.
 *
 */

- (BOOL)removeUserImage:(UserImageModel *)userImage;

/**
 * @name  - (NSArray *)fetchAllUserImage
 *
 * @author Vipindas Palli
 *
 * @brief fetch all user image from storage
 *
 *
 *
 *
 * @return NSArray return collection of UserImageModel object in case of success other wise nil.
 *
 */

- (NSArray *)fetchAllUserImage;

@end