// Copyright (c) 2010 Rick Fillion
// Code based on Chris Farber's CRServerSwitchboard
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.
//

#import "ZKServerSwitchboard.h"
#import "ZKServerSwitchboard+Private.h"
#import "ZKParser.h"
//#import "ZKEnvelope.h"
//#import "ZKPartnerEnvelope.h"
#import "ZKQueryResult.h"
#import "ZKSObject.h"
#import "ZKSoapException.h"
#import "ZKLoginResult.h"
#import "NSObject+Additions.h"
#import "ZKSaveResult.h"
#import "ZKGetDeletedResult.h"
#import "ZKGetUpdatedResult.h"
#import "NSDate+Additions.h"
#import "ZKMessageEnvelope.h"
#import "ZKMessageElement.h"
//#import "AppDelegate.h"
#import "CustomerOrgInfo.h"

@implementation NSString (Helper)
- (BOOL)Contains:(NSString *)string
{
    if(string != nil)
    {
        NSRange range = [self rangeOfString:string];
        if(!(NSEqualRanges(range, NSMakeRange(NSNotFound, 0))) )
        {
            return YES;
        }
    }
    return NO;
    
}
@end
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

static const int MAX_SESSION_AGE = 10 * 60; // 10 minutes.  15 minutes is the minimum length that you can set sessions to last to, so 10 should be safe.
static ZKServerSwitchboard * sharedSwitchboard =  nil;

@interface ZKServerSwitchboard (CoreWrappers)

- (ZKLoginResult *)_processLoginResponse:(ZKElement *)loginResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (ZKQueryResult *)_processQueryResponse:(ZKElement *)queryResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSArray *)_processSaveResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSArray *)_processDeleteResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (ZKGetDeletedResult *)_processGetDeletedResponse:(ZKElement *)getDeletedResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (ZKGetUpdatedResult *)_processGetUpdatedResponse:(ZKElement *)getUpdatedResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSArray *)_processSearchResponse:(ZKElement *)searchResponseElement error:(NSError *)error context:(NSDictionary *)context;
- (NSArray *)_processUnDeleteResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context;

@end

@implementation ZKServerSwitchboard
@synthesize sessionExpiry;
@synthesize apiUrl;
@synthesize clientId;
@synthesize sessionId;
@synthesize oAuthRefreshToken;
@synthesize userInfo;
@synthesize updatesMostRecentlyUsed;
@synthesize logXMLInOut;

#pragma mark Singleton Methods
+ (ZKServerSwitchboard *)switchboard {
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
    // ...
    connections = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                            &kCFTypeDictionaryValueCallBacks);
    connectionsData = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                                &kCFTypeDictionaryValueCallBacks);
    preferredApiVersion = 20;
    
    self.logXMLInOut = NO;

    return self;
}
- (void)dealloc
{
    CFRelease(connections);
    connections = NULL;
    CFRelease(connectionsData);
    connectionsData = NULL;
    
    // Properties
    apiUrl = nil;
    clientId = nil;
	sessionId = nil;
	sessionExpiry = nil;
    userInfo = nil;
    oAuthRefreshToken = nil;
    
    // Private vars
    _username = nil;
    _password = nil;
    
    if (_oAuthRefreshTimer)
    {
        [_oAuthRefreshTimer invalidate];
        _oAuthRefreshTimer = nil;
    }
}

#define kFirstTimeLogin     @"kFirstTimeLogin"

+ (NSString *)baseURL
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
	//Shrinivas : OAuth
	NSString *preference = [defaults valueForKey:@"preference_identifier"];
	
	
    NSString *groupIdentifier = [defaults objectForKey:kFirstTimeLogin];
    if (!groupIdentifier)
    {
        [defaults setValue:@"kFirstTimeLogin" forKey:kFirstTimeLogin];
    }
    else
    {
        SXLogWarning(@"Not a first time login.");
    }
    
    
    if ( [preference isEqualToString:@"Production"] )
    {
        
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		if (userDefaults)
		{
			[userDefaults setObject:preference forKey:@"loggedInOrg"];
		}
        return @"https://login.salesforce.com";
    }
    else if ([preference isEqualToString:@"Sandbox"] )
    {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		if (userDefaults)
		{
			[userDefaults setObject:preference forKey:@"loggedInOrg"];
		}
        return @"https://test.salesforce.com";
    }
	else
	{
		NSString *customURL = [defaults valueForKey:@"custom_url"];
			
		if ( [customURL Contains:@"http://"] || [customURL Contains:@"https://"] );
		//Its fine continue :
		else
			customURL = [NSString stringWithFormat:@"https://%@",customURL];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		
		if ( userDefaults )
		{
			[userDefaults setObject:@"CustomURL" forKey:@"loggedInOrg"];
		}
        return customURL;

	}
    /*
     
     Fixed Issue :023391
     
     HS 7Oct2016 Changed BaseURL from "www.salesforce.com" to "https://login.salesforce.com" as per Salesforce confirmation under below statement
     
     As of January 1, 2016, the internal routing will be retired, and any API endpoints will need to be changed if from www.salesforce.com to https://login.salesforce.com.
     
     */
    //return @"https://www.salesforce.com";
    return @"https://login.salesforce.com";

    
}

#pragma mark Properties

- (NSString *)apiUrl
{
    if (apiUrl)
        return apiUrl;
    return [self authenticationUrl];
}

- (void)setOAuthRefreshToken:(NSString *)refreshToken
{
    NSString *copy = [refreshToken copy];
    oAuthRefreshToken = copy;
    
    // Disable whatever timer existed before
    if (_oAuthRefreshTimer)
    {
        [_oAuthRefreshTimer invalidate];
        _oAuthRefreshTimer = nil;
    }
    if (oAuthRefreshToken)
    {
    // Reschedule a new timer
        _oAuthRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_SESSION_AGE target:self selector:@selector(_oauthRefreshAccessToken:) userInfo:nil repeats:YES];
    }
}

#pragma mark Methods

- (NSString *)authenticationUrl
{
    NSString *url = [NSString stringWithFormat:@"%@/services/Soap/u/%d.0", [[self class] baseURL] , (int)preferredApiVersion];
    return url;
}


- (void)setApiUrlFromOAuthInstanceUrl:(NSString *)instanceUrl
{
    self.apiUrl = [instanceUrl stringByAppendingFormat:@"/services/Soap/u/%d.0", (int)preferredApiVersion];
}

- (NSDictionary *)contextWrapperDictionaryForTarget:(id)target selector:(SEL)selector context:(id)context
{
    NSValue *selectorValue = [NSValue value: &selector withObjCType: @encode(SEL)];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            selectorValue, @"selector",
            target, @"target",
            context ? context: [NSNull null], @"context",
            nil];
}

- (void)unwrapContext:(NSDictionary *)wrapperContext andCallSelectorWithResponse:(id)response error:(NSError *)error
{
    SEL selector;
    [[wrapperContext valueForKey: @"selector"] getValue: &selector];
    id target = [wrapperContext valueForKey:@"target"];
    id context = [wrapperContext valueForKey:@"context"];
    if ([context isEqual:[NSNull null]])
        context = nil;
    
    [target performSelector:selector withObject:response withObject:error withObject: context];
}

- (NSURLConnection *)loginWithUsername:(NSString *)username password:(NSString *)password target:(id)target selector:(SEL)selector
{
    // Save Username and Password for session management stuff
    _username = username;
    _password = password;
    
    // Reset session management stuff
	sessionExpiry = [NSDate dateWithTimeIntervalSinceNow:MAX_SESSION_AGE];
    
    ZKMessageEnvelope *envelop = [ZKMessageEnvelope envelopeWithSessionId:nil clientId:clientId];
    ZKMessageElement *loginElement = [ZKMessageElement elementWithName:@"login" value:nil];
    [loginElement addChildElement:[ZKMessageElement elementWithName:@"username" value:username]];
    [loginElement addChildElement:[ZKMessageElement elementWithName:@"password" value:password]];
    [envelop addBodyElement:loginElement];
    NSString *alternativeXML = [envelop stringRepresentation];    
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:nil];
    return [self _sendRequestWithData:alternativeXML target:self selector:@selector(_processLoginResponse:error:context:) context: wrapperContext];
}

- (NSURLConnection *)create:(NSArray *)objects target:(id)target selector:(SEL)selector context:(id)context
{
	//OAuth
    ZKMessageEnvelope *envelope = [ZKMessageEnvelope envelopeWithSessionId:[[CustomerOrgInfo sharedInstance] accessToken] clientId:clientId];
    if (self.updatesMostRecentlyUsed)
        [envelope addUpdatesMostRecentlyUsedHeader];
    [envelope addBodyElementNamed:@"create" withChildNamed:@"sobject" value:objects];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    return [self _sendRequestWithData:xml target:self selector:@selector(_processSaveResponse:error:context:) context: wrapperContext];
}

- (NSURLConnection *)delete:(NSArray *)objectIDs target:(id)target selector:(SEL)selector context:(id)context
{
	//OAuth
    ZKMessageEnvelope *envelope = [ZKMessageEnvelope envelopeWithSessionId:[[CustomerOrgInfo sharedInstance] accessToken] clientId:clientId];
    if (self.updatesMostRecentlyUsed)
        [envelope addUpdatesMostRecentlyUsedHeader];
    [envelope addBodyElementNamed:@"delete" withChildNamed:@"ids" value:objectIDs];
    NSString *xml = [envelope stringRepresentation]; 
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    return [self _sendRequestWithData:xml target:self selector:@selector(_processDeleteResponse:error:context:) context: wrapperContext];
}

- (void)getDeleted:(NSString *)sObjectType fromDate:(NSDate *)startDate toDate:(NSDate *)endDate target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    if (!startDate)
        startDate = [NSDate dateWithTimeIntervalSinceNow: - (29 * 60 * 60 * 24)];
    if (!endDate)
        endDate = [NSDate date];
    
    ZKMessageEnvelope *envelope = [ZKMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    if (self.updatesMostRecentlyUsed)
        [envelope addUpdatesMostRecentlyUsedHeader];
    ZKMessageElement *getDeletedElement = [ZKMessageElement elementWithName:@"getDeleted" value:nil];
    [getDeletedElement addChildElement:[ZKMessageElement elementWithName:@"sObjectType" value:sObjectType]];
    [getDeletedElement addChildElement:[ZKMessageElement elementWithName:@"startDate" value:[startDate longFormatString]]];
    [getDeletedElement addChildElement:[ZKMessageElement elementWithName:@"endDate" value:[endDate longFormatString]]];
    [envelope addBodyElement:getDeletedElement];
    NSString *xml = [envelope stringRepresentation]; 
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processGetDeletedResponse:error:context:) context: wrapperContext];
}

- (void)getUpdated:(NSString *)sObjectType fromDate:(NSDate *)startDate toDate:(NSDate *)endDate target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    if (!startDate)
        startDate = [NSDate dateWithTimeIntervalSinceNow: - (29 * 60 * 60 * 24)];
    if (!endDate)
        endDate = [NSDate date];
    
    ZKMessageEnvelope *envelope = [ZKMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    ZKMessageElement *getUpdatedElement = [ZKMessageElement elementWithName:@"getUpdated" value:nil];
    [getUpdatedElement addChildElement:[ZKMessageElement elementWithName:@"sObjectType" value:sObjectType]];
    [getUpdatedElement addChildElement:[ZKMessageElement elementWithName:@"startDate" value:[startDate longFormatString]]];
    [getUpdatedElement addChildElement:[ZKMessageElement elementWithName:@"endDate" value:[endDate longFormatString]]];
    [envelope addBodyElement:getUpdatedElement];
    NSString *xml = [envelope stringRepresentation]; 
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processGetUpdatedResponse:error:context:) context: wrapperContext];
}

- (NSURLConnection *)query:(NSString *)soqlQuery target:(id)target selector:(SEL)selector context:(id)context
{
    //[self _checkSession];
    
	//OAuth
    ZKMessageEnvelope *envelope = [ZKMessageEnvelope envelopeWithSessionId:[[CustomerOrgInfo sharedInstance] accessToken] clientId:clientId];
    [envelope addBodyElementNamed:@"query" withChildNamed:@"queryString" value:soqlQuery];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    return [self _sendRequestWithData:xml target:self selector:@selector(_processQueryResponse:error:context:) context: wrapperContext];
}

- (void)queryAll:(NSString *)soqlQuery target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    ZKMessageEnvelope *envelope = [ZKMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"queryAll" withChildNamed:@"queryString" value:soqlQuery];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processQueryResponse:error:context:) context: wrapperContext];
}

- (void)queryMore:(NSString *)queryLocator target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    ZKMessageEnvelope *envelope = [ZKMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"queryMore" withChildNamed:@"queryLocator" value:queryLocator];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processQueryResponse:error:context:) context: wrapperContext];
}

- (void)search:(NSString *)soslQuery target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    ZKMessageEnvelope *envelope = [ZKMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    [envelope addBodyElementNamed:@"search" withChildNamed:@"searchString" value:soslQuery];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processSearchResponse:error:context:) context: wrapperContext];
}

- (void)unDelete:(NSArray *)objectIDs target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    ZKMessageEnvelope *envelope = [ZKMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    if (self.updatesMostRecentlyUsed)
        [envelope addUpdatesMostRecentlyUsedHeader];
    [envelope addBodyElementNamed:@"undelete" withChildNamed:@"ids" value:objectIDs];
    NSString *xml = [envelope stringRepresentation]; 
	
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    [self _sendRequestWithData:xml target:self selector:@selector(_processUnDeleteResponse:error:context:) context: wrapperContext];
}

- (NSURLConnection *)update:(NSArray *)objects target:(id)target selector:(SEL)selector context:(id)context
{
    [self _checkSession];
    
    ZKMessageEnvelope *envelope = [ZKMessageEnvelope envelopeWithSessionId:sessionId clientId:clientId];
    if (self.updatesMostRecentlyUsed)
        [envelope addUpdatesMostRecentlyUsedHeader];
    [envelope addBodyElementNamed:@"update" withChildNamed:@"sobject" value:objects];
    NSString *xml = [envelope stringRepresentation]; 
    
    NSDictionary *wrapperContext = [self contextWrapperDictionaryForTarget:target selector:selector context:context];
    return [self _sendRequestWithData:xml target:self selector:@selector(_processSaveResponse:error:context:) context: wrapperContext];
}


#pragma mark -
#pragma mark Apex Calls

- (void)sendApexRequestToURL:(NSString *)webServiceLocation
                    withData:(NSString *)payload
                      target:(id)target
                    selector:(SEL)sel
                     context:(id)context
{
    // The method is equivalent to ZKServerSwitchboard+Private's _sendRequestWithData:target:selector:context
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:webServiceLocation]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"content-type"];	
	[request addValue:@"\"\"" forHTTPHeaderField:@"SOAPAction"];
    //undochangespushpak
	//
    //SMLog(kLogLevelVerbose,@"request = %@", request);
	NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:data];
    
	if(self.logXMLInOut) {
        //undochangespushpak
        //
		//SMLog(kLogLevelVerbose,@"OutputHeaders:\n%@", [request allHTTPHeaderFields]);
		//SMLog(kLogLevelVerbose,@"OutputBody:\n%@", payload);
	}
    
    [self _sendRequest:request target:target selector:sel context:context];
}


@end

@implementation ZKServerSwitchboard (CoreWrappers)

- (ZKLoginResult *)_processLoginResponse:(ZKElement *)loginResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    ZKLoginResult *loginResult = nil;
    if (!error)
    {
        ZKElement *result = [[loginResponseElement childElements:@"result"] objectAtIndex:0];
        loginResult = [[ZKLoginResult alloc] initWithXmlElement:result];
        self.apiUrl = [loginResult serverUrl];
        self.sessionId = [loginResult sessionId];
        self.userInfo = [loginResult userInfo];
    }

    [self unwrapContext:context andCallSelectorWithResponse:loginResult error:error];
    return loginResult;
}

- (ZKQueryResult *)_processQueryResponse:(ZKElement *)queryResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    ZKQueryResult *result = nil;
    if (!error)
    {
        result = [[ZKQueryResult alloc] initFromXmlNode:[[queryResponseElement childElements] objectAtIndex:0]];
    }
    [self unwrapContext:context andCallSelectorWithResponse:result error:error];
    return result;
}

- (NSArray *)_processSaveResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context
{
	NSArray *resultsArr = [saveResponseElement childElements:@"result"];
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:[resultsArr count]];
	
	for (ZKElement *result in resultsArr) {
		ZKSaveResult * saveResult = [[ZKSaveResult alloc] initWithXmlElement:result];
		[results addObject:saveResult];
	}
    [self unwrapContext:context andCallSelectorWithResponse:results error:error];
    return results;
}

- (NSArray *)_processDeleteResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    NSArray *resArr = [saveResponseElement childElements:@"result"];
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:[resArr count]];
	for (ZKElement *saveResultElement in resArr) {
		ZKSaveResult *sr = [[ZKSaveResult alloc] initWithXmlElement:saveResultElement];
		[results addObject:sr];
	} 
    [self unwrapContext:context andCallSelectorWithResponse:results error:error];
	return results;
}

- (NSArray *)_processSearchResponse:(ZKElement *)searchResponseElement error:(NSError *)error context:(NSDictionary *)context;
{
    ZKElement *searchResult = [searchResponseElement childElement:@"result"];
	NSArray *records = [[searchResult childElement:@"searchRecords"] childElements:@"record"];
	NSMutableArray *results = [NSMutableArray array];
	for (ZKElement *soNode in records) {
		[results addObject:[ZKSObject fromXmlNode:soNode]];
	}
    [self unwrapContext:context andCallSelectorWithResponse:results error:error];
	return results;
}

- (ZKGetDeletedResult *)_processGetDeletedResponse:(ZKElement *)getDeletedResponseElement error:(NSError *)error context:(NSDictionary *)context;
{
    ZKGetDeletedResult *result = nil;
    if (!error)
    {
        result = [[ZKGetDeletedResult alloc] initFromXmlNode:[[getDeletedResponseElement childElements] objectAtIndex:0]];
    }
    [self unwrapContext:context andCallSelectorWithResponse:result error:error];
    return result;
}

- (ZKGetUpdatedResult *)_processGetUpdatedResponse:(ZKElement *)getUpdatedResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    ZKGetUpdatedResult *result = nil;
    if (!error)
    {
        result = [[ZKGetUpdatedResult alloc] initFromXmlNode:[[getUpdatedResponseElement childElements] objectAtIndex:0]];
    }
    [self unwrapContext:context andCallSelectorWithResponse:result error:error];
    return result;
}

- (NSArray *)_processUnDeleteResponse:(ZKElement *)saveResponseElement error:(NSError *)error context:(NSDictionary *)context
{
    return [self _processDeleteResponse:saveResponseElement error:error context:context];
}

@end
