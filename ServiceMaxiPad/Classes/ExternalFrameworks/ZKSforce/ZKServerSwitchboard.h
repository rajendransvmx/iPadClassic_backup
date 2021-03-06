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

#import <Foundation/Foundation.h>

@class ZKUserInfo;

@interface ZKServerSwitchboard : NSObject {
    CFMutableDictionaryRef connections;
    CFMutableDictionaryRef connectionsData;
    
    NSString    *apiUrl;
    
	NSString	*clientId;	
	NSString	*sessionId;
    NSString    *oAuthRefreshToken;
	NSDate		*sessionExpiry;
    ZKUserInfo	*userInfo;
	NSUInteger  preferredApiVersion;
    
    BOOL        updatesMostRecentlyUsed;
    BOOL        logXMLInOut;

@private
    NSString    *_username;
    NSString    *_password;

    NSTimer     *_oAuthRefreshTimer;
}

@property (nonatomic, copy) NSString *apiUrl;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, strong) NSDate *sessionExpiry;
@property (nonatomic, copy) NSString *oAuthRefreshToken;
@property (nonatomic, strong) ZKUserInfo *userInfo;
@property (nonatomic, assign) BOOL updatesMostRecentlyUsed;
@property (nonatomic, assign) BOOL logXMLInOut;

+ (NSString *)baseURL;

+ (ZKServerSwitchboard *)switchboard;
+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));





- (NSString *)authenticationUrl;

- (void)setApiUrlFromOAuthInstanceUrl:(NSString *)instanceUrl;
- (NSURLConnection *)loginWithUsername:(NSString *)username password:(NSString *)password target:(id)target selector:(SEL)selector;

// Convenience methods that should only really be called from within ZKServerSwitchboard methods
// They're public because categories on ZKServerSwitchboard might need access to them
- (NSDictionary *)contextWrapperDictionaryForTarget:(id)target selector:(SEL)selector context:(id)context;
- (void)unwrapContext:(NSDictionary *)wrapperContext andCallSelectorWithResponse:(id)response error:(NSError *)error;


// Core Calls
- (NSURLConnection *)create:(NSArray *)objects target:(id)target selector:(SEL)selector context:(id)context;
- (NSURLConnection *)delete:(NSArray *)objectIDs target:(id)target selector:(SEL)selector context:(id)context;
- (void)getDeleted:(NSString *)sObjectType fromDate:(NSDate *)startDate toDate:(NSDate *)endDate target:(id)target selector:(SEL)selector context:(id)context;
- (void)getUpdated:(NSString *)sObjectType fromDate:(NSDate *)startDate toDate:(NSDate *)endDate target:(id)target selector:(SEL)selector context:(id)context;
- (NSURLConnection *)query:(NSString *)soqlQuery target:(id)target selector:(SEL)selector context:(id)context;
- (void)queryAll:(NSString *)soqlQuery target:(id)target selector:(SEL)selector context:(id)context;
- (void)queryMore:(NSString *)queryLocator target:(id)target selector:(SEL)selector context:(id)context;
- (void)search:(NSString *)soqlQuery target:(id)target selector:(SEL)selector context:(id)context;
- (void)unDelete:(NSArray *)objectIDs target:(id)target selector:(SEL)selector context:(id)context;
- (NSURLConnection *)update:(NSArray *)objects target:(id)target selector:(SEL)selector context:(id)context;

// Apex Calls
- (void)sendApexRequestToURL:(NSString *)webServiceLocation
                    withData:(NSString *)payload
                      target:(id)target
                    selector:(SEL)sel
                     context:(id)context;

@end
