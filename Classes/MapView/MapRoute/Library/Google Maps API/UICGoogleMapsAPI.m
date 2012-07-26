//
//  UICGoogleMapsAPI.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGoogleMapsAPI.h"
#import "JSON.h"
#import "GTMStringEncoding.h" //Siva Manne
#import <CommonCrypto/CommonDigest.h> //Siva Manne
#import <CommonCrypto/CommonHMAC.h> //Siva Manne

@interface UIWebView(JavaScriptEvaluator)
- (void)webView:(UIWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
@end

@implementation UICGoogleMapsAPI

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
		self.delegate = self;
		[self makeAvailable];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    // Nothing to do.
}

- (void)makeAvailable {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"html"];
    //sign here
    NSError * error = nil;
    NSString * htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
  /*  htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<script src=>" withString:@"<script src=http://maps.google.com/maps?file=api&amp;v=3.x&amp;sensor=false&amp;key=hmdk64hM_G8XCEwBNON1o720wLo=>"];*/
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<script src=>" withString:@"<script src=http://maps.google.com/maps?file=api&amp;v=3.x&amp;sensor=false&amp;client=gme-servicemaxinc>"];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundlePath = [bundle bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
    
    //[self loadHTMLString:htmlString baseURL:baseURL];
    [self loadHTMLString:[self signAPIURL:htmlString] baseURL:baseURL];
    
    // [self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}

- (void)webView:(UIWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
	//NSLog(@"%@", message);
	id JSONValue = [message JSONValue];
	if (!JSONValue) {
		if ([self.delegate respondsToSelector:@selector(goolgeMapsAPI:didFailWithMessage:)]) {
			[(id<UICGoogleMapsAPIDelegate>)self.delegate goolgeMapsAPI:self didFailWithMessage:message];
		}
		return;
	}
	if ([self.delegate respondsToSelector:@selector(goolgeMapsAPI:didGetObject:)]) {
		[(id<UICGoogleMapsAPIDelegate>)self.delegate goolgeMapsAPI:self didGetObject:JSONValue];
	}
}
- (NSString *)signAPIURL:(NSString *)urlpath {
    
    NSString *key = @"hmdk64hM_G8XCEwBNON1o720wLo=";
    
    NSURL *u = [NSURL URLWithString:urlpath];
    NSString *url = [NSString stringWithFormat:@"%@%@", [u path], [u query]];
    
    // Stores the url in a NSData.
    NSData *urlData = [url dataUsingEncoding: NSASCIIStringEncoding];
    
    // URL-safe Base64 coder/decoder.
    GTMStringEncoding *encoding = [GTMStringEncoding rfc4648Base64WebsafeStringEncoding];
    
    // Decodes the URL-safe Base64 key to binary.
    NSData *binaryKey = [encoding decode:key];
    
    // Signs the URL.
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1,
           [binaryKey bytes], [binaryKey length],
           [urlData bytes], [urlData length],
           &result);
    NSData *binarySignature = [NSData dataWithBytes:&result length:CC_SHA1_DIGEST_LENGTH];
    
    // Encodes the signature to URL-safe Base64.
    NSString *signature = [encoding encode:binarySignature];
    
    return [NSString stringWithFormat:@"%@&signature=%@", urlpath, signature];
}
@end
