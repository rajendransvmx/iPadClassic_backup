//
//  MessageHandler.h
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 07/10/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPageViewModel.h"

@interface MessageHandler : NSObject

- (void)executeMessageHandler:(NSString*)params;
+ (NSMutableDictionary*)getMessageHandlerResponeDictionaryForSFMPage:(SFMPageViewModel*)sfmPageView;


@end
