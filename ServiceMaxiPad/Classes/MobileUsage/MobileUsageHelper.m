//
//  MobileUsageHelper.m
//  ServiceMaxiPad
//
//  Created by Madhusudhan.HK on 6/27/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "MobileUsageHelper.h"

@implementation MobileUsageHelper

+(BOOL) isFileExistsAtPath:(NSString *)mobileUsageFilePath{
    
    /* hardcoded  for prodcut ID number,
     TODO: Should append the JS file ID */
    SXLogDebug(@"\n ======== :Mobile usgae: ======== \n At %@ find out JS at %@ and returns YES or NO",self.class,mobileUsageFilePath);
    NSString *path = [mobileUsageFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",@"015K0000001ax1tIAA.zip"]];
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    return isFileExists;
}

@end