//
//  SMRestRequest.m
//  iService
//
//  Created by Vipindas on 11/16/13.
//
//

#import "SMRestRequest.h"

NSString * const kSFDefaultDataService   = @"/services/data";


@implementation SMRestRequest


@synthesize instanceUrlString;
@synthesize method;
@synthesize path;
@synthesize parameters;
@synthesize requestDelegate;
@synthesize parseResponse;
@synthesize shouldCancel;


- (id)initWithInstaceURLString:(NSString *)urlString
{
    self = [super init];
    if (self)
    {
        self.instanceUrlString = urlString;
        self.parseResponse = YES;
        self.shouldCancel  = NO;
    }
    return self;
}

- (id)initWithMethod:(id )methodName path:(NSString *)pathName andParameters:(NSDictionary *)parameterDict
{
    self = [super init];
    if (self)
    {
        self.method = methodName;
        self.path = pathName;
        self.parameters = parameterDict;
        self.shouldCancel  = NO;
    }
    return self;
}


- (id)initWithMethod:(id )methodName objectName:(NSString *)objectName andSfId:(NSString *)sfId
{
    self = [super init];
    if (self)
    {
        self.method = methodName;
        self.objectName = objectName;
        self.sfId = sfId;
        self.shouldCancel  = NO;
    }
    return self;
}



- (void)cancelRequest
{
    self.shouldCancel = YES;
}


- (void)dealloc
{
    [path release]; path = nil;
    [parameters release]; parameters = nil;
    
    [super dealloc];
}

@end
