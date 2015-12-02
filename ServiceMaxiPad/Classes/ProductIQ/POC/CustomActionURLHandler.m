//
//  CustomActionURLHandler.m
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 01/12/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomActionURLHandler.h"
#import "ProductIQHomeViewController.h"

@implementation CustomActionURLHandler

- (void)executeCustomActionURLHandler:(NSString*)urlQuery {
    
    [[ProductIQHomeViewController getInstance] loadCustomActionURL:urlQuery];
    
}
@end
