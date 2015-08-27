//
//  Console.m
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import "Console.h"

@implementation Console

- (void)log:(NSString *) params {
    [self logMessage:[self parse:params]];
}

- (void)error:(NSString *) params {
    [self logMessage:[self parse:params]];
}

- (void)warn:(NSString *) params {
    [self logMessage:[self parse:params]];
}

- (void)debug:(NSString *) params {
    [self logMessage:[self parse:params]];
}

- (void)info:(NSString *) params {
    [self logMessage:[self parse:params]];
}

- (NSDictionary *)parse:(NSString *) str {
    NSError *error = nil;
    NSDictionary *ret =
    [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    return ret;
}

-(void)logMessage:(NSDictionary *) details {
    NSLog(@"%@::%@", details[@"type"], details[@"message"]);
}


@end
