//
//  ProductManualViewController.h
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMSplitViewController.h"
#import <UIKit/UIKit.h>
#import "FlowNode.h"

@interface ProductManualViewController : SMSplitViewController<FlowDelegate>

@property (nonatomic,strong) NSString *productId;
@property (nonatomic,strong) NSString *productName;
@property (nonatomic,strong) NSArray  *productDetailsArray ;

@end
