//
//  Item.m
//  iServiceHomeScreen
//
//  Created by Aparna on 09/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//

#import "Item.h"

@implementation Item

@synthesize detailedDescription;
@synthesize title;
@synthesize icon;


- (id)initWithTitle:(NSString *)theTitle
        description:(NSString *)theDescription
               icon:(UIImage *)theIcon
{
    self = [super init];
    if(self)
    {
        self.title = theTitle;
        self.detailedDescription = theDescription;
        self.icon = theIcon;
    }
    return self;
}

- (void)dealloc
{
    self.title = nil;
    self.detailedDescription = nil;
    self.icon = nil;
    [super dealloc];
}

@end
