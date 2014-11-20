//
//  SMRegularAlertView.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 17/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SMAlertView.h"


@interface SMRegularAlertView : SMAlertView
{
}


- (id)initWithTitle:(NSString *)title
           delegate:(id<SMAlertViewDelegate>)alertViewDelegate
           messages:(NSArray *)messages
       cancelButton:(NSString *)cancelButtonTitle
        otherButton:(NSString *)otherButtonTitle;

@end
