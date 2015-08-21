//
//  ProductIQHomeViewController.h
//  ServiceMaxiPad
//
//  Created by Admin on 19/08/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSExecuter.h"

@interface ProductIQHomeViewController : UIViewController <UINavigationControllerDelegate>

@property (nonatomic, strong) JSExecuter                *jsExecuter; /*!< JSExecuter object to load web view with core library imports */

@end
