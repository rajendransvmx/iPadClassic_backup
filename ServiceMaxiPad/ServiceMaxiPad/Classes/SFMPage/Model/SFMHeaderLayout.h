//
//  SFMHeaderLayout.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 12/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SFMHeaderLayout.h
 *  @class  SFMHeaderLayout
 *
 *  @brief Holds the page layout header level information (Including section details)
 *
 *  @author Radha S
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 **/


#import <Foundation/Foundation.h>
#import "SFMHeaderSection.h"

@interface SFMHeaderLayout : NSObject

@property(nonatomic,copy) NSString *pageLayoutId;
@property(nonatomic,copy) NSString *hdrLayoutId;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *objectName;

@property(nonatomic,assign) BOOL enableChatter;   
@property(nonatomic,assign) BOOL enableServicereport;
@property(nonatomic,assign) BOOL enableTroubleShooting;

@property(nonatomic,assign) BOOL enableProductHistory;
@property(nonatomic,assign) BOOL enableAccountHistory;
@property(nonatomic,assign) BOOL enableAttachment;
@property(nonatomic,assign) BOOL enableAllSection;

@property(nonatomic,assign) BOOL hideQuickSave;
@property(nonatomic, assign) BOOL hideSave;

@property(nonatomic,strong) NSArray *sections;

@property(nonatomic, strong) NSArray    *buttons;

- (id)initWithDictionaty:(NSDictionary *)dictionary;
- (NSArray *)getAllHeaderLayoutFields;
- (BOOL)isAccountyHistoryExists;
- (BOOL)isProductHistoryExists;

@end
