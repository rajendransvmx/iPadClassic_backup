//
//  BaseSFReferenceTo.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFReferenceToModel.h
 *  @class  SFReferenceToModel
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

@interface SFReferenceToModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic, strong) NSString *objectApiName;
@property(nonatomic, strong) NSString *fieldApiName;
@property(nonatomic, strong) NSString *reference_to;

- (id)init;

@end