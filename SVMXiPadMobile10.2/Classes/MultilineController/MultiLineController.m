//
//  MultiLineController.m
//  ManualDataSyncUI
//
//  Created by Parashuram on 11/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MultiLineController.h"

@implementation MultiLineController

static NSInteger MY_TAG = 0x666;



-(void)initialize
{
    if (!initialized) {
        
        for (UIView *segmentView in self.subviews) {
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:16];
            label.textAlignment = UITextAlignmentCenter;
            label.tag = MY_TAG;
            [segmentView addSubview:label];
            [label release];
        }
        
        initialized = YES;
    }
}



-(void)layoutSubviews
{
    [super layoutSubviews];
    [self initialize];
    
    for (UIView *segmentView in self.subviews) {
        
        UIView *segmentLabel = [[segmentView subviews] objectAtIndex:0];
        if (segmentLabel) {
            
            UILabel *myLabel = (UILabel *)[segmentView viewWithTag:MY_TAG];
            if (myLabel) {
                
                CGFloat h = [myLabel.font lineHeight];
                
                CGRect f = segmentLabel.frame;
                f.origin.y -= h / 2;
                segmentLabel.frame = f;
                
                f.origin.y += h;
                f.origin.x = 0;
                f.size.width = segmentView.frame.size.width;
                myLabel.frame = f;
            }
        }
    }
}

- (void)setSubTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
    [self layoutSubviews];
    
    for (UIView * segmentView in self.subviews)
    {
        UILabel *segmentLabel = nil;
        for( id view in segmentView.subviews )
        {
            if( [view isKindOfClass:[UILabel class]] )
            {
                segmentLabel = view;
                break;
            }
        }
//        UILabel *segmentLabel = (UILabel *)[[segmentView subviews] objectAtIndex:1];
        if ([segmentLabel.text isEqualToString:[self titleForSegmentAtIndex:segment]])
        {
            
            UILabel *myLabel = (UILabel *)[segmentView viewWithTag:MY_TAG];
            if (myLabel) 
            {
                myLabel.text = title;
				myLabel.font = [UIFont systemFontOfSize:12.0];
				[myLabel setBackgroundColor:[UIColor clearColor]];
				[myLabel setTextColor:[UIColor whiteColor]];
            }
            break;
        }
    }
}


@end
