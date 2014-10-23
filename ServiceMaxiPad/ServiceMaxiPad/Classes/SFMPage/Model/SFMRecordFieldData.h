//
//  SFMRecordFieldData.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFMRecordFieldData : NSObject

@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *internalValue;
@property(nonatomic,strong) NSString *displayValue;
@property(nonatomic,assign) BOOL isReferenceRecordExist;

- (id)initWithFieldName:(NSString *)fName
                  value:(NSString *)fValue
        andDisplayValue:(NSString *)dValue;
@end
