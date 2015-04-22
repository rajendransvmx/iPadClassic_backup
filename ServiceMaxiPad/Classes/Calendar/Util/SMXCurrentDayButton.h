//
//  SMXCurrentDayButton.h
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/20/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMXCurrentDayDelegate
    @optional
        -(void)removeCalender;
@end

@interface SMXCurrentDayButton : UIButton <SMXCurrentDayDelegate>{
    id delegate;
}
-(void) setDelegate:(id)newDelegate;
-(void)initialsetup:(UIView *)parent;
@end
