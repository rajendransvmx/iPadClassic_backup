//
//  SMProgressAlertView.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 17/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SMAlertView.h"

@interface SMProgressAlertView : SMAlertView
{
    float           heightToAdjust;
    UIProgressView  *progressView;
    UILabel         *progresStatus;
}

- (void)updateProgressBarWithValue:(float)value andMessage:(NSString *)message;

- (id)initWithTitle:(NSString *)title
           delegate:(id)alertViewDelegate
           messages:(NSArray *)messages
       cancelButton:(NSString *)cancelButtonTitle
        otherButton:(NSString *)otherButtonTitle;


@end
