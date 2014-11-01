//
//  SFMPageChildLayoutViewController.m
//  ServiceMaxMobile
//
//  Created by Aparna on 15/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageChildLayoutViewController.h"
#import "SFMDetailLayout.h"
#import "SFMPageFieldCollectionHeaderView.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"


@interface SFMPageChildLayoutViewController ()

@property(nonatomic, strong)SFMDetailLayout *pageDetailLayout;

@end

@implementation SFMPageChildLayoutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    self = [super initWithNibName:@"SFMPageLayoutViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = self.pageCollectionView;
    
    self.pageCollectionView.delegate = self;
    self.pageCollectionView.dataSource = self;
    self.pageCollectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;

    NSArray *detailLayouts = self.sfmPageView.sfmPage.process.pageLayout.detailLayouts;
    if ([detailLayouts count]>self.selectedSection) {
        self.pageDetailLayout = [self.sfmPageView.sfmPage.process.pageLayout.detailLayouts objectAtIndex:self.selectedSection];
    }
    
    self.pageCollectionView.scrollEnabled = NO;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)[self.pageCollectionView collectionViewLayout];
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.footerReferenceSize = CGSizeZero;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 30, 0, 10);
    
    //[self setLeftBorder];

}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setLeftBorder];
}

- (void)setLeftBorder
{
    CALayer *leftBorder = [CALayer layer];
    leftBorder.borderColor = [UIColor colorWithHexString:kSeperatorLineColor].CGColor;
    leftBorder.borderWidth = 1;
    leftBorder.frame = CGRectMake(0, 0, 1.0, CGRectGetHeight(self.pageCollectionView.bounds));
    [self.pageCollectionView.layer addSublayer:leftBorder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    UIEdgeInsets edgeInsets = flowLayout.sectionInset;
    
    CGFloat cellWidth = self.pageCollectionView.frame.size.width;
    return CGSizeMake(cellWidth - edgeInsets.left - edgeInsets.right,FlowLayoutItemHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}


- (CGFloat)contentViewHeight
{
    CGFloat collectionViewHeight = 0.0;
    
    int sectionCount = [self numberOfSectionsInCollectionView:self.pageCollectionView];
    for (int sectionIndex=0; sectionIndex<sectionCount; sectionIndex++) {
        int itemCount =  [self.pageFields count];
        collectionViewHeight += FlowLayoutHeaderReferenceHeight+FlowLayoutFooterReferenceHeight+ FlowLayoutSectionTopInset+FlowLayoutSectionBottomInset;
        for (int itemIndex=0; itemIndex<itemCount; itemIndex++) {
            collectionViewHeight += FlowLayoutItemHeight  + FlowLayoutMinimumLineSpacing ;        }
    }
    return collectionViewHeight;
}

-(SFMRecordFieldData *)getValueForField:(NSString *)fieldApiName
{
    SFMRecordFieldData * recordField = nil;
    if (fieldApiName != nil) {
        
        NSMutableDictionary * detailDict =  self.sfmPageView.sfmPage.detailsRecord;
        NSArray * detailRecords = [detailDict objectForKey: self.pageDetailLayout.processComponentId];
        
        if( self.selectedRecord  < [detailRecords count] )
        {
            NSDictionary * recordDict = [detailRecords objectAtIndex:self.selectedRecord];
            recordField = [recordDict objectForKey:fieldApiName];
        }
    }

    return recordField;
}



@end
