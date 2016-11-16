//
//  UIImage+fixOrientation.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 16/07/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UIImage+FixOrientation.h"

@implementation UIImage (FixOrientation)

- (UIImage *)fixImageOrientation {
    
    // If the orientation is already correct, do nothing
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    
    // There are two steps to calculate the transformation to make the image upright - Rotate if the image is left or right or down, and then flip if image is mirrored.
    CGAffineTransform afflineTransform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        {
            afflineTransform = CGAffineTransformTranslate(afflineTransform, self.size.width, self.size.height);
            afflineTransform = CGAffineTransformRotate(afflineTransform, M_PI);
            break;
        }
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        {
            afflineTransform = CGAffineTransformTranslate(afflineTransform, self.size.width, 0);
            afflineTransform = CGAffineTransformRotate(afflineTransform, M_PI_2);
            break;
        }
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            afflineTransform = CGAffineTransformTranslate(afflineTransform, 0, self.size.height);
            afflineTransform = CGAffineTransformRotate(afflineTransform, -M_PI_2);
            break;
        }
            
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        {
            afflineTransform = CGAffineTransformTranslate(afflineTransform, self.size.width, 0);
            afflineTransform = CGAffineTransformScale(afflineTransform, -1, 1);
            break;
        }
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
        {
            afflineTransform = CGAffineTransformTranslate(afflineTransform, self.size.height, 0);
            afflineTransform = CGAffineTransformScale(afflineTransform, -1, 1);
            break;
        }
            
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Draw underlying CGImage into a new context and then applying the transform calculated above.
    CGContextRef context = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                                 CGImageGetBitsPerComponent(self.CGImage), 0,
                                                 CGImageGetColorSpace(self.CGImage),
                                                 CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(context, afflineTransform);
    
    if (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored || self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored) {
        
        CGContextDrawImage(context, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
    }
    else {
        
        CGContextDrawImage(context, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
    }
    
    // Create new UIImage from the drawing context
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGContextRelease(context);
    CGImageRelease(cgImage);
    return image;
}

@end
