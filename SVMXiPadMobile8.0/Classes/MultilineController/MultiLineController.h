//
//  MultiLineController.h
//  ManualDataSyncUI
//
//  Created by Parashuram on 11/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultiLineController : UISegmentedControl
{
    BOOL initialized;

}

- (void)setSubTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;

@end
