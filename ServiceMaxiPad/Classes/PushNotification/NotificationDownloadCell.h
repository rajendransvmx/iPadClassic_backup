//
//  NotificationDownloadCell.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 06/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationDownloadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *progressStatusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *requestDescription;
@property (weak, nonatomic) IBOutlet UILabel *requestTitle;

@end
