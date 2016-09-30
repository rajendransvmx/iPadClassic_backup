//
//  MobileDataUsageExecuter.h
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 01/03/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bridge.h"

@interface MobileDataUsageExecuter : NSObject<UIWebViewDelegate>
{
    NSString *accessToken, *instanceUrl;
    UIWebView *mdWebView;
    Bridge *bridge;
    NSString *callbackUrl;
    NSString *nativeCallUrl;
    NSString *clientId;
    NSString *loginUrl;
    BOOL authenticated;

}
@property(nonatomic,strong)UIView    *parentView;
@property(nonatomic,retain)NSString *syncErrorData;


- (id)initWithParentView:(UIView *)newParentView
                andFrame:(CGRect)newFrame;

-(UIWebView *) getBrowser;
+(MobileDataUsageExecuter*)getInstance;
-(void)execute;
@end
