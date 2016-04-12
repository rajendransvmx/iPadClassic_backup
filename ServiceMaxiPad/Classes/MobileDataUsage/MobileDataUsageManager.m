//
//  MobileDataUsageManager.m
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 24/02/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "MobileDataUsageManager.h"
#import "MobileDataUsageExecuter.h"
#import "SMAppDelegate.h"
#import "AppMetaData.h"



@implementation MobileDataUsageManager

-(void)getSettingValue:(NSString *)params
{
    NSLog(@"getSettingValue called");
    NSDictionary *d = [self parse:params];
    NSString *callback = d[@"nativeCallbackHandler"];
    NSString *requestId = d[@"requestId"];
    NSString *type = d[@"type"];
    NSString *methodName = d[@"methodName"];
    NSString *jsCallback = d[@"jsCallback"];
    NSDictionary *paramDict = [self parse:d[@"params"]];
    NSString *serverURLkey = paramDict[@"settingName"];
    //NSString *serverURLvalue = @"https://mtools-prod.servicemax-api.com";
    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *serverURLvalue = appDelegate.serverUrl;

    
    //For Viewing
   // https://mtools-prod-host.servicemax-api.com/resource/errorsyncreport/?orgid=00DF00000007BzNMAU
    
    
    NSMutableDictionary *resp = [[NSMutableDictionary alloc] init];
    [resp setObject:requestId forKey:@"requestId"];
    [resp setObject:type forKey:@"type"];
    [resp setObject:methodName forKey:@"methodName"];
    [resp setObject:callback forKey:@"nativeCallbackHandler"];
    [resp setObject:jsCallback forKey:@"jsCallback"];
    [resp setObject:serverURLvalue forKey:serverURLkey];
    
    [self respondOnMethod:callback withParams:resp];
    
}

-(void)getDeviceInfo:(NSString *)params
{
    NSLog(@"getDeviceInfo called");
    NSDictionary *d = [self parse:params];
    NSString *callback = d[@"nativeCallbackHandler"];
    NSString *requestId = d[@"requestId"];
    NSString *type = d[@"type"];
    NSString *methodName = d[@"methodName"];
    NSString *jsCallback = d[@"jsCallback"];
    
    NSMutableDictionary *resp = [[NSMutableDictionary alloc] init];
    [resp setObject:requestId forKey:@"requestId"];
    [resp setObject:type forKey:@"type"];
    [resp setObject:methodName forKey:@"methodName"];
    [resp setObject:callback forKey:@"nativeCallbackHandler"];
    [resp setObject:jsCallback forKey:@"jsCallback"];

    
    [resp setObject:[self getDeviceInfo] forKey:@"deviceInfo"];

    [resp setObject:@true forKey:@"status"];
    
    [self respondOnMethod:callback withParams:resp];
}

-(void)getReadOpenFile:(NSString *)params
{
    NSLog(@"getReadOpenFile called");
    NSDictionary *d = [self parse:params];
    NSString *callback = d[@"nativeCallbackHandler"];
    NSString *requestId = d[@"requestId"];
    NSString *type = d[@"type"];
    NSString *methodName = d[@"methodName"];
    NSString *jsCallback = d[@"jsCallback"];
    
    NSMutableDictionary *resp = [[NSMutableDictionary alloc] init];
    [resp setObject:requestId forKey:@"requestId"];
    [resp setObject:type forKey:@"type"];
    [resp setObject:methodName forKey:@"methodName"];
    [resp setObject:callback forKey:@"nativeCallbackHandler"];
    [resp setObject:jsCallback forKey:@"jsCallback"];

    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:appDelegate.syncDataArray format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
    NSLog(@"Size in bytes before: %lu - Entries: %lu", (unsigned long)[data length], (unsigned long)appDelegate.syncDataArray.count);
    
    
    if(data.length>(500*1024)) {
        
    __block NSInteger dataToBeRemove = data.length-(500*1024);
    __block NSInteger dataRemoved=0;
    __block NSInteger indexUpperLimit=0;
        
     [appDelegate.syncDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           NSData * dataDict =  [NSPropertyListSerialization dataWithPropertyList:obj format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
         
           if(dataToBeRemove>dataRemoved) {
               dataRemoved += dataDict.length;
               indexUpperLimit++;
           } else {
               *stop = YES;    // Stop enumerating
           }
       }];
        
        if([appDelegate.syncDataArray count]>indexUpperLimit) {
            [appDelegate.syncDataArray removeObjectsInRange:NSMakeRange(0, indexUpperLimit)];
        }
    }
    
    NSData *dataAfter = [NSPropertyListSerialization dataWithPropertyList:appDelegate.syncDataArray format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
    NSLog(@"Size in bytes after: %lu - Entries: %lu", (unsigned long)[dataAfter length], (unsigned long)appDelegate.syncDataArray.count);
    
    if (appDelegate.syncDataArray !=nil)
    {
        [resp setObject:appDelegate.syncDataArray forKey:@"error"];
        
    }
    

    [resp setObject:@true forKey:@"Status"];
    
    [self respondOnMethod:callback withParams:resp];
    
}

-(void)getErrorDetails:(NSString *)params
{
    NSLog(@"geterrorDetails called");
    NSDictionary *d = [self parse:params];
    NSString *callback = d[@"nativeCallbackHandler"];
    NSString *requestId = d[@"requestId"];
    NSString *type = d[@"type"];
    NSString *methodName = d[@"methodName"];
    NSString *jsCallback = d[@"jsCallback"];
    
    NSMutableDictionary *resp = [[NSMutableDictionary alloc] init];
    [resp setObject:requestId forKey:@"requestId"];
    [resp setObject:type forKey:@"type"];
    [resp setObject:methodName forKey:@"methodName"];
    [resp setObject:callback forKey:@"nativeCallbackHandler"];
    [resp setObject:jsCallback forKey:@"jsCallback"];
 
    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication]delegate];

    NSString *logType = appDelegate.syncReportingType;
    if ([logType isEqualToString:@"error"])
    {
        logType = @"error";
    }
    else if([logType isEqualToString:@"always"])
    {
        logType = @"success";
    }
    if (logType!=nil)
    {
        [resp setObject:logType forKey:@"logType"];
    }
    NSMutableDictionary *exceptionDict = [[NSMutableDictionary alloc]init];
    if (appDelegate.syncErrorDataArray !=nil)
    {
        [exceptionDict setObject:appDelegate.syncErrorDataArray forKey:@"errorRecords"];
    }

    [resp setObject:exceptionDict forKey:@"exceptions"];
    [resp setObject:@"INITIAL" forKey:@"syncType"];//have to take actual value of sync type
    [resp setObject:@true forKey:@"status"];
    [resp setObject:appDelegate.serverUrl forKey:@"toolsServerURL"];
    
    [self respondOnMethod:callback withParams:resp];

    
}


-(NSDictionary *)parse:(NSString *) str {
    NSError *error = nil;
    NSDictionary *ret =
    [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    return ret;
}


-(void)respondOnMethod:(NSString *) methodName withParams:(id)params {
    NSError *error = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    
    NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
    MobileDataUsageExecuter *mdExecuter = [MobileDataUsageExecuter getInstance];

    dispatch_async(dispatch_get_main_queue(), ^{
    
        UIWebView *browser = [mdExecuter getBrowser];
        if(browser != nil)
        {
            NSString *js = [NSString stringWithFormat:@"%@(%@)", methodName, resp];
            //SXLogDebug(@"&&& %@", js);
            NSLog(@"executing js script in mdu before");
            [browser stringByEvaluatingJavaScriptFromString:js];
            NSLog(@"executing js script in mdu after");

        }
    });

    
}

-(NSMutableArray *)getDeviceInfo
{
    
    NSMutableArray *deviceInfoArray = [[NSMutableArray alloc]init];
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSMutableDictionary *deviceInfoDict  = [[NSMutableDictionary alloc]init];
    [deviceInfoDict setObject:@"" forKey:@"barcode-enabled"];
    [deviceInfoDict setObject:currentDevice.model forKey:@"client-type"];
    [deviceInfoDict setObject:currentDevice.systemName forKey:@"device-platform"];
    
    NSMutableArray *detailsArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *deviceDetailsDict  = [[NSMutableDictionary alloc]init];
    [deviceDetailsDict setObject:currentDevice.systemVersion forKey:@"OperatingSystemName"];
    [deviceDetailsDict setObject:@"armv_64" forKey:@"OSArchitecture"];
    [deviceDetailsDict setObject:@"" forKey:@"CurrentTimeZone"];
    [deviceDetailsDict setObject:currentDevice.systemVersion forKey:@"Caption"];
    [deviceDetailsDict setObject:@"" forKey:@"SystemDirectory"];
    [deviceDetailsDict setObject:currentDevice.name forKey:@"ComputerName"];
    [deviceDetailsDict setObject:currentDevice.name forKey:@"UserName"];
    [deviceDetailsDict setObject:@"Apple" forKey:@"Manufacturer"];
    [deviceDetailsDict setObject:@"" forKey:@"Model"];
    NSString *physicalMemory = [NSString stringWithFormat:@"%llu",[NSProcessInfo processInfo].physicalMemory];
    [deviceDetailsDict setObject:physicalMemory forKey:@"TotalPhysicalMemory"];
    [detailsArray addObject:deviceDetailsDict];
    [deviceInfoDict setObject:detailsArray forKey:@"details"];
    
    [deviceInfoArray addObject:deviceInfoDict];
    
    return deviceInfoArray;
    
    
}

@end
