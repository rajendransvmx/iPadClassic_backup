//
//  AsyncImageDownload.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 12/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncImageConnection : NSURLConnection

@property(nonatomic, strong)NSString *photoUrl;
@property(nonatomic, strong)NSString *userId;

@end

@interface AsyncImageDownload : NSObject



@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *urlString;

- (instancetype )initWithURL:(NSString *)URL userId:(NSString *)userId;

- (void)start;
- (void)cancel;


@end
