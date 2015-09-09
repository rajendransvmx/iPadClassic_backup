//
//  SFMOnlineLookUpManager.h
//  ServiceMaxiPad
//
//  Created by Admin on 05/09/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMLookUp.h"
@interface SFMOnlineLookUpManager : NSObject

- (void)performOnlineLookUpWithLookUpObject:(SFMLookUp *)lookUpObj
                              andSearchText:(NSString *)searchText;
@end
