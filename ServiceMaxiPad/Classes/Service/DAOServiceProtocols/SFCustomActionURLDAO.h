//
//  SFCustomActionURLDAO.h
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@protocol SFCustomActionURLDAO <CommonServiceDAO>

- (void)getCustomActionURL:(NSMutableArray *)CustomActionURLArray recordId:(NSString *)recordId;
-(void)updateCustomActionURL:(NSArray*)modelArray;

@end
