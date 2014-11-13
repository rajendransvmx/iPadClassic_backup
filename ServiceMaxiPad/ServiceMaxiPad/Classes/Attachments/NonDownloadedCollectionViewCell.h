//
//  NonDownloadedCollectionViewCell.h
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/6/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NonDownloadedCollectionViewCell : UICollectionViewCell{
   
}
@property(nonatomic,strong)IBOutlet UILabel *fileNamelbl;
@property(nonatomic,strong)IBOutlet UILabel *fileSizelbl;
@property(nonatomic,strong)IBOutlet UILabel *errorlbl;
@property(nonatomic,strong)IBOutlet UIImageView *imageIcon;
@property(nonatomic,strong)IBOutlet UIImageView *videoIcon;
@property(nonatomic,strong)IBOutlet UIProgressView *progressView;
-(void)initialSetUP;
-(void)errorCell:(BOOL)isError;
-(void)initialSerup:(NSDictionary *)fileInfo Iserror:(BOOL)isFileError;
@end
