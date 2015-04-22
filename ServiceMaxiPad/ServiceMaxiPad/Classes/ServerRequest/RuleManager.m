//
//  RuleManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/31/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "RuleManager.h"
#import "PlistManager.h"

NSString * const kFlowActionImmediate   = @"Immediate";
NSString * const kFlowActionNext        = @"Next";
NSString * const kFlowActionParallel    = @"Parallel";
NSString * const kFlowActionNotAllowed  = @"NotAllowed";


@interface RuleManager ()
{
    NSMutableDictionary *rulesCache;
}

@property (nonatomic, strong) NSMutableDictionary *rulesCache;

@end


@implementation RuleManager

@synthesize rulesCache;

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
    rulesCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    // ...
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


#pragma mark - Load/Reload Tags

- (void)loadRules
{
    self.rulesCache = [PlistManager getDefaultTags];
    
    if (self.rulesCache == nil)
    {
        self.rulesCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
}



#pragma mark - Get tags

- (NSDictionary *)rulesByName:(NSString *)name
{
    NSDictionary *rules = nil;
    
    if ( (self.rulesCache != nil) && ([self.rulesCache count] > 0) )
    {
        rules = [self.rulesCache objectForKey:name];
    }
    else
    {
        rules = [NSDictionary dictionary];
    }
    return rules;
}


- (NSString *)actionNameByPlacedFlowName:(NSString *)primeFlowName
                        withIncomingFlow:(NSString *)secondFlowName
{
    
    NSDictionary *nodeRuleBook = [self rulesByName:primeFlowName];
    
    NSString *actionName = kFlowActionNext;
    
    if ((nodeRuleBook != nil) && (secondFlowName != nil))
    {
        actionName = [nodeRuleBook  objectForKey:secondFlowName];
        
        if (actionName == nil)
        {
            actionName = kFlowActionNext;
        }
    }
 
    //return kFlowActionNext;
    return actionName;
}


@end
