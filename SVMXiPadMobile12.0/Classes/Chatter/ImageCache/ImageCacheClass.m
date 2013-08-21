//
//  MyImageClass.m
//  MiniDirectory
//
//  Created by Samman Banerjee on 30/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageCacheClass.h"


@implementation ImageCacheClass

@synthesize imageCache;

- (id) init
{
    self = [super init];
	if (self)
	{
		imageCache = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	return self;
}

//  Unused methods
//- (void) clearMemory
//{
//	[imageCache removeAllObjects];
//}

- (UIImage *) getImage:(NSString *)filename
{
	if (filename == nil)
		return nil;
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectoryPath = [paths objectAtIndex:0];
    filename = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", filename]];

	UIImage * image = [imageCache objectForKey:filename];

	if (nil == image)
	{
		if ([imageCache count] > 5)
		{
			[imageCache removeAllObjects];
		}
		// NSString * imageFile = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
		if ([filename isEqualToString:@""])
			return nil;
		image = [UIImage imageWithContentsOfFile:filename];
		if (nil != image)
			[imageCache setObject:image forKey:filename];
		else
			return nil;
	}

	return image;
}

-(void) dealloc
{
	[imageCache removeAllObjects];
	[imageCache release];
	[super dealloc];
}

@end

/*
@implementation UIImage (ImageLoadingExtension)

+ (UIImage *) newImageFromResource:(NSString *) filename
{
	NSString * imageFile = [[NSString alloc] initWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    UIImage * image = nil;
    image = [[UIImage alloc] initWithContentsOfFile:imageFile];
    [imageFile release];
    return image;
}

@end
*/
