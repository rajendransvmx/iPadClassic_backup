//
//  ContactCell.h
//  MapPopUp
//
//  Created by Anoop on 9/8/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContactImageModel;

@interface ContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) ContactImageModel *contactModel;

- (IBAction)mailButtonTapped:(UIButton *)sender;
- (IBAction)messageButtonTapped:(UIButton *)sender;
- (void)configureCellWithContact:(ContactImageModel*)contactModelObj
                        andTitle:(NSString*)titleString;

@end
