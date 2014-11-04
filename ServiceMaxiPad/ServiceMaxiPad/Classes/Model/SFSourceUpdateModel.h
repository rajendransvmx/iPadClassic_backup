//
//  BaseSFSourceUpdate.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFSourceUpdateModel.h
 *  @class  SFSourceUpdateModel
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

@interface SFSourceUpdateModel : NSObject

@property(nonatomic, copy) NSString *Id;
@property(nonatomic, copy) NSString *action;
@property(nonatomic, copy) NSString *configurationType;
@property(nonatomic, copy) NSString *displayValue;
@property(nonatomic, copy) NSString *process;
@property(nonatomic, copy) NSString *settingId;
@property(nonatomic, copy) NSString *sourceFieldName;
@property(nonatomic, copy) NSString *targetFieldName;
@property(nonatomic, copy) NSString *sourceObjectName;
@property(nonatomic, copy) NSString *targetObjectName;

- (id)init;

/**
 * + (NSDictionary *) getMappingDictionary
 *
 * @author Shubha
 *
 * @brief to get mapping dictionary
 *
 *
 *
 * @param
 * @param
 *
 * @return mapdictionary
 *
 */

+ (NSDictionary *) getMappingDictionary;

@end