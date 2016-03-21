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
    NSDictionary *d = [self parse:params];
    NSString *callback = d[@"nativeCallbackHandler"];
    NSString *requestId = d[@"requestId"];
    NSString *type = d[@"type"];
    NSString *methodName = d[@"methodName"];
    NSString *jsCallback = d[@"jsCallback"];
    NSDictionary *paramDict = [self parse:d[@"params"]];
    NSString *serverURLkey = paramDict[@"settingName"];
    NSString *serverURLvalue = @"https://mtools-prod.servicemax-api.com";
    
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
    [resp setObject:callback forKey:@"nativellbackHandler"];
    [resp setObject:jsCallback forKey:@"jsCallback"];

    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:appDelegate.syncDataArray format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
    NSLog(@"Size in bytes before: %lu - Entries: %lu", (unsigned long)[data length], (unsigned long)appDelegate.syncDataArray.count);
    
    
    if(data.length>(650*1024)) {

    __block NSInteger dataToBeRemove = data.length-(650*1024);
    __block NSInteger dataRemoved=0;
    
     [appDelegate.syncDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           NSDictionary * logDict = appDelegate.syncDataArray[idx];
           
           NSData * dataDict =  [NSPropertyListSerialization dataWithPropertyList:logDict format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
           NSLog(@"size: %lu", (unsigned long)[dataDict length]);
           
           if(dataToBeRemove>dataRemoved) {
               dataRemoved += dataDict.length;
               [appDelegate.syncDataArray removeObjectAtIndex:idx];
           } else {
               *stop = YES;    // Stop enumerating
           }
       }];
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
        NSData *dataAfter = [NSPropertyListSerialization dataWithPropertyList:appDelegate.syncErrorDataArray format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
        NSLog(@"Size in bytes: %lu - Entries: %lu", (unsigned long)[dataAfter length], (unsigned long)appDelegate.syncDataArray.count);
        
    }

    [resp setObject:exceptionDict forKey:@"exceptions"];
    [resp setObject:@"INITIAL" forKey:@"syncType"];//have to take actual value of sync type
    [resp setObject:@true forKey:@"status"];
    
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

    
    UIWebView *browser = [mdExecuter getBrowser];
    if(browser != nil)
    {
        NSString *js = [NSString stringWithFormat:@"%@(%@)", methodName, resp];
        SXLogDebug(@"&&& %@", js);
        [browser stringByEvaluatingJavaScriptFromString:js];
    }
        
    
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
    [deviceInfoDict setObject:currentDevice.systemVersion forKey:@"OperatingSystemName"];
    [deviceInfoDict setObject:@"armv_64" forKey:@"OSArchitecture"];
    [deviceInfoDict setObject:@"" forKey:@"CurrentTimeZone"];
    [deviceInfoDict setObject:@"" forKey:@"Caption"];
    [deviceInfoDict setObject:@"" forKey:@"SystemDirectory"];
    [deviceInfoDict setObject:currentDevice.name forKey:@"ComputerName"];
    [deviceInfoDict setObject:currentDevice.name forKey:@"UserName"];
    [deviceInfoDict setObject:@"Apple" forKey:@"Manufacturer"];
    [deviceInfoDict setObject:@"" forKey:@"Model"];
    [deviceInfoDict setObject:@"" forKey:@"TotalPhysicalMemory"];
    [detailsArray addObject:deviceDetailsDict];
    [deviceInfoDict setObject:@"" forKey:@"details"];
    
    [deviceInfoArray addObject:deviceInfoDict];
    
    return deviceInfoArray;
    
    
}

@end
