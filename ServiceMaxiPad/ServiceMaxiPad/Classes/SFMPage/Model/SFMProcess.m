//
//  SFMProcess.m
//  ServiceMaxMobile
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMProcess.h"
#import "SFProcessComponentModel.h"

@implementation SFMProcess

- (id)initWithDictionary:(NSDictionary *)dictionary{
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (SFProcessComponentModel *)getProcessComponentOfType:(NSString *)type{
    
    for (NSString *key in self.component) {
        SFProcessComponentModel *model = [self.component objectForKey:key];
        if ([model.componentType isEqualToString:type]) {
            return model;
        }
    }
    return nil;
}

@end
