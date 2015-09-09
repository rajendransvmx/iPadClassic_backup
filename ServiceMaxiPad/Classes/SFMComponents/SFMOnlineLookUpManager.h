//
//  SFMOnlineLookUpManager.h
//  ServiceMaxiPad
//
//  Created by Admin on 05/09/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMLookUp.h"

@protocol  SFMOnlineLookUpManagerDelegate <NSObject>

- (void)onlineLookupSearchSuccessfullwithResponse:(NSMutableArray *)dataArray;
- (void)onlineLookupSearchFailedwithError:(NSError *)error ;

@end

@interface SFMOnlineLookUpManager : NSObject

@property(nonatomic, weak) id <SFMOnlineLookUpManagerDelegate>delegate;

- (void)performOnlineLookUpWithLookUpObject:(SFMLookUp *)lookUpObj
                              andSearchText:(NSString *)searchText;
@end
