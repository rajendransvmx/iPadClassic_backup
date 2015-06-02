//
//  SMXProductListModel.h
//  ServiceMaxiPad
//
//  Created by Apple on 02/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMXProductListModel : NSObject{
    
}
@property(nonatomic, copy) NSString *productId;
@property(nonatomic, assign) int count;
@property(nonatomic, copy) NSString *displayValue;
- (id)init;
@end
