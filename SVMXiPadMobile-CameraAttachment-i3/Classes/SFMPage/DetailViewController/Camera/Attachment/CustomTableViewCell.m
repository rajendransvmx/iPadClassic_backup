//
//  CustomTableViewCell.m
//  TabView
//
//  Created by Siva Manne on 30/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "iServiceAppDelegate.h"
@implementation CustomTableViewCell
@synthesize nameField,sizeField,imageField,sizeStringName,nameStringName;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *nameString = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_File_Name];
        NSString *sizeString = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_File_Size];
        nameStringName.text = nameString;
        sizeStringName.text = sizeString;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) dealloc
{
    [nameField release];
    [sizeField release];
    [imageField release];
    [sizeStringName release];
    [nameStringName release];
    [super dealloc];
}
@end
