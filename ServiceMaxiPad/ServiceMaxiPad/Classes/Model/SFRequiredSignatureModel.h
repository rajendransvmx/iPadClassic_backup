//
//  BaseSFRequiredSignature.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFRequiredSignatureModel.h
 *  @class  SFRequiredSignatureModel
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

@interface SFRequiredSignatureModel : NSObject

@property(nonatomic, strong) NSString *signId;
@property(nonatomic, strong) NSString *signatureId;

- (id)init;

@end