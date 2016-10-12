//
//  Console.h
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Console : NSObject

- (void)log:(NSString* ) params;
- (void)error:(NSString* ) params;
- (void)warn:(NSString* ) params;
- (void)debug:(NSString* ) params;
- (void)info:(NSString* ) params;

@end
