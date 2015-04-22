//
//  TaskViewCell.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 21/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TaskViewCell.h"
#import "Utility.h"

@implementation TaskViewCell

- (void) setTask:(NSString *)task
{
    // defect 8515
    if(![Utility notIOS7])
    task=[task stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    taskLabel.text = task;
}

- (void)dealloc
{
    [taskLabel release];
    [super dealloc];
}


@end
