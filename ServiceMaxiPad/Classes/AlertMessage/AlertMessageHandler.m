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
#import "TagConstant.h"

@implementation AlertMessageHandler

#pragma mark - Singleton class Implementation
#pragma mark Singleton Methods
+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
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
+ (NSString *)titleByType:(AlertMessageType)type
{
    NSString * title = nil;
    switch (type)
    {
        case AlertMessageTypeSwitchUser:
        {
            title =  [[TagManager sharedInstance] tagByName:kTagAlertSwitchUser];
        }
            break;
            
        case AlertMessageTypeInternetNotReachable:
        case AlertMessageTypeResetApplication:
        case AlertMessageTypeNoEventsForTheDay:
        case AlertMessageTypeAccessTokenExpired:
        case AlertMessageTypeInactiveUser:
            
        {
            title =  [[TagManager sharedInstance] tagByName:kTagAlertTitleError];
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
            title = [[TagManager sharedInstance] tagByName:kTagAlertIpadError];
        }
            break;
            
        case AlertMessageTypeInvalidURL:
        case AlertMessageTypeRequiredFieldWarning:
        case AlertMessageTypeInvalidEmail:
            
        {
            title = [[TagManager sharedInstance] tagByName:kTagAlertWarningError];
        }
            break;
            
        case AlertMessageTypeAttachmentWithImproperFormat:
        case AlertMessageTypeCannotFindHost:
        case AlertMessageTypeCannotFindCustomHost:
        case AlertMessageTypeCannotLoadInWebView:
            
        {
            title = [[TagManager sharedInstance] tagByName:kTagAlertApplicationError];
        }
            break;

        case AlertMessageTypeErrorInEmail:
        {
            title = [[TagManager sharedInstance] tagByName:kTagServiceReportEmailError];
        }
            break;
        case AlertMessageTypeAttachmentDeleteConfirmation:
        {
            title = [[TagManager sharedInstance] tagByName:@""];
        }
            break;
            
        case AlertMessageTypeEventOvelapOnSync:
        {
            title = [[TagManager sharedInstance] tagByName:kTagSyncErrorMessage];
        }
            break;
            
        case AlertMessageTypeInvalidLogin:
        {
            title = [[TagManager sharedInstance] tagByName:kTagChatterAlertAuthenticatiojnError];
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

+ (NSString *)messageByType:(AlertMessageType)type
{
    NSString * message = nil;
    switch (type)
    {
        case AlertMessageTypeSwitchUser:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagLoginSwitchUser];
        }
            break;
        case AlertMessageTypeNoEventsForTheDay:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagHomeNoEvents];
        }
            break;
        case AlertMessageTypeResetApplication:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagResetApplication];
        }
            break;
        case AlertMessageTypeInternetNotReachable:
        {
            message =  [[TagManager sharedInstance] tagByName:KTagAlertInrnetNotAvailableError];
        }
            break;
        case AlertMessageTypeErrorInEmail:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagServiceReportPleaseSetUpEmailFirstError];
        }
            break;
        case AlertMessageTypeAttachmentDeleteConfirmation:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagDocDeleteConfirmation];
        }
            break;
        case AlertMessageTypeChatterNoPost:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagChatterNewPost];
        }
            break;
        case AlertMessageTypeInvalidURL:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagSfmInvalidUrl];
        }
            break;
        case AlertMessageTypeNoViewLayout:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagNoViewLayOut];
        }
            break;
        case AlertMessageTypeSFMSwitchProcess:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagSfmSwitchProcess];
        }
            break;
        case AlertMessageTypeRequiredFieldWarning:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagAlertRequiredFields];
        }
            break;
        case AlertMessageTypeGetPriceObjectsNotFound:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagGetPriceObjectsNotFound];
        }
            break;
        case AlertMessageTypeAttachmentWithImproperFormat:
        {
            message =  [[TagManager sharedInstance] tagByName:kTag_FileNotSupportedByWebView];
        }
            break;
        case AlertMessageTypeCannotFindHost:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagHostNotFound];
        }
            break;
        case AlertMessageTypeCannotFindCustomHost:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagHostNotFound_CheckURL];
        }
            break;
        case AlertMessageTypeCannotLoadInWebView:
        {
            message =  [[TagManager sharedInstance] tagByName:kTag_CannotBeLoadedInWebView];
        }
            break;
        case AlertMessageTypeNoPageLayout:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagSfmNoPageLayout];
        }
            break;
        case AlertMessageTypeInvalidEmail:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagSfmInvalidEmail];
        }
            break;
        case AlertMessageTypeEventOvelapOnSync:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagEventOverlap];
        }
            break;
        case AlertMessageTypeEventNotAssociatedWithRecord:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagNotAssociatedRecord];
        }
            break;
        case AlertMessageTypeNoViewProcess:
        {
            message =  [[TagManager sharedInstance] tagByName:kTagNoViewProcess];
        }
            break;
        case AlertmessageTypeInternetNotAvailableWithRetryOption:
        {
            message =  [[TagManager sharedInstance] tagByName:KTagAlertInrnetNotAvailableError];
        }
            break;
            
        case AlertMessageTypeAccessTokenExpired:
        case AlertMessageTypeInactiveUser:
        {
            //message =  [[TagManager sharedInstance] tagByName:kTagRemoteAccesError];
            message =  [[TagManager sharedInstance] tagByName:kTag_RemoteAccessRevokedMsg];

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

+ (NSString *)cancelButtonTitleByType:(AlertMessageType)type
{
    NSString * cancelButtonTitle = nil;
    switch (type)
    {
        case AlertMessageTypeSwitchUser:
        case AlertMessageTypeResetApplication:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:kTagLoginContinue];
        }
            break;
            
        case AlertMessageTypeInternetNotReachable:
        case AlertMessageTypeErrorInEmail:
        case AlertMessageTypeChatterNoPost:
        case AlertMessageTypeInvalidURL:
        case AlertMessageTypeNoEventsForTheDay:
        case AlertMessageTypeAccessTokenExpired:
        case AlertMessageTypeInactiveUser:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
        }
            break;
            
        case AlertMessageTypeNoViewLayout:
        case AlertMessageTypeSFMSwitchProcess:
        case AlertMessageTypeNoPageLayout:
            
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:kTagCancelButton];
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
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
        }
            break;
        case AlertMessageTypeAttachmentDeleteConfirmation:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:kTagDeleteAction];
        }
            break;

        case AlertMessageTypeEventOvelapOnSync:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:kTagEventReschedulePrompt];
        }
            break;
        case AlertmessageTypeInternetNotAvailableWithRetryOption:
        {
            cancelButtonTitle =  [[TagManager sharedInstance] tagByName:kTagSyncProgressRetry];
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

+ (NSString *)otherButtonTitleByType:(AlertMessageType)type
{
   
    NSString * otherButtonTitle = nil;
    switch (type)
    {
        case AlertMessageTypeSwitchUser:
        case AlertMessageTypeResetApplication:
        {
            otherButtonTitle =  [[TagManager sharedInstance] tagByName:kTagCancelButton];
        }
            break;
            
        case AlertMessageTypeAttachmentDeleteConfirmation:
        {
            otherButtonTitle =  [[TagManager sharedInstance] tagByName:kTagDeleteLocallyAction];
        }
            break;
        case AlertMessageTypeEventOvelapOnSync:
        {
            otherButtonTitle =  [[TagManager sharedInstance] tagByName:kTagYes];
        }
            break;
        case AlertmessageTypeInternetNotAvailableWithRetryOption:
        {
            otherButtonTitle =  [[TagManager sharedInstance] tagByName:kTagSyncProgressIWillTry];
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
    
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[AlertMessageHandler titleByType:type]
                               message:[AlertMessageHandler messageByType:type]
                              delegate:alertDelegate
                     cancelButtonTitle:[AlertMessageHandler cancelButtonTitleByType:type]
                     otherButtonTitles:[AlertMessageHandler otherButtonTitleByType:type], nil];
  [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
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
        alertMessage = [AlertMessageHandler messageByType:type];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[AlertMessageHandler titleByType:type]
                                                        message:alertMessage
                                                       delegate:alertDelegate
                                              cancelButtonTitle:[AlertMessageHandler cancelButtonTitleByType:type]
                                              otherButtonTitles:[AlertMessageHandler otherButtonTitleByType:type], nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
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
}

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
     andOtherButtonTitles:(NSArray *)buttonTitles {
    
    NSString *titleSeparatedByComas = nil;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:aMessage
                                                       delegate:alertDelegate
                                              cancelButtonTitle:cancelButton
                                              otherButtonTitles:titleSeparatedByComas,nil];
    if ((buttonTitles!= nil) && ([buttonTitles count] > 0))
    {
        for (NSString *title in buttonTitles) {
            [alertView addButtonWithTitle:title];
        }
    }
    
    alertView.tag = tag;
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];

}

@end
