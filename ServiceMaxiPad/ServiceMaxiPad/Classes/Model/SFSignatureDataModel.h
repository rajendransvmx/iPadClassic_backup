//
//  BaseSFSignatureData.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFSignatureDataModel
 *  @class  SFSignatureDataModel
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

@interface SFSignatureDataModel : NSObject

@property(nonatomic, strong) NSString *recordId;
@property(nonatomic, strong) NSString *objectApiName;
@property(nonatomic, strong) NSString *signatureData;
@property(nonatomic, strong) NSString *sigId;
@property(nonatomic, strong) NSString *WorkOrderNumber;
@property(nonatomic, strong) NSString *signType;
@property(nonatomic, strong) NSString *operationType;
@property(nonatomic, strong) NSString *signatureTypeId;
@property(nonatomic, strong) NSString *signatureName;

- (id)init;

@end