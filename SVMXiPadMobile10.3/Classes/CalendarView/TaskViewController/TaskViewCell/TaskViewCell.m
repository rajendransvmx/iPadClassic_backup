//
//  TaskViewCell.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 21/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TaskViewCell.h"


@implementation TaskViewCell

- (void) setTask:(NSString *)task
{
    taskLabel.text = task;
}

- (void)dealloc
{
    [taskLabel release];
    [super dealloc];
}


@end
