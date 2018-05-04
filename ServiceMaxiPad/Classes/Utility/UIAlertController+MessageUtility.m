//
//  UIAlertController+MessageUtility.m
//  ServiceMaxiPad
//
//  Created by Vincent Sagar on 04/05/18.
//  Copyright © 2018 ServiceMax Inc. All rights reserved.
//

#import "UIAlertController+MessageUtility.h"

@implementation UIAlertController (MessageUtility)
@dynamic messageLabel;

/* Return the subviews of UIAlertController */
- (NSArray *)viewAlertSubViewArray:(UIView *)root {
    static NSArray *_subviews = nil;
    _subviews = nil;
    for (UIView *alert in root.subviews) {
        if (_subviews) {
            break;
        }
        if ([alert isKindOfClass:[UILabel class]]) {
            _subviews = root.subviews;
            return _subviews;
        }
        [self viewAlertSubViewArray:alert];
    }
    return _subviews;
}
/* Accessing the message label */
- (UILabel *)messageLabel {
    return [self viewAlertSubViewArray:self.view][1];
}
@end
