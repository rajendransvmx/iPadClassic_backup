//
//  BaseSFObjectField.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFObjectFieldModel.h
 *  @class  SFObjectFieldModel
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

@interface SFObjectFieldModel : NSObject

@property(nonatomic) NSInteger localId;


@property(nonatomic) BOOL unique;
@property(nonatomic) BOOL restrictedPicklist;
@property(nonatomic) BOOL calculated;
@property(nonatomic) BOOL defaultedOnCreate;

/**
 String represents value for fieldName
 */
@property(nonatomic,strong) NSString    *fieldName;

/**
 String represents value for type
 */
@property(nonatomic,strong) NSString    *type;

/**
 String represents value for objectName
 */
@property(nonatomic,strong) NSString    *objectName;

/**
 String represents value for label
 */
@property(nonatomic,strong) NSString    *label;

/**
 String represents value for relationName
 */
@property(nonatomic,strong) NSString    *relationName;

/**
 String represents value for referenceTo
 */
@property(nonatomic,strong) NSString    *referenceTo;

/**
 String represents value for controlerField
 */
@property(nonatomic,strong) NSString    *controlerField;

/**
 String represents value for nameField
 */
@property(nonatomic,strong) NSString    *nameField;

/**
 String represents value for dependentPicklist
 */
@property(nonatomic,strong) NSString    *dependentPicklist;

/**
 String represents value for precision
 */
@property(nonatomic,assign) double       precision;

/**
 Integer value represents value for length
 */
@property(nonatomic,assign) NSInteger    length;

/**
 Bool flag for checking if its is Nillable
 */
@property(nonatomic,assign) BOOL        isNillable;

- (id)init;

@end