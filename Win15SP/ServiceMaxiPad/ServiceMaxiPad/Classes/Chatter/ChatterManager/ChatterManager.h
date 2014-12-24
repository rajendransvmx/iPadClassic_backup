//
//  ChatterManager.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatterManager : NSObject

@property(nonatomic, weak) id chatterDelegate;

- (void)getProductIamgeAndChatterPostDetails;


@end
