//
//  BaseSFOPDocHtmlData.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFOutputDocHtmlaDataModel.h
 *  @class  SFOutputDocHtmlaDataModel
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

@interface SFOutputDocHtmlaDataModel : NSObject

@property(nonatomic, strong) NSString *localId;
@property(nonatomic, strong) NSString *objectApiName;
@property(nonatomic, strong) NSString *opdocData;
@property(nonatomic, strong) NSString *sfId;
@property(nonatomic, strong) NSString *WorkOrderNumber;
@property(nonatomic, strong) NSString *docName;
@property(nonatomic, strong) NSString *processId;

- (id)init;

@end