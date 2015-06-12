//
//  SFMCustomActionHelper.h
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFMCustomActionHelper : NSObject

-(void)loadURL:(NSString *)url withParams:(NSArray *)params ActionType:(NSString *)actionType;
-(id)init;
@end
