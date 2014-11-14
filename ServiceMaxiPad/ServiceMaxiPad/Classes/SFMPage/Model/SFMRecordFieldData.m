//
//  SFMRecordFieldData.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMRecordFieldData.h"

@implementation SFMRecordFieldData

- (id)initWithFieldName:(NSString *)fName
                  value:(NSString *)fValue
        andDisplayValue:(NSString *)dValue{
    self = [super init];
    if (self != nil) {
        
        self.name = fName;
        self.internalValue = fValue;
        self.displayValue = dValue;
    }
    return self;
}


@end
