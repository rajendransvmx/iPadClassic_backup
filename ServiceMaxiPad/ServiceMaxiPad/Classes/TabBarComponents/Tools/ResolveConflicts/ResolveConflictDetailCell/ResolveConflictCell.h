//
//  ResolveConflictCell.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 05/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ResolveConflictCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView  *resolutionView;
@property (weak, nonatomic) IBOutlet UILabel *userResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeResolutionLabel;

@property (weak, nonatomic) IBOutlet UIView  *resolveView;
@property (weak, nonatomic) IBOutlet UILabel *resolveLabel;
@property (weak, nonatomic) IBOutlet UILabel *objectLabel;
@property (weak, nonatomic) IBOutlet UILabel *objectNameLabel;

- (void)configureCellForResolve;

- (void)configureCellForResolutionWithUserResolution:(NSString *)resolutionString;

@end
