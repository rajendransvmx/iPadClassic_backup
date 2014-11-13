//
//  DownloadedCollectionViewCell.h
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/6/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadedCollectionViewCell : UICollectionViewCell{
   
}
@property(nonatomic,strong)IBOutlet UILabel *datelbl;
@property(nonatomic,strong)IBOutlet UIImageView *imageIcon;
@property(nonatomic,strong)IBOutlet UIImageView *videoIcon;
@property(nonatomic,strong)IBOutlet UIImageView *bottomBar;
@property (nonatomic ,strong)IBOutlet UIImageView *selectedIcon;
@property (nonatomic,assign)BOOL isEdtingEnable;
-(void)initialSetUP;
-(void)isVideo:(BOOL)isVideo;
-(void)initialSerup:(NSDictionary *)fileInfo IsFilevideo:(BOOL)isFileVideo isEditiable:(BOOL)isEditiable isSelected:(BOOL)isSelected;
@end
