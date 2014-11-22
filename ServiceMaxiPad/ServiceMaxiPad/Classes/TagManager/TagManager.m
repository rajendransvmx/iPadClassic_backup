//
//  TagManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 3/26/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

/**
 *  @file   TagManager.m
 *  @class  TagManager
 *
 *  @brief  This class manage tags which used across the application
 *
 *
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "TagManager.h"
#import "PlistManager.h"
#import "MobileDeviceTagDAO.h"
#import "FactoryDAO.h"
#import "MobileDeviceTagModel.h"

@interface TagManager ()
{
   NSMutableDictionary *tagsCache;
}

@property (nonatomic, strong) NSMutableDictionary *tagsCache;

@end


@implementation TagManager

@synthesize tagsCache;

#pragma mark Singleton Methods

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    tagsCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    // ...
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


#pragma mark - Load/Reload Tags

/**
 * @name   loadTags
 *
 * @author Vipindas Palli
 *
 * @brief  Load tags from Plist manager
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)loadTags
{
    if (self.tagsCache != nil)
    {
        self.tagsCache = nil;
    }
    
    self.tagsCache = [PlistManager getDefaultTags];
    
    if (self.tagsCache == nil)
    {
        self.tagsCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
}


/**
 * @name   reloadTags
 *
 * @author Vipindas Palli
 * @author Pushpak
 *
 * @brief  Load tags to tagcache
 *
 * \par
 *  Method first loads tags from plist and merge tags fetched from database.
 *
 * @return void
 *
 */

- (void)reloadTags
{
    [self loadTags];
    NSArray *tagsFromDB = nil;
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceTag];
    
    if ([daoService conformsToProtocol:@protocol(MobileDeviceTagDAO)]) {
        tagsFromDB = [daoService fetchAllTagsWithError:NULL];
    }
    
    if (tagsFromDB) {
        for (MobileDeviceTagModel *temp in tagsFromDB) {
            [self.tagsCache setObject:temp.value forKey:temp.tagId];
        }
    }
}

#pragma mark - Get tags

- (NSString *)tagByName:(NSString *)tagNameOrCode
{
    NSString *tagValue = nil;

    if ( (self.tagsCache != nil) && ([self.tagsCache count] > 0) )
    {
        tagValue = [self.tagsCache objectForKey:tagNameOrCode];
    }
    
    return tagValue;
}

@end
