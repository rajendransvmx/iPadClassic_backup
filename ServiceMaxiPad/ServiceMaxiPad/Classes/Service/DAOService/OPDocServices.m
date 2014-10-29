//
//  OPDocServices.m
//  ServiceMaxiPad
//
//  Created by Damodar on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "OPDocServices.h"

@implementation OPDocServices
- (NSString *)tableName
{
    // kTableOPDocHtmlDataSchema - OPDocHTML
    // kTableOPDocSignatureDataSchema - OPDocSignature

    return @"OPDocHTML";
}


/* Add signatures and HTML file to tables */
- (void)addHTMLfile:(NSString*)fileName forProcess:(NSString*)processId recordId:(NSString*)recId
{
    
}

- (void)addSignaturefile:(NSString*)fileName processId:(NSString*)processId recordId:(NSString*)recId signId:(NSString*)signId andHTML:(NSString*)htmlFile
{
    
}

/* Update SFID of signatures and HTML file to tables */
- (void)updateHTML:(NSString*)htmlFileName withSFID:(NSString*)sfid
{
    
}

- (void)updateSignature:(NSString*)signName withSFID:(NSString*)sfid
{
    
}


@end
