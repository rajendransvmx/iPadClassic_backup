//
//  TableViewCell.h
//  iServiceHomeScreen
//
//  Created by Aparna on 24/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemView.h"



@interface GridViewCell : UITableViewCell

@property(nonatomic, assign) int columnCount;

- (ItemView *) itemViewAtColumn:(int)column;

@end
