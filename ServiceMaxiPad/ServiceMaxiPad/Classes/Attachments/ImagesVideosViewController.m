//
//  ImagesVideosViewController.m
//  ServiceMaxiPad
//
//  Created by Anoop on 10/27/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ImagesVideosViewController.h"
#import "DownloadedCollectionViewCell.h"
#import "NonDownloadedCollectionViewCell.h"
#import "AttachmentHelper.h"

@interface ImagesVideosViewController ()

@end

@implementation ImagesVideosViewController

@synthesize collectionView;
@synthesize imageAndVideoView;
@synthesize editProcessHeaderView;
@synthesize IsEdtiable;
@synthesize editProcessHeaderLabel;
@synthesize documentArray;
@synthesize parentId;
@synthesize localDictinory;

static NSString *const kDownloadedCollectionViewCell = @"DownloadedCollectionViewCell";
static NSString *const kNonDownloadedCollectionViewCell = @"NonDownloadedCollectionViewCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.documentArray=[AttachmentHelper getImagesAndVideosAttachmentsLinkedToParentId:self.parentId];
    [self.collectionView registerNib:[UINib nibWithNibName:kDownloadedCollectionViewCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kDownloadedCollectionViewCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kNonDownloadedCollectionViewCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kNonDownloadedCollectionViewCell];
    self.collectionView.delegate = self;
    self.collectionView.dataSource= self;
    editProcessHeaderView.hidden=YES;
    IsEdtiable=NO;
    [self localCellSelection];
    self.collectionView.backgroundColor=[UIColor whiteColor];
}
-(void)localCellSelection{
    localDictinory=[[NSMutableDictionary alloc] init];
    [self refreshHeaderTitle:0];
    for (int i=0; i<=100; i++) {
        [localDictinory setValue:@"0" forKey:[NSString stringWithFormat:@"%d",i]];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    //NSArray* sectionArray = [_data objectAtIndex:section];
    return 100;//[documentArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row]%2==0) {
        DownloadedCollectionViewCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kDownloadedCollectionViewCell forIndexPath:indexPath];
        newCell.datelbl.text=@"12-12-2014";
        if ([[localDictinory objectForKey:[NSString stringWithFormat:@"%d",[indexPath row]]] isEqualToString:@"0"]) {
            [newCell initialSerup:nil IsFilevideo:YES isEditiable:IsEdtiable isSelected:NO];
        }else{
            [newCell initialSerup:nil IsFilevideo:YES isEditiable:IsEdtiable isSelected:YES];
        }
        return newCell;
    }else{
        NonDownloadedCollectionViewCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kNonDownloadedCollectionViewCell forIndexPath:indexPath];
        [newCell initialSerup:nil Iserror:NO];
        newCell.fileNamelbl.text=@"An_Average_Filename.jpg";
        newCell.fileSizelbl.text=@"3.5 MB";
        newCell.selected=NO;
        return newCell;
    }
}
- (void)collectionView:(UICollectionView *)collectionViewLoc didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionViewLoc cellForItemAtIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionViewLoc didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionViewLoc cellForItemAtIndexPath:indexPath];
}
- (BOOL)collectionView:(UICollectionView *)collectionViewLoc shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionViewLoc didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    if (IsEdtiable) {
        if ([[localDictinory objectForKey:[NSString stringWithFormat:@"%d",[indexPath row]]] isEqualToString:@"0"]) {
            [localDictinory setValue:@"1" forKey:[NSString stringWithFormat:@"%d",[indexPath row]]];
        }else{
            [localDictinory setValue:@"0" forKey:[NSString stringWithFormat:@"%d",[indexPath row]]];
        }
        [collectionViewLoc reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[indexPath row] inSection:0]]];
        [self updateShereAndDeleteButton];
    }
    
}

- (IBAction)selectAction:(UIButton *)sender{
    imageAndVideoView.hidden=YES;
    editProcessHeaderView.hidden=NO;
    IsEdtiable=true;
    //[self refreshHeaderTitle:[self.collectionView sele]];
    [self localCellSelection];
    [self.collectionView reloadData];
}
-(void)refreshHeaderTitle:(int)selectedItems{
    editProcessHeaderLabel.text=[NSString stringWithFormat:@"%d Items Selected",selectedItems];
}
- (IBAction)cancelAction:(UIButton *)sender{
    imageAndVideoView.hidden=NO;
    editProcessHeaderView.hidden=YES;
    IsEdtiable=NO;
   // [self refreshHeaderTitle:[self.collectionView numberOfSections]];
    [self localCellSelection];
    [self.collectionView reloadData];
}
- (IBAction)shareAction:(UIButton *)sender{
    
}
- (IBAction)deleteAction:(UIButton *)sender{
    
}
-(int )numberOfSelectedItem{
    int count=0;
    for (int i=0; i<=100; i++) {
        if ([[localDictinory objectForKey:[NSString stringWithFormat:@"%d",i]] integerValue]==1) {
            count++;
        }
    }
    return count;
}
-(void)updateShereAndDeleteButton{
    int numberOfselectedItem=[self numberOfSelectedItem];
     [self refreshHeaderTitle:numberOfselectedItem];
    if (numberOfselectedItem>0) {
        [self.shareButton setSelected:YES];
        [self.deleteButton setSelected:YES];
    }else{
        [self.shareButton setSelected:NO];
        [self.deleteButton setSelected:NO];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
