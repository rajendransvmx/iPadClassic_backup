//
//  EditableCellValidator.h
//  ServiceMaxiPad
//
//  Created by Shubha S on 25/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditableDataValidator : NSObject

+(BOOL)validateNumberString:(NSString*)string inParentString:(NSString*)string withRange:(NSRange)range andDataType:(NSString*)
dataType;

@end
