//
//  MyImageClass.h
//  MiniDirectory
//
//  Created by Samman Banerjee on 30/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageCacheClass : NSObject
{
	NSMutableDictionary * imageCache;
}

@property (nonatomic, retain) NSMutableDictionary * imageCache;

- (UIImage *) getImage:(NSString *)filename;
- (void) clearMemory;

@end