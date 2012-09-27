//
//  CustomTableViewCell.h
//  TabView
//
//  Created by Siva Manne on 30/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UILabel *nameField;
@property (nonatomic, retain) IBOutlet UILabel *sizeField;
@property (nonatomic, retain) IBOutlet UILabel *nameStringName;
@property (nonatomic, retain) IBOutlet UILabel *sizeStringName;
@property (nonatomic, retain) IBOutlet UIImageView *imageField;
@end
