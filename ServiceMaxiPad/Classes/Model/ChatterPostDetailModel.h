//
//  BaseChatterPostDetails.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ChatterPostDetailModel.h
 *  @class  ChatterPostDetailModel
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


@interface ChatterPostDetailModel : NSObject


@property(nonatomic, strong) NSString *productId;
@property(nonatomic, strong) NSString *body;
@property(nonatomic, strong) NSString *createdById;
@property(nonatomic, strong) NSString *createdDate;
@property(nonatomic, strong) NSString *feedItemId;
@property(nonatomic, strong) NSString *postType;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *fullPhotoUrl;
@property(nonatomic, strong) NSString *Id;

- (id)init;

- (void)explainMe;

@end