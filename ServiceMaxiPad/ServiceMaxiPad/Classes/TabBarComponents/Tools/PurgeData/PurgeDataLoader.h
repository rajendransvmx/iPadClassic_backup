//
//  PurgeDataLoader.h
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/1/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"

@interface PurgeDataLoader : NSObject{

}

+ (void)makeRequestForFrequencyWithTheCallerDelegate:(id)delegate
                                     ForTheCategory:(CategoryType )category;


@end
