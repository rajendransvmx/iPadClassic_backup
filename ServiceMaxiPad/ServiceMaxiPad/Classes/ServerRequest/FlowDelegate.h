//
//  FlowDelegate.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 8/16/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   FlowDelegate.h
 *  @class  FlowDelegate
 *
 *  @brief  Function prototypes for the console driver.
 *
 *
 *  This contains the prototypes for the console
 *  driver and eventually any macros, constants,
 *  or global variables you will need.
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>

@protocol FlowDelegate <NSObject>

- (void)flowStatus:(id)status;

@end
