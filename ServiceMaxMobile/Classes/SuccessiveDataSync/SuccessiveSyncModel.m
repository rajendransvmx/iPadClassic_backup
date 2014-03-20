//
//  SuccessiveSync.m
//  ServiceMaxMobile
//
//  Created by Sahana on 03/01/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "SuccessiveSyncModel.h"

@implementation SuccessiveSyncModel
@synthesize dataDict;

@synthesize localId;
@synthesize objectName;
@synthesize sfId;
@synthesize parentObjectName;
@synthesize operation;
@synthesize parentLocalId;
@synthesize record_type;
@synthesize syncFlag;
@synthesize parentObjName;
@synthesize syncType;
@synthesize headerLocalId;

@synthesize isDBUpdated;

-(void)dealloc
{
    [super dealloc];
    
    [localId release];
    [objectName release];
    [sfId release];
    [parentObjectName release];
    [operation release];
    [parentLocalId release];
    [record_type release];
    [syncFlag release];
    [parentObjName release];
    [syncType release];
    [headerLocalId release];

    
}

@end
