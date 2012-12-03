//
//  WorkPerformedCellView.h
//  iService
//
//  Created by Samman Banerjee on 08/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WorkPerformedCellView : UIView
//@interface WorkPerformedCellView : UITextView
{
    IBOutlet UILabel * workPerformed;
}

@property (nonatomic, retain) IBOutlet UILabel * workPerformed;

@end
