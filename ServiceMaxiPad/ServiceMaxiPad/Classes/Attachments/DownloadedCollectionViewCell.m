//
//  DownloadedCollectionViewCell.m
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/6/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DownloadedCollectionViewCell.h"
#import "StyleManager.h"
@implementation DownloadedCollectionViewCell

@synthesize datelbl;
@synthesize imageIcon;
@synthesize videoIcon;
@synthesize bottomBar;
@synthesize selectedIcon;
@synthesize isEdtingEnable;

-(void)initialSetUP{
    }
-(void)setBackgroundImage{
}
-(void)setBottomBar{
    bottomBar.backgroundColor=[UIColor colorWithHexString:@"000000"];
    bottomBar.alpha=0.50f;
}
-(void)setFileSize{
    [self setFont:datelbl];
}
-(void)setFont:(UILabel *)label{
    label.font=[UIFont fontWithName:kHelveticaNeueLight size:14.0];
    label.textColor=[UIColor colorWithHexString:@"FFFFFF"];
}
-(void)isVideo:(BOOL)isVideo{
    if (isVideo) {
        videoIcon.hidden=NO;
    }else{
        videoIcon.hidden=YES;
    }
}
-(void)initialSerup:(NSDictionary *)fileInfo IsFilevideo:(BOOL)isFileVideo isEditiable:(BOOL)isEditiable isSelected:(BOOL)isSelected{
    if (isEditiable){
        selectedIcon.hidden=NO;
        if (isSelected) {
            selectedIcon.image=[UIImage imageNamed:@"Attachment-SelectionCheckfilled.png"];
        }else{
            selectedIcon.image=[UIImage imageNamed:@"Attachment-SelectionCheckempty.png"];
        }
    }
    else{
        selectedIcon.hidden=YES;
    }
    
    [self setBackgroundImage];
    [self setBottomBar];
    [self setFileSize];
    [self isVideo:isFileVideo];

}
@end
