//
//  BaseSFObject.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFObjectModel.h
 *  @class  SFObjectModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shravya Shridhar
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@interface SFObjectModel : NSObject

/**
 String represents value for objectName
 */
@property(nonatomic,strong) NSString *objectName;

/**
 String represents value for prefix
 */
@property(nonatomic,strong) NSString *keyPrefix;

/**
 String represents value for label
 */
@property(nonatomic,strong) NSString *label;

/**
 String represents value for isQueryable
 */
@property(nonatomic,strong) NSString *isQueryable;

/**
 String represents value for pluralLabel
 */
@property(nonatomic,strong) NSString *labelPlural;


- (id)init;


@end