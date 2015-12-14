//
//  AlertViewHandler.h
//  ServiceMaxiPad
//
//  Created by Chinna Babu on 14/12/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertViewHandler : NSObject

- (void)showAlertViewWithTitle:(NSString *)title
                       Message:(NSString *)messaage
                      Delegate:(id)delegate
                  cancelButton:(NSString *)cancelButton
                andOtherButton:(NSString *)otherButton;

@end
