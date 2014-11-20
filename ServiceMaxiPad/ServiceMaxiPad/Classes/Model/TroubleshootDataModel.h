//
//  BaseTrobleshootdata.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   TrobleshootdataModel.h
 *  @class  TrobleshootdataModel
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

@interface TroubleshootDataModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic, strong) NSString *ProductId;
@property(nonatomic, strong) NSString *ProductName;
@property(nonatomic, strong) NSData *Product_Doc;
@property(nonatomic, strong) NSString *DocId;
@property(nonatomic, strong) NSString *prod_manualId;
@property(nonatomic, strong) NSString *prod_manualName;
@property(nonatomic, strong) NSString *productmanbody;

- (id)init;

@end