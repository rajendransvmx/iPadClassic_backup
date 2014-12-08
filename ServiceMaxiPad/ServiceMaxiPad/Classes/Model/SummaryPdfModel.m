//
//  BaseSummaryPDF.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SummaryPdfModel.m
 *  @class  SummaryPdfModel
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

#import "SummaryPdfModel.h"

@implementation SummaryPdfModel 

@synthesize recordId;
@synthesize objectApiName;
@synthesize PDFData;
@synthesize WorkOrderNumber;
@synthesize PDFId;
@synthesize signType;
@synthesize pdfName;

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
    recordId = nil;
    objectApiName = nil;
    PDFData = nil;
    WorkOrderNumber = nil;
    PDFId = nil;
    signType = nil;
    pdfName = nil;
}


@end