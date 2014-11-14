//
//  BaseSFRequiredPdf.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFRequiredPdfModel.h
 *  @class  SFRequiredPdfModel
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


@interface SFRequiredPdfModel : NSObject

@property(nonatomic, strong) NSString *processId;
@property(nonatomic, strong) NSString *recordId;
@property(nonatomic, strong) NSString *attachmentId;

- (id)init;

@end