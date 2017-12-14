//
//  AlertViewHandler.m
//  ServiceMaxiPad
//
//  Created by Chinna Babu on 14/12/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "AlertViewHandler.h"
#import "SMXConstants.h"


@implementation AlertViewHandler


- (void)showAlertViewWithTitle:(NSString *)title
                       Message:(NSString *)messaage
                      Delegate:(id)delegate
                  cancelButton:(NSString *)cancelButton
                andOtherButton:(NSString *)otherButton
{
    if (SYSTEM_VERSION < 8.0)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
                                                           message:messaage
                                                          delegate:self
                                                 cancelButtonTitle:cancelButton
                                                 otherButtonTitles:otherButton, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView show];
        });
        
        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messaage preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButton style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
            [delegate dismissViewControllerAnimated:YES completion:nil];
            
            
        }];
        
        
        
        [alertController addAction:cancelAction];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate presentViewController:alertController animated:YES completion:nil];
        });
        
    }
    
    
    
}


@end
