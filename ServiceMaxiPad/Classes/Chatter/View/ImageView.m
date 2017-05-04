//
//  ImageView.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 30/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ImageView.h"
#import "FileManager.h"
#import "TaskManager.h"
#import "TaskGenerator.h"
#import "FlowDelegate.h"
#import "WebserviceResponseStatus.h"
#import "SNetworkReachabilityManager.h"
#import "AsyncImageLoader.h"
#import "ChatterHelper.h"
#import "ChatterManager.h"

@interface ImageView ()

@property (nonatomic, strong)UIActivityIndicatorView *activityIndicator;

@end

@implementation ImageView

- (void)loadImage
{
    if ([[ChatterManager sharedInstance] getFirstTimeLoad]) {
        if (!self.activityIndicator) {
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            self.activityIndicator.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
            self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin ;
        }
        [self addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
    }
    [self continueLoadingImage];
}

- (void)continueLoadingImage {
    
    [self createTask];
    self.hidden = NO;
}

- (UIImage *)getImageForUserId
{
    UIImage* newImage = nil;
    
    NSData* imageData = [ChatterHelper getImageDataForUserId:self.userId];
    if( imageData ) {
        newImage = [UIImage imageWithData:imageData];
    }
    return newImage;
}


- (UIImage *)getImageForChatterFilePath
{
    UIImage* newImage = nil;
    if( [[NSFileManager defaultManager] fileExistsAtPath:[FileManager getChatterRelatedFilePath:self.userId]] ) {
        newImage = [[UIImage alloc] initWithContentsOfFile:[FileManager getChatterRelatedFilePath:self.userId]];
    }
    return newImage;
}

- (void)createTask
{
    BOOL result = [[AsyncImageLoader sharedInstance] isRequestFiredForUrl:self.photoUrl userId:self.userId];
    if (result) {
        [self updateImage];
    }
    else {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(updateImage)
                                                     name:@"ImageDownloaded"
                                                   object:nil];
    }
}

- (void)setNewImage:(UIImage*)inImage {
    if (inImage == nil) {
        self.hidden =YES;
    }
    else {
        self.image =  inImage;
    }
    [self.activityIndicator stopAnimating];
    self.activityIndicator = nil;
    [self.activityIndicator removeFromSuperview];
}

- (void)updateImage
{
    UIImage* image = [self getImageForUserId];
    
    if (image) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self setNewImage:image];
    }
    else {
        [self.activityIndicator stopAnimating];
        self.activityIndicator = nil;
        [self.activityIndicator removeFromSuperview];
    }
}

- (void)cancelAllOPeration
{
    @synchronized([self class]){
        self.image = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)dealloc
{
    [self cancelAllOPeration];
}

@end
