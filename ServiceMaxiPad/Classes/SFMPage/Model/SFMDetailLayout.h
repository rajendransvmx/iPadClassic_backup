//
//  SFMDetailLayout.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 12/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPageField.h"

/**
 *  @file   SFMDetailLayout.h
 *  @class  SFMDetailLayout
 *
 *  @brief Holds the page layout detials information
 *
 *  @author Radha S
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 **/


@interface SFMDetailLayout : NSObject

@property(nonatomic,copy) NSString *objectName;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *pageLayoutId;
@property(nonatomic,copy) NSString *dtlLayoutId;
@property(nonatomic,copy) NSString *headerReferenceField;
@property(nonatomic,copy) NSString *processComponentId;

@property(nonatomic,assign) BOOL allowNewLines;
@property(nonatomic,assign) BOOL allowDeleteLines;
@property(nonatomic,assign) BOOL allowMultiAddConfig;
@property(nonatomic, strong) NSString *allowZeroLines;
@property(nonatomic, strong) NSString *multiAddSearchField;
@property(nonatomic, strong) NSString *multiAddSearhObject;

@property(nonatomic,assign) NSInteger noOfColumns;

@property(nonatomic,strong) NSArray *detailSectionFields;

@property(nonatomic,strong) NSArray *linkedProcess;

@property(nonatomic,strong) NSArray *pageEvents; //is billable 012254

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
