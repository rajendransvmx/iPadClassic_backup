//
//  SMCheckBoxBindedAlertView.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 18/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SMAlertView.h"

@protocol CheckBoxDelegate <SMAlertViewDelegate>
- (void)checkBoxValueChanged:(BOOL)value forKey:(NSString*)key;
@end


@interface SMCheckBoxBindedAlertView : SMAlertView
{
    float   labelHeight;
}



- (id)initWithTitle:(NSString *)title
           delegate:(id<SMAlertViewDelegate>)alertViewDelegate
           messages:(NSArray *)messages
   checkBoxMessages:(NSDictionary *)checkBoxMessages
       cancelButton:(NSString *)cancelButtonTitle
        otherButton:(NSString *)otherButtonTitle;
@end

