//
//  SFMLookUp.h
//  ServiceMaxMobile
//
//  Created by Sahana on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMLookUpFilter.h"

@interface SFMLookUp : NSObject


@property (nonatomic, strong) NSString *lookUpId;

@property (nonatomic, strong) NSString *defaultColoumnName;

@property (nonatomic, strong) NSArray *searchFields;

@property (nonatomic, strong) NSArray *displayFields;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) NSString *objectName;

@property (nonatomic, strong) NSString *searchString;

@property (nonatomic)NSInteger recordLimit;

@property(nonatomic, strong) NSString *serachName;

@property (nonatomic, strong) NSMutableDictionary * fieldInfoDict;

/*Advance Look UP Filter*/
@property (nonatomic, strong) NSArray *preFilters;
@property (nonatomic, strong) NSArray *advanceFilters;
@property (strong, nonatomic) SFMLookUpFilter *contextLookupFilter;

// defect- 23783
@property (strong, nonatomic) NSString *defaultObjectColumnName; // Used this for include online Item to show default Object table name, if defaultColumnName value does not exits.

@end
