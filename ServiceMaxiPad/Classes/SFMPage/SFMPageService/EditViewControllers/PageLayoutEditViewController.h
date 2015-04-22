//
//  PageLayoutEditViewController.h
//  ServiceMaxMobile
//
//  Created by shravya on 30/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PageEditDetailViewController.h"
#import "ChildEditViewController.h"
#import "SFMCollectionViewCell.h"
#import "PageEditControlHandler.h"
#import "SFMPageEditManager.h"

@interface PageLayoutEditViewController : ChildEditViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,SFMCollectionViewCellDelegate,PageEditControlDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *pageLayoutCollectionView;
@property (strong, nonatomic) PageEditControlHandler    *pageEditControlHandler;

- (CGFloat)heightForEachDataType:(NSString *)dataType;
- (void)reloadDataAsync ;

@end
