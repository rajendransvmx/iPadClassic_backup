//
//  MySegmentedControl.h
//  iService
//
//  Created by Parashuram on 20/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySegmentedControl : UISegmentedControl
{
    NSIndexPath *myIndexPath;
}


@property (nonatomic, assign) NSIndexPath *myIndexPath;

@end
