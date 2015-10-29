//
//  SFMLookUpFilter.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 01/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMLookUpFilter.h"

#define kEncodeKeysearchId   @"searchId"
#define kEncodeKeysourceObjectName     @"sourceObjectName"
#define kEncodeKeysearchFieldName     @"searchFieldName"
#define kEncodeKeyadvanceExpression    @"advanceExpression"
#define kEncodeKeyruleType     @"ruleType"
#define kEncodeKeyname    @"name"
#define kEncodeKeynameSearchID    @"nameSearchID"
#define kEncodeKeyallowOverride     @"allowOverride"
#define kEncodeKeydefaultOn     @"defaultOn"
#define kEncodeKeyobjectPermission     @"objectPermission"
#define kEncodeKeylookupContext      @"lookupContext"
#define kEncodeKeylookContextDisplayValue      @"lookContextDisplayValue"
#define kEncodeKeylookupContextParentObject      @"lookupContextParentObject"
#define kEncodeKeylookupQuery      @"lookupQuery"

@implementation SFMLookUpFilter

//Enabling Copying of Custom object
#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.searchId   forKey:kEncodeKeysearchId];
    [aCoder encodeObject:self.sourceObjectName   forKey:kEncodeKeysourceObjectName];
    [aCoder encodeObject:self.searchFieldName   forKey:kEncodeKeysearchFieldName];
    [aCoder encodeObject:self.advanceExpression   forKey:kEncodeKeyadvanceExpression];
    [aCoder encodeObject:self.ruleType   forKey:kEncodeKeyruleType];
    [aCoder encodeObject:self.name   forKey:kEncodeKeyname];
    [aCoder encodeObject:self.nameSearchID   forKey:kEncodeKeynameSearchID];
    [aCoder encodeBool:self.allowOverride   forKey:kEncodeKeyallowOverride];
    [aCoder encodeBool:self.defaultOn   forKey:kEncodeKeydefaultOn];
    [aCoder encodeBool:self.objectPermission   forKey:kEncodeKeyobjectPermission];
    [aCoder encodeObject:self.lookupContext   forKey:kEncodeKeylookupContext];
    [aCoder encodeObject:self.lookContextDisplayValue   forKey:kEncodeKeylookContextDisplayValue];
    [aCoder encodeObject:self.lookupContextParentObject   forKey:kEncodeKeylookupContextParentObject];
    [aCoder encodeObject:self.lookupQuery   forKey:kEncodeKeylookupQuery];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init]))
    {
        self.searchId = [aDecoder decodeObjectForKey:kEncodeKeysearchId];
        self.sourceObjectName = [aDecoder decodeObjectForKey:kEncodeKeysourceObjectName];
        self.searchFieldName = [aDecoder decodeObjectForKey:kEncodeKeysearchFieldName];
        self.advanceExpression = [aDecoder decodeObjectForKey:kEncodeKeyadvanceExpression];
        self.ruleType = [aDecoder decodeObjectForKey:kEncodeKeyruleType];
        self.name = [aDecoder decodeObjectForKey:kEncodeKeyname];
        self.nameSearchID = [aDecoder decodeObjectForKey:kEncodeKeynameSearchID];
        self.allowOverride = [aDecoder decodeBoolForKey:kEncodeKeyallowOverride];
        self.defaultOn = [aDecoder decodeBoolForKey:kEncodeKeydefaultOn];
        self.objectPermission = [aDecoder decodeBoolForKey:kEncodeKeyobjectPermission];
        self.lookupContext = [aDecoder decodeObjectForKey:kEncodeKeylookupContext];
        self.lookContextDisplayValue = [aDecoder decodeObjectForKey:kEncodeKeylookContextDisplayValue];
        self.lookupContextParentObject = [aDecoder decodeObjectForKey:kEncodeKeylookupContextParentObject];
        self.lookupQuery = [aDecoder decodeObjectForKey:kEncodeKeylookupQuery];

    }
    return self;
}
@end
