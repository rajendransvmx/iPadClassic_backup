//
//  NSData+DDData.h
//  iService
//
//  Created by Samman Banerjee on 3/19/12.
//  Copyright (c) 2012 TheTwinTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DDData)

// gzip compression utilities
- (NSData *)gzipInflate;
- (NSData *)gzipDeflate;

@end
