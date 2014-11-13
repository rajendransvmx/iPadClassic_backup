//
//  SFMOnlineSearchManager.h
//  ServiceMaxiPad
//
//  Created by Shubha S on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMSearchProcessModel.h"

@interface SFMOnlineSearchManager : NSObject

@property(nonatomic,strong)SFMSearchProcessModel *searchProcessModel;

@property(nonatomic,strong)NSString *searchText;

- (id)initWithSFMSearchProcessModel:(SFMSearchProcessModel*)searchProcessModel andSearchText:(NSString*)searchText;

@end
