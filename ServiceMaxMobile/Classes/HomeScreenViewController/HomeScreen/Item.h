//
//  Item.h
//  iServiceHomeScreen
//
//  Created by Aparna on 09/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//

/**
 *  @file   Item.h
 *  @class  Item
 *
 *  @brief  This will store home view menu item details.
 *
 *
 *  This contains the prototypes for the console
 *  driver and eventually any macros, constants,
 *  or global variables you will need.
 *
 *  @author  Aparna
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>

/**
 *  MenuItemType
 *
 *  Enum represetation of Home screen menu item
 *
 */


typedef enum MenuItemType : NSUInteger
{
    MenuItemTypeCalendar = 1,
    MenuItemTypeCreateNew = 2,
    MenuItemTypeHelp = 3,
    MenuItemTypeLogout = 4,
    MenuItemTypeMap = 5,
    MenuItemTypeRecents = 6,
    MenuItemTypeSearch = 7,
    MenuItemTypeSync = 8,
    MenuItemTypeTasks = 9,
}
MenuItemType;


@interface Item : NSObject

@property(nonatomic) MenuItemType itemType;

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *detailedDescription;
@property(nonatomic, strong) UIImage  *icon;
@property(nonatomic, strong) NSString *accessibilityIdentifier;


- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
               icon:(UIImage *)icon;

/**
 * @name  initWithMenuItemType
 *
 * @author Vipindas Palli
 *
 * @brief Constructor method will recieve type of the menu item and return Object
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return Item object
 *
 */

- (id)initWithMenuItemType:(MenuItemType)type;

/**
 * @name  reloadItem
 *
 * @author Vipindas Palli
 *
 * @brief Reload details of menu item
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */
- (void)reloadItem;

@end
