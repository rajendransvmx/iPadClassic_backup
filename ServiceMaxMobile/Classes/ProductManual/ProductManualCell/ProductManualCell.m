//
//  TroubleshootingCell.m
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProductManualCell.h"


@implementation ProductManualCell

- (void) setCellLabel:(NSString *)_label Image:(NSString *)_image
{
    cellLabel.text = _label;
    cellImage.image = [UIImage imageNamed:_image];
}

- (void)dealloc {
    [super dealloc];
}


@end
