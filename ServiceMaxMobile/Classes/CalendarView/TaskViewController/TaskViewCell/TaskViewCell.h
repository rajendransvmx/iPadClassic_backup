//
//  TaskViewCell.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 21/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskViewCell : UITableViewCell
{
    IBOutlet UILabel * taskLabel;
}

- (void) setTask:(NSString *)task;

@end
