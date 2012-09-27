//
//  TroubleshootingCell.h
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TroubleshootingCell : UITableViewCell
{
    IBOutlet UILabel * cellLabel;
    IBOutlet UIImageView * cellImage;
    
    BOOL isClicked;
    IBOutlet UIActivityIndicatorView * activity;
}

@property (nonatomic, retain) NSString * troubleshootingFilePath;
@property BOOL isClicked;

- (void) setCellLabel:(NSString *)_label Image:(NSString *)_image;
- (NSString *) getCellLabel;
- (void) startActivity;
- (void) stopActivity;

@end
