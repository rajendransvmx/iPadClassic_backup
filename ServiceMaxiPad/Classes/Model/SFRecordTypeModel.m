//
//  BaseSFRecordType.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFRecordTypeModel.m
 *  @class  SFRecordTypeModel
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

#import "SFRecordTypeModel.h"
#import "StringUtil.h"
#import "RequestConstants.h"

@implementation SFRecordTypeModel 

@synthesize localId;
@synthesize recordTypeId;
@synthesize objectApiName;
@synthesize recordType;
@synthesize recordtypeLabel;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}


- (id)initWithDictionary:(NSDictionary *)jsonDictionary {
    self = [super init];
	if (self != nil)
    {
      
		//Initialization
        NSString *newrecordTypeId = [jsonDictionary objectForKey:kSVMXRequestKey];
        if ([StringUtil isStringEmpty:newrecordTypeId]) {
            newrecordTypeId = @"";
        }
        self.recordTypeId = newrecordTypeId;
        
        NSString *recordTypeNameTemp = [jsonDictionary objectForKey:kSVMXRequestValue];
        if ([StringUtil isStringEmpty:recordTypeNameTemp]) {
            recordTypeNameTemp = @"";
        }
         self.recordtypeLabel = recordTypeNameTemp;
        
        NSString *newRecordType = [jsonDictionary objectForKey:@"value"];
        if(![StringUtil isStringEmpty:newRecordType])
        {
            self.recordType = newRecordType;

        }

	}
	return self;
}


@end