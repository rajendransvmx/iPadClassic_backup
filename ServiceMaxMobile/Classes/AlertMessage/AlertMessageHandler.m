//
//  AlertMessageHandler.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/29/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//
/**
 *  @file   AlertMessageHandler.m
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

#import "AlertMessageHandler.h"
#import "TagManager.h"
#import "LocalizationGlobals.h"

static dispatch_once_t _sharedMessageHandlerInstanceGuard;
static AlertMessageHandler *_instance;

static NSString *kMessageAttachmentImproper = @"File cannot be loaded on the webview, File not supported by web view";

static NSString *kMessageCanNotCustomFindHost = @"A server with the specified hostname could not be found. Please check your custom host URL settings.";

static NSString *kMessageCanNotFindHost =  @"A server with the specified hostname could not be found.";

static NSString *kMessageCanNotBeLoadedInWebView = @"Can not be loaded in web view";


@interface AlertMessageHandler ()
{

}
@end


@implementation AlertMessageHandler

#pragma mark - Singleton class Implementation

- (id)init
{
    return [AlertMessageHandler sharedInstance];
}


- (id)initializeAlertMessageHandler
{
    self = [super init];
    
    if (self)
    {

    }
    return self;
}


+ (AlertMessageHandler *)sharedInstance
{
    dispatch_once(&_sharedMessageHandlerInstanceGuard,
                  ^{
                      _instance = [[AlertMessageHandler alloc] initializeAlertMessageHandler];
                  });
    return _instance;
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)retain
{
    return self;
}


- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    // never release
}


- (id)autorelease
{
    return self;
}

#pragma mark - Generate AlertMessage
/**
 * @name  <MethodName. optional>
 *
 * @author Vipindas Palli
 * @author Shubha S.
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */
- (NSString *)titleByType:(AlertMessageType)type
{
    // TODO:- Shubha S
   // Need to replace al the macros by constants
    
    NSString * title = nil;
    switch (type)
    {
        case AlertMessageTypeSwitchUser:
        {
            title =  [[TagManager sharedInstance] tagByName:alert_switch_user];
        }
            break;
            
        case AlertMessageTypeInternetNotReachable:
        case AlertMessageTypeResetApplication:
        case AlertMessageTypeNoEventsForTheDay:
            
        {
            title =  [[TagManager sharedInstance] tagByName:ALERT_ERROR_TITLE];
        }
            break;
            
        case AlertmessageTypeInternetNotAvailableWithRetryOption:
        case AlertMessageTypeChatterNoPost:
        case AlertMessageTypeNoViewLayout:
        case AlertMessageTypeSFMSwitchProcess:
        case AlertMessageTypeEventNotAssociatedWithRecord:
        case AlertMessageTypeGetPriceObjectsNotFound:
        case AlertMessageTypeNoViewProcess:
        case AlertMessageTypeNoPageLayout:
            
        {
            title = [[TagManager sharedInstance] tagByName:alert_ipad_error];
        }
            break;
            
        case AlertMessageTypeInvalidURL:
        case AlertMessageTypeRequiredFieldWarning:
        case AlertMessageTypeInvalidEmail:
            
        {
            title = [[TagManager sharedInstance] tagByName:ALERT_ERROR_WARNING];
        }
            break;
            
        case AlertMessageTypeAttachmentWithImproperFormat:
        case AlertMessageTypeCannotFindHost:
        case AlertMessageTypeCannotFindCustomHost:
        case AlertMessageTypeCannotLoadInWebView:
            
        {
            title = [[TagManager sharedInstance] tagByName:alert_application_error];
        }
            break;

        case AlertMessageTypeErrorInEmail:
        {
            title = [[TagManager sharedInstance] tagByName:SERVICE_REPORT_EMAIL_ERROR];
        }
            break;
        case AlertMessageTypeAttachmentDeleteConfirmation:
        {
            title = [[TagManager sharedInstance] tagByName:@""];
        }
            break;
            
        case AlertMessageTypeEventOvelapOnSync:
        {
            title = [[TagManager sharedInstance] tagByName:sync_error_message];
        }
            break;
            
        case AlertMessageTypeInvalidLogin:
        {
            title = [[TagManager sharedInstance] tagByName:alert_authentication_error_];
        }
            break;

        default:
            break;
    }
    return title;
}

/**
 * @name  <MethodName. optional>
 *
 * @author Vipindas Palli
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */

- (NSString *)messageByType:(AlertMessageType)type
{
    NSString * message = nil;
    switch (type)
    {
        case AlertMessageTypeSwitchUser:
        {
            message =  [[TagManager sharedInstance] tagByName:login_switch_user];
        }
            break;
        case AlertMessageTypeNoEventsForTheDay:
        {
            message =  [[TagManager sharedInstance] tagByName:HOME_NO_EVENTS];
        }
            break;
        case AlertMessageTypeResetApplication:
        {
            message =  [[TagManager sharedInstance] tagByName:RESET_APPLICATION];
        }
            break;
        case AlertMessageTypeInternetNotReachable:
        {
            message =  [[TagManager sharedInstance] tagByName:ALERT_INTERNET_NOT_AVAILABLE];
        }
            break;
        case AlertMessageTypeErrorInEmail:
        {
            message =  [[TagManager sharedInstance] tagByName:SERVICE_REPORT_PLEASE_SET_UP_EMAIL_FIRST];
        }
            break;
        case AlertMessageTypeAttachmentDeleteConfirmation:
        {
            message =  [[TagManager sharedInstance] tagByName:DOC_DELETE_CONFIRMATION];
        }
            break;
        case AlertMessageTypeChatterNoPost:
        {
            message =  [[TagManager sharedInstance] tagByName:chatter_no_posts];
        }
            break;
        case AlertMessageTypeInvalidURL:
        {
            message =  [[TagManager sharedInstance] tagByName:SFM_TEXT_INVALID_URL];
        }
            break;
        case AlertMessageTypeNoViewLayout:
        {
            message =  [[TagManager sharedInstance] tagByName:NO_VIEW_LAYOUT];
        }
            break;
        case AlertMessageTypeSFMSwitchProcess:
        {
            message =  [[TagManager sharedInstance] tagByName:sfm_swich_process];
        }
            break;
        case AlertMessageTypeRequiredFieldWarning:
        {
            message =  [[TagManager sharedInstance] tagByName:ALERT_REQUIRED_FIELDS];
        }
            break;
        case AlertMessageTypeGetPriceObjectsNotFound:
        {
            message =  [[TagManager sharedInstance] tagByName:getPrice_Objects_not_found];
        }
            break;
        case AlertMessageTypeAttachmentWithImproperFormat:
        {
            message =  [[TagManager sharedInstance] tagByName:kMessageAttachmentImproper];
        }
            break;
        case AlertMessageTypeCannotFindHost:
        {
            message =  [[TagManager sharedInstance] tagByName:kMessageCanNotFindHost];
        }
            break;
        case AlertMessageTypeCannotFindCustomHost:
        {
            message =  [[TagManager sharedInstance] tagByName:kMessageCanNotCustomFindHost];
        }
            break;
        case AlertMessageTypeCannotLoadInWebView:
        {
            message =  [[TagManager sharedInstance] tagByName:kMessageCanNotBeLoadedInWebView];
        }
            break;
        case AlertMessageTypeNoPageLayout:
        {
            message =  [[TagManager sharedInstance] tagByName:sfm_no_pagelayout];
        }
            break;
        case AlertMessageTypeInvalidEmail:
        {
            message =  [[TagManager sharedInstance] tagByName:SFM_TEXT_INVALID_EMAIL];
        }
            break;
        case AlertMessageTypeEventOvelapOnSync:
        {
            message =  [[TagManager sharedInstance] tagByName:EVENT_OVERLAP];
        }
            break;
        case AlertMessageTypeEventNotAssociatedWithRecord:
        {
            message =  [[TagManager sharedInstance] tagByName:cal_day_week_view_view_Id];
        }
            break;
        case AlertMessageTypeNoViewProcess:
        {
            message =  [[TagManager sharedInstance] tagByName:NO_VIEW_PROCESS];
        }
            break;
        case AlertmessageTypeInternetNotAvailableWithRetryOption:
        {
            message =  [[TagManager sharedInstance] tagByName:ALERT_INTERNET_NOT_AVAILABLE];
        }
            break;
        
        default:
            break;
    }
    return message;
}

/**
 * @name  <MethodName. optional>
 *
 * @author Vipindas Palli
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */

- (NSString *)cancelButtonTitleByType:(AlertMessageType)type
{
    // TODO:- Shubha S
   // Macros should be replaced by string constants
   
    NSString * cancelButtonTitle = nil;
    switch (type)
    {
        case AlertMessageTypeSwitchUser:
        case AlertMessageTypeResetApplication:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:login_continue];
        }
            break;
            
        case AlertMessageTypeInternetNotReachable:
        case AlertMessageTypeErrorInEmail:
        case AlertMessageTypeChatterNoPost:
        case AlertMessageTypeInvalidURL:
        case AlertMessageTypeNoEventsForTheDay:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:ALERT_ERROR_OK];
        }
            break;
            
        case AlertMessageTypeNoViewLayout:
        case AlertMessageTypeSFMSwitchProcess:
        case AlertMessageTypeNoPageLayout:
            
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:CANCEL_BUTTON_TITLE];
        }
            break;
            
        case AlertMessageTypeRequiredFieldWarning:
        case AlertMessageTypeGetPriceObjectsNotFound:
        case AlertMessageTypeAttachmentWithImproperFormat:
        case AlertMessageTypeCannotFindHost:
        case AlertMessageTypeCannotFindCustomHost:
        case AlertMessageTypeCannotLoadInWebView:
        case AlertMessageTypeInvalidEmail:
        case AlertMessageTypeEventNotAssociatedWithRecord:
        case AlertMessageTypeNoViewProcess:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:ALERT_ERROR_OK];
        }
            break;
        case AlertMessageTypeAttachmentDeleteConfirmation:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:DELETE_ACTION];
        }
            break;

        case AlertMessageTypeEventOvelapOnSync:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:EVENT_RESCHEDULE_NO];
        }
            break;
        case AlertmessageTypeInternetNotAvailableWithRetryOption:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:sync_progress_retry];
        }
            break;
            
        default:
            break;
    }
    return cancelButtonTitle;
}

/**
 * @name  <MethodName. optional>
 *
 * @author Vipindas Palli
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */

- (NSString *)otherButtonTitleByType:(AlertMessageType)type
{
    // TODO:- Shubha S
    // Macros should be replaced by string constants
   
    NSString * otherButtonTitle = nil;
    switch (type)
    {
        case AlertMessageTypeSwitchUser:
        case AlertMessageTypeResetApplication:
        {
            otherButtonTitle =  [[TagManager sharedInstance] tagByName:CANCEL_BUTTON_TITLE];
        }
            break;
            
        case AlertMessageTypeAttachmentDeleteConfirmation:
        {
            otherButtonTitle =  [[TagManager sharedInstance] tagByName:DELETE_LOCALLY_ACTION];
        }
            break;
        case AlertMessageTypeEventOvelapOnSync:
        {
            otherButtonTitle =  [[TagManager sharedInstance] tagByName:EVENT_RESCHEDULE_YES];
        }
            break;
        case AlertmessageTypeInternetNotAvailableWithRetryOption:
        {
            otherButtonTitle =  [[TagManager sharedInstance] tagByName:sync_progress_i_ll_try];
        }
            break;
            
        default:
            break;
    }
    return otherButtonTitle;
}


#pragma mark - Show Alert Message

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

- (void)showAlertMessageWithType:(AlertMessageType)type
{
    [self showAlertMessageWithType:type andDelegate:nil];
}

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


- (void)showAlertMessageWithType:(AlertMessageType)type andDelegate:(id)alertDelegate
{
    
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[self titleByType:type]
                               message:[self messageByType:type]
                              delegate:alertDelegate
                     cancelButtonTitle:[self cancelButtonTitleByType:type]
                     otherButtonTitles:[self otherButtonTitleByType:type], nil];
  [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
  [alertView release];
}


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


- (void)showAlertMessageWithType:(AlertMessageType)type message:(NSString*)message andDelegate:(id)alertDelegate
{
    NSString *alertMessage = message;
    
    if(message == nil)
        
    {
        alertMessage = [self messageByType:type];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[self titleByType:type]
                                                        message:alertMessage
                                                       delegate:alertDelegate
                                              cancelButtonTitle:[self cancelButtonTitleByType:type]
                                              otherButtonTitles:[self otherButtonTitleByType:type], nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    [alertView release];
}


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
     andOtherButtonTitles:(NSArray *)buttonTitles
{
    
    NSString *titleSeparatedByComas = nil;
    
    if ((buttonTitles!= nil) && ([buttonTitles count] > 0))
    {
        titleSeparatedByComas = [buttonTitles componentsJoinedByString:@","];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:aMessage
                                                       delegate:alertDelegate
                                              cancelButtonTitle:cancelButton
                                              otherButtonTitles:titleSeparatedByComas, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    [alertView release];
}


@end
