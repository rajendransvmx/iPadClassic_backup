//
//  PushNotificationUtility.m
//  ServiceMaxiPad
//
//  Created by Sahana on 12/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "PushNotificationUtility.h"
#import "CustomTabBar.h"
#import "CalendarHomeViewController.h"
#import "NewItemViewController.h"
#import "SMXCalendarViewController.h"
#import "PageEditViewController.h"
#import "FactoryDAO.h"
#import "TransactionObjectDAO.h"
#import "SFObjectDAO.h"
#import "SFObjectModel.h"
#import "CustomerOrgInfo.h"
#import "ResponseConstants.h"

@implementation PushNotificationUtility


+(BOOL)isEditViewController:(UIViewController *)topViewcontroller
{
    if([topViewcontroller isKindOfClass:[PageEditViewController class]])
    {
        return YES;
    }
    return NO;
}

+(ViewControllerType)getRootViewControllerType:(UIViewController *)rootViewController;
{
    if([rootViewController isKindOfClass:[SMXCalendarViewController class]])
    {
        return CalendarViewController;
    }
    else {
        return Unknown;
    }
//    CalendarViewController,
//    SearchViewController,
//    NewItemViewControllert,
//    SettingsViewController,
//    TaskViewController,
//    Unknown
    
    return Unknown;
}

+(ViewControllerType)selectedViewControllerOnTabBar
{
    return Unknown;
}

+(UIViewController *)getTopViewController
{
    id topVc = nil;
    CustomTabBar *customBar = (CustomTabBar*)[UIApplication sharedApplication].delegate.window.rootViewController;
    id vc = [customBar selectedViewController];
    if([vc isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nv = (UINavigationController *)vc;
        //id topVc = [nv topViewController];
        topVc = [nv visibleViewController];
    }
    return  topVc;
}

+(UIViewController *)getRootViewController
{
    id  rootVc  =  nil;
    CustomTabBar *customBar = (CustomTabBar*)[UIApplication sharedApplication].delegate.window.rootViewController;
    id vc = [customBar selectedViewController];
    if([vc isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nv = (UINavigationController *)vc;
        rootVc  = [nv.viewControllers objectAtIndex:0];
    }
    return rootVc;
}

+(void)removeViewControllersFromNavStack:(UIViewController *)viewController
{
    UINavigationController * navController =  viewController.navigationController;
    NSArray *viewControllers = [navController viewControllers];
    UIViewController * rootVc  = nil;
    for ( id vc in viewControllers) {
        if([vc isKindOfClass:[SMXCalendarViewController class]]){
            rootVc = vc;
            break;
        }
    }
    
    
  /*  for ( UIViewController * vc in viewControllers) {
        if(![vc isKindOfClass:[SMXCalendarViewController class]]){
            [navController popViewControllerAnimated:YES];
        }
    }*/
    if(rootVc != nil){
        [navController popToViewController:rootVc animated:NO];
    }

}

+(UIViewController *)getCalendarViewController
{
    return [PushNotificationUtility getRootViewController];;
}

+(void)selectCalendarViewController
{

    CustomTabBar *customBar = (CustomTabBar*)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    [customBar selectTab:1];

}

+(UIViewController *)getParentViewController
{
    id topVc = nil;
    CustomTabBar *customBar = (CustomTabBar*)[UIApplication sharedApplication].delegate.window.rootViewController;
    id vc = [customBar selectedViewController];
    if([vc isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nv = (UINavigationController *)vc;
         topVc = [nv topViewController];
        //topVc = [nv visibleViewController];
    }
    return  topVc;
}

+(NSString *)getLocalIdForSfId:(NSString *)sfId objectName:(NSString *)objectName;
{
    id <TransactionObjectDAO>  transObj = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    TransactionObjectModel *model = [transObj getLocalIDForObject:objectName recordId:sfId];
    
    if (model != nil) {
         return  [model valueForField:kLocalId];
    }
    return nil;
}

+(NSString *)getObjectForSfId:(NSString *)sfId
{
    if (sfId.length < 15) {
        return nil;
    }
    
    NSString *keyPrefix = [sfId substringToIndex:3];
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"keyPrefix" operatorType:SQLOperatorEqual andFieldValue:keyPrefix];
    
    id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    
    SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:@[@"objectName"]];
    
    return model.objectName;
}


+(BOOL)shouldInitiatePushNotification:(CategoryType)categoryType {
    
        switch (categoryType) {
            case CategoryTypeConfigSync:
            case CategoryTypeInitialSync:
            case CategoryTypeOneCallRestInitialSync:
            case CategoryTypeIncrementalOneCallMetaSync:
            case CategoryTypeDOD:
            case CategoryTypeOneCallConfigSync:
            case CategoryTypeSFMSearch:
            case CategoryTypeDataPurge:
            case CategoryTypeValidateProfile:
                return YES;
            break;
                
            default:
                break;
        }
    return YES;
}

//Org Validation
+(BOOL)validateOrg:(NSDictionary *)APNSDict
{
    BOOL isValidUser = NO;
    CustomerOrgInfo *custOrginfo = [CustomerOrgInfo sharedInstance];
    NSString *orgID = custOrginfo.userOrgId;
    NSString *userID = custOrginfo.userId;
    
    if ([orgID isEqualToString:[APNSDict objectForKey:kPulseNotificationOrgId]])
    {
        if ([userID isEqualToString:[APNSDict objectForKey:kPulseNotificationUserId]])
        {
            isValidUser = YES;
        }
        else
        {
            //NSString *orgId = [APNSDict objectForKey:kPulseNotificationUserId];
            UIAlertView *alert  = [[UIAlertView alloc]initWithTitle:@"Login Alert" message:@"Please login with same user ID, used for Pulse App" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            isValidUser = NO;
        }
    }
    else
    {
        //NSString *userId = [APNSDict objectForKey:kPulseNotificationUserId];
        UIAlertView *alert  = [[UIAlertView alloc]initWithTitle:@"Login Alert" message:@"Please login with same org Id, used for Pulse App" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        isValidUser = NO;
    }
    
    return isValidUser;
}

+(NSMutableDictionary*)getDictionaryFromSharedURL:(NSURL*)url
{
    NSString *tokenString = [[url query]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [tokenString componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        [queryStringDictionary setObject:value forKey:key];
        
        if ([key isEqualToString:kPulseNotificationString])
        {
            value = [[urlComponents lastObject] stringByRemovingPercentEncoding];
            value = [value substringFromIndex:19];
            NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            id json;
            if (![data isKindOfClass:[NSNull class]] && data != nil)
            {
                json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                if(json!=nil) {
                [queryStringDictionary setObject:json forKey:key];
                }
                else {
                [queryStringDictionary removeObjectForKey:key];
                }
            }
        }
    }
    return queryStringDictionary;
}

@end
