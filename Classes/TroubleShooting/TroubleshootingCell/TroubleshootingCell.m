//
//  TroubleshootingCell.m
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TroubleshootingCell.h"


@implementation TroubleshootingCell

@synthesize troubleshootingFilePath;
@synthesize isClicked;

- (void) setCellLabel:(NSString *)_label Image:(NSString *)_image
{
    if ([_label isKindOfClass:[NSString class]])
        cellLabel.text = _label;
    cellImage.image = [UIImage imageNamed:_image];
}

- (NSString *) getCellLabel;
{
    return cellLabel.text;
}

- (void) startActivity
{
    [activity startAnimating];
}

- (void) stopActivity
{
    [activity stopAnimating];
}

- (void)dealloc {
    [super dealloc];
}

@end
