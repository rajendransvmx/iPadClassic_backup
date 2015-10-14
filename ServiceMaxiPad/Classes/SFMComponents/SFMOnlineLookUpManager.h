//
//  SFMOnlineLookUpManager.h
//  ServiceMaxiPad
//
//  Created by Admin on 05/09/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMLookUp.h"
#import "FlowNode.h"

@protocol  SFMOnlineLookUpManagerDelegate <NSObject>

- (void)onlineLookupSearchSuccessfullwithResponse:(NSMutableArray *)dataArray;
- (void)onlineLookupSearchFailedwithError:(NSError *)error ;
-(id)getValueForContextFilterThroughDelegateForfieldName:(NSString *)fieldName forHeaderObject:(NSString *)headerValue;


@end

@interface SFMOnlineLookUpManager : NSObject <FlowDelegate>

@property(nonatomic, weak) id <SFMOnlineLookUpManagerDelegate>delegate;

- (void)performOnlineLookUpWithLookUpObject:(SFMLookUp *)lookUpObj
                              andSearchText:(NSString *)searchText;
@end
