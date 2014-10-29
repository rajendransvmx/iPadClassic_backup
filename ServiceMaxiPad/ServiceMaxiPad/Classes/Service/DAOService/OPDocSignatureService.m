//
//  OPDocSignatureService.m
//  ServiceMaxiPad
//
//  Created by Damodar on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "OPDocSignatureService.h"

@implementation OPDocSignatureService


- (NSString *)tableName
{
    // kTableOPDocHtmlDataSchema - OPDocHTML
    // kTableOPDocSignatureDataSchema - OPDocSignature
    
    return @"OPDocSignature";
}

- (void)addSignaturefile:(NSString*)fileName processId:(NSString*)processId recordId:(NSString*)recId signId:(NSString*)signId andHTML:(NSString*)htmlFile
{
    
}

- (void)updateSignature:(NSString*)signName withSFID:(NSString*)sfid
{
    
}

@end
