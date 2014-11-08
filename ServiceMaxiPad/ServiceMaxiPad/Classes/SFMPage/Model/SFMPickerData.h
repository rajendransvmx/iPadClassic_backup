//
//  SFMPickerData.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 23/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFMPickerData : NSObject

@property(nonatomic, strong)NSString *pickerValue;
@property(nonatomic, strong)NSString *pickerLabel;
@property(nonatomic, assign)NSInteger indexValue;

- (instancetype)initWithPickerValue:(NSString *)value label:(NSString *)label index:(NSInteger)index;

@end
