//
//  SVMXLookupFilter.m
//  iService
//
//  Created by Shravya shridhar on 5/28/13.
//
//

#import "SVMXLookupFilter.h"

@implementation SVMXLookupFilter

@synthesize name;
@synthesize identifier;
@synthesize namedSearchId;
@synthesize ruleType;
@synthesize sourceObjectName;
@synthesize fieldName;
@synthesize parentObjectCriteria;
@synthesize sequence;
@synthesize description;
@synthesize advancedExpressions;
@synthesize componentArray;
@synthesize isDefaultOn;
@synthesize allowOverride;
@synthesize objectPermission;
@synthesize lookupContext;
@synthesize lookupQuery;
- (void)dealloc {
    [name release];
    [identifier release];
    [namedSearchId release];
    [ruleType release];
    [sourceObjectName release];
    [fieldName release];
    [description release];
    [parentObjectCriteria release];
    [advancedExpressions release];
    [componentArray release];
    [lookupContext release];
    [lookupQuery release];
    [super dealloc];
}

@end
