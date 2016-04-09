//
//  SFMProcess.h
//  ServiceMaxMobile
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SFMProcess.h
 *  @class  SFMProcess
 *
 *  @brief
 *
 *   This is a model class used to hold the SFM Process related to different type of SFM processes.
 *
 *  @author Aparna
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import "SFMPageLayout.h"
#import "SFProcessModel.h"
#import "SFProcessComponentModel.h"

@interface SFMProcess : NSObject

@property(nonatomic, strong) SFProcessModel * processInfo;
@property(nonatomic, strong) NSMutableDictionary *component;
@property(nonatomic, strong) SFMPageLayout *pageLayout;

@property(nonatomic, strong) NSMutableDictionary *valueMappingDict;
@property(nonatomic, strong) NSMutableDictionary *valueMappingArrayInLayoutOrder; //Defect#028966

@property(nonatomic, strong) NSMutableDictionary *fieldMappingData;

@property(nonatomic,strong)  NSDictionary *sourceObjectUpdate;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (SFProcessComponentModel *)getProcessComponentOfType:(NSString *)type;

@end
