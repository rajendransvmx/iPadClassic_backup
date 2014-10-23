//
//  BaseSummaryPDF.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SummaryPdfModel.h
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

@interface SummaryPdfModel : NSObject

@property(nonatomic, strong) NSString *recordId;
@property(nonatomic, strong) NSString *objectApiName;
@property(nonatomic, strong) NSString *PDFData;
@property(nonatomic, strong) NSString *WorkOrderNumber;
@property(nonatomic, strong) NSString *PDFId;
@property(nonatomic, strong) NSString *signType;
@property(nonatomic, strong) NSString *pdfName;

- (id)init;

@end