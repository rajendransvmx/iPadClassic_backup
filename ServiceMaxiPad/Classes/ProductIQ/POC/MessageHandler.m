//
//  MessageHandler.m
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 07/10/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "MessageHandler.h"
#import "ProductIQHomeViewController.h"
#import "SFMRecordFieldData.h"
#import "StringUtil.h"
#import "ProductIQManager.h"

@implementation MessageHandler

- (void)executeMessageHandler:(NSString*)params {
    
    @autoreleasepool {
        NSDictionary *requestParams = [self parse:params];
        NSString *callback = requestParams[@"nativeCallbackHandler"];
        NSString *requestId = requestParams[@"requestId"];
        NSString *type = requestParams[@"type"];
        NSString *methodName = requestParams[@"methodName"];
        NSString *operation = requestParams[@"operation"];
        NSString *jsCallback = requestParams[@"jsCallback"];
        
        NSDictionary *messageHandlerResponse = [ProductIQHomeViewController getInstance].responseDictionary;
        
        //If messageHandlerResponse is nil, then try to avoid the call.
        if (messageHandlerResponse != nil && messageHandlerResponse.count > 0) {
            NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
            [responseDictionary setValue:requestId forKey:@"requestId"];
            [responseDictionary setValue:type forKey:@"type"];
            [responseDictionary setValue:methodName forKey:@"methodName"];
            if (operation != nil) {
                [responseDictionary setValue:operation forKey:@"operation"];
            }
            [responseDictionary setValue:callback forKey:@"nativeCallbackHandler"];
            [responseDictionary setValue:jsCallback forKey:@"jsCallback"];
            [responseDictionary setValue:messageHandlerResponse forKey:@"data"];
            [self respondOnMethod:callback withParams:responseDictionary];
        }
        
    }
}


-(NSDictionary *)parse:(NSString *) str {
    NSError *error = nil;
    NSDictionary *ret =
    [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    return ret;
}

-(void)respondOnMethod:(NSString *) methodName withParams:(NSDictionary *)params {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    UIWebView *browser = [[ProductIQHomeViewController getInstance] getBrowser];
    NSString *js = [NSString stringWithFormat:@"%@(%@)", methodName, resp];
    SXLogDebug(@"&&& %@", js);
    [browser stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - MessageHandler Response

+ (NSMutableDictionary*)getMessageHandlerResponeDictionaryForSFMPage:(SFMPageViewModel*)sfmPageView {
    @autoreleasepool {
        NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSMutableArray *recordIds = nil;
        recordIds = [[ProductIQManager sharedInstance] recordIds];
        
        [responseDictionary setValue:sfmPageView.sfmPage.objectName forKey:@"object"];
        [responseDictionary setValue:@"VIEW" forKey:@"action"];
        [responseDictionary setValue:recordIds forKey:@"recordIds"];
        [responseDictionary setValue:sfmPageView.sfmPage.nameFieldValue forKey:@"sourceRecordName"];
        return responseDictionary;
    }
}



@end
