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

#import "ZKServerSwitchboard+Private.h"
#import "ZKParser.h"
#import "ZKSoapException.h"
#import "NSObject+Additions.h"
#import "NSURL+Additions.h"
//#import "AppDelegate.h"
#import "CustomerOrgInfo.h"
#import "Utility.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

static NSString *SOAP_NS = @"http://schemas.xmlsoap.org/soap/envelope/";

@implementation ZKServerSwitchboard (Private)

- (void)_sendRequestWithData:(NSString *)payload
                      target:(id)target
                    selector:(SEL)sel
{
    [self _sendRequestWithData:payload
                        target:target
                      selector:sel
                       context:nil];
}

- (NSURLConnection *)_sendRequestWithData:(NSString *)payload
                      target:(id)target
                    selector:(SEL)sel
                     context:(id)context
{
    
    CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[customerOrgInfoInstance apiURL]]]; //Shrinivas : OAuth
    [request setHTTPMethod:@"POST"];
    [request addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"content-type"];
    [request addValue:@"\"\"" forHTTPHeaderField:@"SOAPAction"];
    NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    request.timeoutInterval = [Utility requestTimeOutValueFromSetting];
    
    SXLogDebug(@"OPD: SET timeout: %f", request.timeoutInterval);
    
    if(self.logXMLInOut) {
        //undochangespushpak
        //
        //SMLog(kLogLevelVerbose,@"OutputHeaders:\n%@", [request allHTTPHeaderFields]);
        //SMLog(kLogLevelVerbose,@"OutputBody:\n%@", payload);
    }
    
    return [self _sendRequest:request target:target selector:sel context:context];
}

- (NSURLConnection *)_sendRequest:(NSURLRequest *)aRequest
              target:(id)target
            selector:(SEL)sel
             context:(id)context
{
    NSURL *requestURL = [aRequest URL];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:aRequest delegate:self];
    if (!connection)
    {
        NSError *error = [NSError errorWithDomain:@"ZKSwitchboardError"
                                             code:1
                                         userInfo:nil];
		[target performSelector: sel withObject: nil withObject: error withObject: context];
        return nil;
    }
    
    CFDictionarySetValue(connectionsData, (__bridge const void *)(connection), (__bridge const void *)([NSMutableData data]));
    
    NSValue *selector = [NSValue value: &sel withObjCType: @encode(SEL)];
    NSMutableDictionary *targetInfo =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     selector, @"selector",
     target, @"target",
     context ? context: [NSNull null], @"context",
     nil];
    
    if (requestURL)
    {
        [targetInfo setObject:requestURL forKey:@"requestURL"];
    }
    
    CFDictionarySetValue(connections, (__bridge const void *)(connection), (__bridge const void *)(targetInfo));
    
    return connection;
}

- (void) connection: (NSURLConnection *)connection didReceiveResponse: (NSHTTPURLResponse *)response
{
    NSMutableDictionary * targetInfo = (id)CFDictionaryGetValue(connections, (__bridge const void *)(connection));
    
    if(self.logXMLInOut) 
    {
        //undochangespushpak
        //
        //SMLog(kLogLevelVerbose,@"ResponseStatus: %u\n", [response statusCode]);
		//SMLog(kLogLevelVerbose,@"ResponseHeaders:\n%@", [response allHeaderFields]);
	}
    
    [targetInfo setValue: response forKey: @"response"];
}

- (void) connection: (NSURLConnection *)connection didReceiveData: (NSData *)data
{
    NSMutableData * connectionData = (id)CFDictionaryGetValue(connectionsData, (__bridge const void *)(connection));
    [connectionData appendData: data];
}

- (void) connection: (NSURLConnection *)connection didFailWithError: (NSError *)error
{
	if (self.logXMLInOut) {
        
//        if ([self respondsToSelector:@selector(internetConnectionFailed)])
//            [self performSelector:@selector(internetConnectionFailed)];
	}
    
    NSMutableDictionary * targetInfo = (id)CFDictionaryGetValue(connections, (__bridge const void *)(connection));
    [targetInfo setValue: error forKey: @"error"];
    [self _returnResponseForConnection: connection];
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection
{
    NSMutableDictionary *targetInfo =
    (id)CFDictionaryGetValue(connections, (__bridge const void *)(connection));
    
    // Determine what type of request is being dealt with
    NSURL *requestURL = nil;
    id object = [targetInfo objectForKey:@"requestURL"];
    if (object != nil && [object isKindOfClass:[NSURL class]])
    {
        requestURL = (NSURL *)object;
    }
    
    
    [self _returnResponseForConnection: connection];
}



- (void) _returnResponseForConnection: (NSURLConnection *)connection {
	NSMutableDictionary * targetInfo = (id)CFDictionaryGetValue(connections, (__bridge const void *)(connection));
	NSMutableData * data = (id)CFDictionaryGetValue(connectionsData, (__bridge const void *)(connection));
	
	if (self.logXMLInOut) {
        //undochangespushpak
        //
		//SMLog(kLogLevelVerbose,@"ResponseBody:\n%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	}
	
	id target = [targetInfo valueForKey: @"target"];
	SEL selector;
	[[targetInfo valueForKey: @"selector"] getValue: &selector];
    
	NSError *error = nil;
	NSHTTPURLResponse * response = nil;
	id errorObject = [targetInfo valueForKey: @"error"];
	if (errorObject != [NSNull null] && [errorObject isKindOfClass:[NSError class]])
	{
		response = [targetInfo valueForKey: @"response"];
		NSInteger status = [response statusCode];
        if (status != 200) error = (NSError *)errorObject;//[NSError errorWithDomain: @"APIError" code: status userInfo: nil]; //Replacing custom error message with actual error
	}
    
	ZKElement *responseElement = nil;
	if ([data length] && [error code] != 401) {
		@try {
			responseElement = [self _processHttpResponse:response data:data];
		} @catch (NSException *exception) {
			error = [NSError errorWithDomain: @"XMLError" code: 199 userInfo: [NSDictionary dictionaryWithObject: exception forKey: @"exception"]];
		}
	}
	
    // In this case, a valid status code is returned meaning that the request was
    // received and processed.  But, the result of the processing may be a SOAP
    // Fault as defined by the service.  So we need to check every call to make sure
    // that a fault wasn't returned, and if one was, to throw the error passing the 
    // fault code and fault string
    // Checking for SOAP Fault here now?
	if ([responseElement childElement:@"faultcode"] != nil) {
		NSDictionary *errorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[[responseElement childElement:@"faultcode"] stringValue],@"faultcode", [[responseElement childElement:@"faultstring"] stringValue], @"faultstring",[[responseElement childElement:@"faultstring"] stringValue] ,@"errorCode",nil];
		error = [NSError errorWithDomain:@"APIError" code:0 userInfo:errorDictionary];
	}
	
	id context = [targetInfo valueForKey:@"context"];
	if ([context isEqual: [NSNull null]])
		context = nil;
	
	[target performSelector:selector withObject:responseElement withObject:error withObject:context];
    
	CFDictionaryRemoveValue(connections, (__bridge const void *)(connection));
	CFDictionaryRemoveValue(connectionsData, (__bridge const void *)(connection));
}

- (void)_checkSession
{
    if ([sessionExpiry timeIntervalSinceNow] < 0)
		[self loginWithUsername:_username password:_password target:self selector:@selector(_sessionResumed:error:)];
}

- (void)_sessionResumed:(ZKLoginResult *)loginResult error:(NSError *)error
{
    if (error)
    {
        //undochangespushpak
        //
        //SMLog(kLogLevelError,@"There was an error resuming the session: %@", error);
    }
    else {
        //undochangespushpak
        //
        //SMLog(kLogLevelVerbose,@"Session Resumed Successfully!");
    }
    
}

- (void)_oauthRefreshAccessToken:(NSTimer *)timer
{
    if (!clientId)
    {
        //undochangespushpak
        //
        //SMLog(kLogLevelError,@"can't refresh OAuth Access Token without a client id set");
        return;
    }
    if (!oAuthRefreshToken)
    {
        //undochangespushpak
        //
        //SMLog(kLogLevelError,@"can't refresh OAuth Access Token without oAuthRefreshToken set");
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://login.salesforce.com/services/oauth2/token"]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];	
    
    NSString *bodyString = [NSString stringWithFormat:@"grant_type=refresh_token&client_id=%@&refresh_token=%@&format=urlencoded", clientId, oAuthRefreshToken];
    
	NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:data];
    
    NSURLResponse *response = nil;
    NSData *refreshResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *refreshResponseString = [[NSString alloc] initWithData:refreshResponseData encoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://login.salesforce.com/?%@", refreshResponseString]];
    NSString *newAccessToken = [url parameterWithName:@"access_token"];
    if (newAccessToken)
    {
        self.sessionId = newAccessToken;
    }
}


-(ZKElement *)_processHttpResponse:(NSHTTPURLResponse *)resp data:(NSData *)responseData
{
	ZKElement *root = [ZKParser parseData:responseData];
	if (root == nil)	
		@throw [NSException exceptionWithName:@"Xml error" reason:@"Unable to parse XML returned by server" userInfo:nil];
	if (![[root name] isEqualToString:@"Envelope"])
		@throw [NSException exceptionWithName:@"Xml error" reason:[NSString stringWithFormat:@"response XML not valid SOAP, root element should be Envelope, but was %@", [root name]] userInfo:nil];
	if (![[root namespace] isEqualToString:SOAP_NS])
		@throw [NSException exceptionWithName:@"Xml error" reason:[NSString stringWithFormat:@"response XML not valid SOAP, root namespace should be %@ but was %@", SOAP_NS, [root namespace]] userInfo:nil];
	ZKElement *body = [root childElement:@"Body" ns:SOAP_NS];
	if (resp.statusCode == 500) 
    {
		// I don't believe this will work.  With our API we occaisionally return
		// a 500, but not for operational errors such as bad username/password.  The 
		// body of the response is generally a web page (HTML) not soap
		ZKElement *fault = [body childElement:@"Fault" ns:SOAP_NS];
		if (fault == nil)
			@throw [NSException exceptionWithName:@"Xml error" reason:@"Fault status code returned, but unable to find soap:Fault element" userInfo:nil];
		NSString *fc = [[fault childElement:@"faultcode"] stringValue];
		NSString *fm = [[fault childElement:@"faultstring"] stringValue];
		@throw [ZKSoapException exceptionWithFaultCode:fc faultString:fm];
	} 
    
	return [[body childElements] objectAtIndex:0];
}





@end
