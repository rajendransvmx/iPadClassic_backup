//
//  CustomActionURLHandler.m
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 01/12/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomActionURLHandler.h"
#import "ProductIQHomeViewController.h"

@implementation CustomActionURLHandler

- (void)executeCustomActionURLHandler:(NSString*)urlQuery {
    
    NSDictionary *dictionary = [self parse:urlQuery];
    NSString *paramString = dictionary[@"params"];
    NSDictionary *urlDictionary = [self parse:paramString];
    NSString *uriString = urlDictionary[@"Uri"];
    
    [[ProductIQHomeViewController getInstance] loadCustomActionURL:uriString];
    
}

-(NSDictionary *)parse:(NSString *) str {
    NSError *error = nil;
    NSDictionary *ret =
    [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    return ret;
}
@end
