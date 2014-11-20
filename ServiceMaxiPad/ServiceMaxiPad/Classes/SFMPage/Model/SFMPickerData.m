//
//  SFMPickerData.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 23/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMPickerData.h"

@implementation SFMPickerData

- (instancetype)initWithPickerValue:(NSString *)value label:(NSString *)label index:(NSInteger)index
{
    if (self = [super init]) {
        
        _pickerValue = value;
        _pickerLabel = label;
        _indexValue = index;
    }
    return self;
}

@end
