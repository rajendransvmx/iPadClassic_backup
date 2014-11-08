//
//  BaseSFM_Search_Process.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFMSearchProcessModel.m
 *  @class  SFMSearchProcessModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SFMSearchProcessModel.h"
#import "ResponseConstants.h"

@implementation SFMSearchProcessModel 
@synthesize localId;
@synthesize identifier;
@synthesize name;
@synthesize processName;
@synthesize processDescription;


- (void)dealloc
{
    localId = nil;
    identifier = nil;
    name = nil;
    processName = nil;
    processDescription = nil;
}
+ (NSDictionary *) getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:ksfmSearchProcessSFID,@"identifier",ksfmSearchName,@"name",ksfmSearchProcessDescrip,@"processDescription", ksfmSearchProcessName,@"processName", nil];
    
    return mapDictionary;
}


@end