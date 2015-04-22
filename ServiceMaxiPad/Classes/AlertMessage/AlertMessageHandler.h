//
//  AlertMessageHandler.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/29/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   AlertMessageHandler.h
 *  @class  AlertMessageHandler
 *
 *  @brief Generate and display alert messages for application
 *
 *   This will manage entire application UIAlertView.
 *   It is singletone class.
 *   
 *   -- Create AlertView
 *   -- Propagate alert view into correspond view controller
 *
 *  @author Vipindas Palli
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>


/**
 *  Alert Message Type
 *
 *  Enum represetation of Alert Message type
 *
 */


typedef enum AlertMessageType : NSUInteger
{
    AlertMessageTypeUnknown = -1,
    AlertMessageTypeInternetNotReachable = 1,
    AlertMessageTypeSwitchUser = 2,
    AlertMessageTypeIncorrectLogin = 3,
    AlertMessageTypeWebServiceFailed = 4,
    AlertMessageTypeInvalidLogin = 5,
    AlertMessageTypeErrorInEmail = 6,
    AlertMessageTypeAttachmentDeleteConfirmation = 7,
    AlertMessageTypeAttachmentWithImproperFormat = 8,
    AlertMessageTypeChatterNoPost = 9,
    AlertMessageTypeInvalidURL = 10,
    AlertMessageTypeNoViewLayout = 11,
    AlertMessageTypeSFMSwitchProcess = 12,
    AlertMessageTypeRequiredFieldWarning = 13,
    AlertMessageTypeGetPriceObjectsNotFound = 14,
    AlertMessageTypeCannotFindHost = 15,
    AlertMessageTypeCannotFindCustomHost = 16,
    AlertMessageTypeCannotLoadInWebView = 17,
    AlertMessageTypeNoPageLayout = 18,
    AlertMessageTypeInvalidEmail = 19,
    AlertMessageTypeEventOvelapOnSync = 20,
    AlertMessageTypeEventNotAssociatedWithRecord = 21,
    AlertMessageTypeNoViewProcess = 22,
    AlertmessageTypeInternetNotAvailableWithRetryOption = 23,
    AlertMessageTypeResetApplication = 24,
    AlertMessageTypeNoEventsForTheDay = 25,
    AlertMessageTypeAccessTokenExpired = 26,
    AlertMessageTypeInactiveUser = 27,
    AlertMessageTypeCustom = 99,               /** Undefined Alert message  */
    
}
AlertMessageType;


@interface AlertMessageHandler : NSObject


+ (instancetype) sharedInstance;
+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

/**
 * @name
 *
 * @author Vipindas Palli
 *
 * @brief Show Alert message by message type
 *
 * \par
 *
 *
 * @param  type message type
 * @return void
 *
 */

- (void)showAlertMessageWithType:(AlertMessageType)type;

/**
 * @name
 *
 * @author Vipindas Palli
 *
 * @brief Show Alert message by message type
 *
 * \par
 *
 * @param  type message type
 * @param  alertDelegate  UIAlertViewDelegate object, if you want to do some respond to the alert button click
 * @return void
 *
 */

- (void)showAlertMessageWithType:(AlertMessageType)type andDelegate:(id)alertDelegate;

/**
 * @name
 *
 * @author Shubha S
 *
 * @brief Show Alert message by message type and given message
 *
 * \par
 *
 * @param  type message type 
 * @param  NSString message
 * @param  alertDelegate  UIAlertViewDelegate object, if you want to do some respond to the alert button click
 * @return void
 *
 */

- (void)showAlertMessageWithType:(AlertMessageType)type message:(NSString*)message andDelegate:(id)alertDelegate;

/**
 * @name
 *
 * @author Vipindas Palli
 *
 * @brief Show Alert message by custom inputs
 *
 * \par
 *
 *
 *
 * @param  aMessage message
 * @param  alertDelegate  UIAlertViewDelegate object, if you want to do some respond to the alert button click
 * @param  title  title for alert view
 * @param  cancelButton  cancel button name
 * @param  buttonTitles list of button titles
 * @return void
 *
 */

- (void)showCustomMessage:(NSString *)aMessage
             withDelegate:(id)alertDelegate
                    title:(NSString *)title
        cancelButtonTitle:(NSString *)cancelButton
     andOtherButtonTitles:(NSArray *)buttonTitles;

/**
 * @name showCustomMessage:(NSString *)aMessage
              withDelegate:(id)alertDelegate
                       tag:(NSInteger)tag
                     title:(NSString *)title
         cancelButtonTitle:(NSString *)cancelButton
      andOtherButtonTitles:(NSArray *)buttonTitles;

 *
 * @author Pushpak
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  aMessage message
 * @param  alertDelegate  UIAlertViewDelegate object, if you want to do some respond to the alert button click
 * @param  title  title for alert view
 * @param  tag  tag for alert view
 * @param  cancelButton  cancel button name
 * @param  buttonTitles list of button titles
 * @return void
 *
 */
- (void)showCustomMessage:(NSString *)aMessage
             withDelegate:(id)alertDelegate
                      tag:(NSInteger)tag
                    title:(NSString *)title
        cancelButtonTitle:(NSString *)cancelButton
     andOtherButtonTitles:(NSArray *)buttonTitles;
@end
