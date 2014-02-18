//
//  DocumentViewCell.h
//  ServiceMaxMobile
//
//  Created by Kirti on 08/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DocumentViewCell : UITableViewCell {
    
    UIImageView *editIconImageView;
    UIImageView *cellTypeImageView;
    UILabel     *titleLabel;
    UILabel     *subTitleLabel;
    UILabel     *leftLabel;
    UIImageView *backGroundImageView;
    UILabel     *progessLabel;
    UILabel     *imageTitleLabel;
    
}

@property(nonatomic,retain)UIImageView *editIconImageView;
@property(nonatomic,retain)UIImageView *cellTypeImageView;
@property(nonatomic,retain)UILabel     *titleLabel;
@property(nonatomic,retain)UILabel     *subTitleLabel;
@property(nonatomic,retain)UILabel     *leftLabel;
@property(nonatomic,retain)UILabel     *progessLabel;
@property(nonatomic,retain)UILabel     *imageTitleLabel;

@end
