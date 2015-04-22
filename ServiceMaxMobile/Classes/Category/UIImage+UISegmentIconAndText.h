//
//  UIImage+UISegmentIconAndText.h
//  ServiceMaxMobile
//
//  Created by ServiceMax on 09/05/14.
//  Copyright (c) 2014 Shubha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UISegmentIconAndText)

//It will draw given text inside given image.

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point;


@end
