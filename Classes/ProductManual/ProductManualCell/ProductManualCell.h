//
//  TroubleshootingCell.h
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductManualCell : UITableViewCell
{
    IBOutlet UILabel * cellLabel;
    IBOutlet UIImageView * cellImage;
}

- (void) setCellLabel:(NSString *)_label Image:(NSString *)_image;

@end
