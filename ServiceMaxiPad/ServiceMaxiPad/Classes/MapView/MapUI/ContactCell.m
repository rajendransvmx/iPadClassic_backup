//
//  ContactCell.m
//  MapPopUp
//
//  Created by Anoop on 9/8/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "ContactCell.h"
#import "ContactImageModel.h"
#import "TagManager.h"

@implementation ContactCell

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

- (IBAction)mailButtonTapped:(UIButton *)sender
{
    NSString *telString = [NSString stringWithFormat:@"mailto://%@",[self.contactModel.emailString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telString]];
}

- (IBAction)messageButtonTapped:(UIButton *)sender
{
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]])
    {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertWarningError] message:@"Your device does not support sending sms." delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
        [lAlert show];
        lAlert = nil;
        return;
    }
    NSString *cleanedtelStr = [[self.contactModel.mobilePhoneString componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSString *smsString = [NSString stringWithFormat:@"sms://%@",[cleanedtelStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:smsString]];
}

- (void)configureCellWithContact:(ContactImageModel*)contactModelObj
                        andTitle:(NSString*)titleString {
    
    [self cleanUp];
    _contactModel = contactModelObj;
    self.titleLabel.text = titleString;
    self.descriptionLabel.text = self.contactModel.contactName;
    
}

- (void)cleanUp {
    
    self.contactModel = nil;
    self.descriptionLabel.text = nil;
    self.titleLabel.text = nil;

}

@end
