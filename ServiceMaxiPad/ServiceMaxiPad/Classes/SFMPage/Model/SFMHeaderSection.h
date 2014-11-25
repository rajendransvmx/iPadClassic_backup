//
//  SFMHeaderSection.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 12/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SFMHeaderSection.h
 *  @class  SFMHeaderSection
 *
 *  @brief Holda the page layout sections details
 *
 *  @author Radha S
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 **/


#import <Foundation/Foundation.h>
#import "SFMPageField.h"

@interface SFMHeaderSection : NSObject

@property(nonatomic,copy) NSString *title;

@property(nonatomic,assign) NSInteger noOfColumns;

@property(nonatomic,assign) BOOL isSLAClock;

@property(nonatomic,strong) NSArray *sectionFields;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)isSectionSLAClock;
- (SFMPageField *)pageFieldForField:(NSString *)fieldName;
@end
