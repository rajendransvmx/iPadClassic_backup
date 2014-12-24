//
//  SFPageButton.h
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/24/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 This is a Model Class which represents page level button such as save,quick save, Get price etc.
 */

#define SFPageButtonTypeJavascript @"JAVASCRIPT"

@interface SFPageButton : NSObject

/**
 string which represents button title
 */
@property(nonatomic,strong)NSString *title;

/**
 Boolean which indicates whether button is enabled
 */
@property(nonatomic,assign)BOOL enabled;

/**
  string which represents type of event like WEB SERVICE, JAVA SCRIPT etc
 
 */
@property(nonatomic,strong)NSString *eventCallBackType;

/**
 string which represents type of event
 */
@property(nonatomic,strong)NSString *eventType;

/**
 string which represents functions needs to be called upon button click
 */
@property(nonatomic,strong)NSString *targetCall;


/**
 This method instantiate the SFPageButton
 @param newTitle  button title
 @param newEventType   event call back type
 @returns Instance of SFPageButton
 */
- (id)initWithTitle:(NSString *)newTitle andEventType:(NSString *)newEventType;

@end
