//
//  TagManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 3/26/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

#import "TagManager.h"
#import "PlistManager.h"

static dispatch_once_t _sharedTagManagerInstanceGuard;
static TagManager *_instance;

@interface TagManager ()
{
   NSMutableDictionary *tagsCache;
}

@property (nonatomic, strong) NSMutableDictionary *tagsCache;

@end


@implementation TagManager

@synthesize tagsCache;

#pragma mark - Singleton class Implementation

- (id)init
{
    return [TagManager sharedInstance];
}


- (id)initializeTagManager
{
    self = [super init];
    
    if (self)
    {
        tagsCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}


+ (TagManager *)sharedInstance
{
    dispatch_once(&_sharedTagManagerInstanceGuard,
                  ^{
                      _instance = [[TagManager alloc] initializeTagManager];
                  });
    return _instance;
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)retain
{
    return self;
}


- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    // never release
}


- (id)autorelease
{
    return self;
}


#pragma mark - Load/Reload Tags

- (void)loadTags
{
    self.tagsCache = [PlistManager getDefaultTags];
    
    if (self.tagsCache == nil)
    {
        self.tagsCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
}


- (void)reloadTags
{
    /* TODO :- Vipin  Complete implementation */
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
