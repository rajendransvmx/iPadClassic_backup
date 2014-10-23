//
//  TextFieldHelperDelegate.h
//  ServiceMaxiPad
//
//  Created by shravya on 14/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextField.h"

@interface TextFieldHelperDelegate : NSObject <UITextFieldDelegate,UITextViewDelegate>

@property (weak)    TextField *containerTextField;

@end
