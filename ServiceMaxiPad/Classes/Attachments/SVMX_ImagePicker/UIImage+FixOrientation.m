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
    
    UIImage *imageSelf = self;
    
    // If the orientation is already correct, do nothing
    if (imageSelf.imageOrientation == UIImageOrientationUp) {
        return imageSelf;
    }
    
    // There are two steps to calculate the transformation to make the image upright - Rotate if the image is left or right or down, and then flip if image is mirrored.
    CGAffineTransform afflineTransform = CGAffineTransformIdentity;
    
    //step 1
    //check for down orientation
    if (imageSelf.imageOrientation == UIImageOrientationDown || imageSelf.imageOrientation == UIImageOrientationDownMirrored) {
        
        afflineTransform = CGAffineTransformTranslate(afflineTransform, imageSelf.size.width, imageSelf.size.height);
        afflineTransform = CGAffineTransformRotate(afflineTransform, M_PI);
    }
    //check for left orientation
    else if (imageSelf.imageOrientation == UIImageOrientationLeft || imageSelf.imageOrientation == UIImageOrientationLeftMirrored) {
        
        afflineTransform = CGAffineTransformTranslate(afflineTransform, imageSelf.size.width, 0);
        afflineTransform = CGAffineTransformRotate(afflineTransform, M_PI_2);
    }
    //check for right orientation
    else if (imageSelf.imageOrientation == UIImageOrientationRight || imageSelf.imageOrientation == UIImageOrientationRightMirrored) {

        afflineTransform = CGAffineTransformTranslate(afflineTransform, 0, imageSelf.size.height);
        afflineTransform = CGAffineTransformRotate(afflineTransform, -M_PI_2);
    }

    //step 2
    //check for up or down orientation
    if (imageSelf.imageOrientation == UIImageOrientationUpMirrored || imageSelf.imageOrientation == UIImageOrientationDownMirrored) {

        afflineTransform = CGAffineTransformTranslate(afflineTransform, imageSelf.size.width, 0);
        afflineTransform = CGAffineTransformScale(afflineTransform, -1, 1);
    }
    //check for left or right orientation
    else if (imageSelf.imageOrientation == UIImageOrientationLeftMirrored || imageSelf.imageOrientation == UIImageOrientationRightMirrored) {

        afflineTransform = CGAffineTransformTranslate(afflineTransform, imageSelf.size.height, 0);
        afflineTransform = CGAffineTransformScale(afflineTransform, -1, 1);
    }
    
    // Draw underlying CGImage into a new context and then applying the transform calculated above.
    CGContextRef context = CGBitmapContextCreate(NULL, imageSelf.size.width, imageSelf.size.height,
                                                 CGImageGetBitsPerComponent(imageSelf.CGImage), 0,
                                                 CGImageGetColorSpace(imageSelf.CGImage),
                                                 CGImageGetBitmapInfo(imageSelf.CGImage));
    CGContextConcatCTM(context, afflineTransform);
    
    if (imageSelf.imageOrientation == UIImageOrientationLeft || imageSelf.imageOrientation == UIImageOrientationLeftMirrored || imageSelf.imageOrientation == UIImageOrientationRight || imageSelf.imageOrientation == UIImageOrientationRightMirrored) {
        
        CGContextDrawImage(context, CGRectMake(0,0,imageSelf.size.height,imageSelf.size.width), imageSelf.CGImage);
    }
    else {
        
        CGContextDrawImage(context, CGRectMake(0,0,imageSelf.size.width,imageSelf.size.height), imageSelf.CGImage);
    }
    
    // Create new UIImage from the drawing context
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGContextRelease(context);
    CGImageRelease(cgImage);
    return image;
}

@end
