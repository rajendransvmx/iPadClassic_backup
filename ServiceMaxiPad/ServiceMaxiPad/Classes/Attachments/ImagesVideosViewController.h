//
//  ImagesVideosViewController.h
//  ServiceMaxiPad
//
//  Created by Anoop on 10/27/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagesVideosViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource>
{
    IBOutlet UICollectionView *collectionView;
    
}
@property (strong, nonatomic) IBOutlet UILabel *editProcessHeaderLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *parentObjectName;
@property (nonatomic, copy) NSString *parentSFObjectName;
@property (strong, nonatomic) IBOutlet UIView *editProcessHeaderView;
@property (strong, nonatomic) IBOutlet UIView *imageAndVideoView;
@property (nonatomic,assign) BOOL IsEdtiable;
@property (nonatomic ,strong) NSMutableArray *documentArray;
@property (nonatomic,strong) NSMutableDictionary *localDictinory;

- (IBAction)selectAction:(UIButton *)sender;
- (IBAction)cancelAction:(UIButton *)sender;
- (IBAction)shareAction:(UIButton *)sender;
- (IBAction)deleteAction:(UIButton *)sender;
@end
