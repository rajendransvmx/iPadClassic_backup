//
//  MobileUsageDataModel.m
//  ServiceMaxiPad
//
//  Created by Madhusudhan.HK on 6/24/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "MobileUsageDataModel.h"

@implementation MobileUsageDataModel

@synthesize uniqId;
@synthesize name;
@synthesize type;


- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //Initialization
    }
    return self;
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    uniqId = nil;
    name   = nil;
    type   = nil;
    
}


- (void)explainMe
{
}

+ (NSDictionary*)getMobileUageDetails
{
    NSDictionary *mobileUsageDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:@"getMobileUageDetails",@"00Di0000000ca6SEAQ",@"userId",@"005i0000001kPLgAAM",@"profileId",@"005i0000001kPLgAAM",@"orgId",@"00DJ0000003KhyyMAC",@"userLoggedInHost",@"Sandbox",@"currentUserName",@"himanshi@qa11.com.cfg1", nil];
    
    /* add client inforation */
    NSDictionary *clientInfoDictionary;
    NSDictionary *client = @{@"clientType":@"iPad",@"iOSversion":@"7.0.4",@"appversion":@"15.30.007",@"deviceversion":@"iPad2-2",@"memoryavailable":@"1024"};
    NSDictionary *network = @{@"type":@"cellular",@"ipaddress":@"15.30.007"};
    clientInfoDictionary = @{client:@"clientInfo",network:@"network"};
    
    
    /* add metadata inforation */
    NSDictionary *metaInfoDictionary;
    NSDictionary *syncInfo = @{@"lastDataSyncTime":@"2015-06-29 12:44:56",@"lastConfigSyncTime":@"2015-06-29 12:44:56",@"lastDataSyncStatus":@"Success",@"lastConfigSyncStatus":@"Success",@"lastDataurgeTime":@"2015-06-15 10:12:09"};
    NSDictionary *locationInfo = @{@"lat":@"78.78667",@"long":@"12.09089",@"status":@"enabled"};
    NSDictionary *recordInfo = @{@"attachments":@"1245",@"case":@"22",@"bizzrules":@"5",@"contact":@"0",@"event":@"22",@"pricebook":@"34",@"pricebookentry":@"216",@"product":@"932",@"SFExpression":@"114",@"SFProcess":@"202",@"SFwizard":@"35",@"SMVXC_Code_Snipet__c":@"5",@"SMVXC_Service_Order_line__c":@"432",@"SMVXC_Service_Order__c":@"110",@"SMVXC_Site__c":@"1231",@"User":@"1",@"SMVXC_Installed_Product__c":@"0",@"SFRTPicklist":@"89729382",@"SFPicklist":@"5876",@"SFObjectField":@"6098",@"SFNamedSearch":@"76",@"SFM_search_field":@"60",@"SMXC_Time_Entry__c":@"30"};
    metaInfoDictionary = @{syncInfo:@"syncInfo",locationInfo:@"locationInfo",recordInfo:@"recordInfo"};
    
    /* add client and metadata Dictionaries to MobileUsage Dictionary */
    mobileUsageDictionary = @{clientInfoDictionary:@"clientInfo",metaInfoDictionary:@"metaInfo"};
    
    SXLogDebug(@"\n MobileUsage Data Model \n, %@",mobileUsageDictionary);
    
    return mobileUsageDictionary;
    
}
@end
