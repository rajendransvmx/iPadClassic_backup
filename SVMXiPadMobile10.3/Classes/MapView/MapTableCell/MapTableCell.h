//
//  MapTableCell.h
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapTableCell : UITableViewCell
{
    IBOutlet UIImageView * cellImage;
    IBOutlet UITextView * cellText;
    IBOutlet UILabel * cellLabel;
}

- (void) setCellLabel:(NSString *)_label Color:(UIColor *)_image Timing:(NSString *)timing;
- (void) setEventColor:(UIColor *)color;


@end
