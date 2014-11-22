
//
//  TextCell.m
//  MapPopUp
//
//  Created by Anoop on 9/8/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TextCell.h"

@implementation TextCell

- (id)debugQuickLookObject
{
    NSAttributedString *cr = [[NSAttributedString alloc] initWithString:@"\n"];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:self.titleLabel.attributedText];
    [result appendAttributedString:cr];
    [result appendAttributedString:self.descriptionLabel.attributedText];
    return result;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.descriptionLabel.frame);
}

- (void)configureCellWithTitle:(NSString*)titleString
                andDescription:(NSString*)descriptionString {
    [self cleanUp];
    self.descriptionLabel.text = descriptionString;
    self.titleLabel.text = titleString;
}

- (void)cleanUp {
    
    self.descriptionLabel.text = nil;
    self.titleLabel.text = nil;
    
}

@end