//
//  UIImage+UISegmentIconAndText.m
//  ServiceMaxMobile
//
//  Created by ServiceMax on 09/05/14.
//  Copyright (c) 2014 Shubha. All rights reserved.
//

#import "UIImage+UISegmentIconAndText.h"

@implementation UIImage (UISegmentIconAndText)

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
