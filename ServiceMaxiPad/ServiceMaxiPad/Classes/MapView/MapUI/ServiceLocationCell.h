//
//  ServiceLocationCell.h
//  MapPopUp
//
//  Created by Anoop on 9/8/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServiceLocationModel;

@interface ServiceLocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *getDirectionsButton;
@property (weak, nonatomic) ServiceLocationModel *serviceLocationModel;

- (IBAction)getDirectionsButtonTapped:(UIButton *)sender;
- (void)configureCellWithTitle:(NSString*)titleString
            andServiceLocation:(ServiceLocationModel*)serviceLocationModel;


@end
