//
//  SFMPageHeaderLayoutViewController.m
//  ServiceMaxMobile
//
//  Created by Aparna on 15/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageHeaderLayoutViewController.h"
#import "SFMHeaderSection.h"
#import "SFMPageFieldCollectionHeaderView.h"
#import "StyleGuideConstants.h"
#import "StringUtil.h"
#import "StyleManager.h"
#import "TagManager.h"

#define HeaderFlowLayoutHeaderReferenceHeight    40.0
#define HeaderFlowLayoutFooterReferenceHeight    0
#define HeaderFlowLayoutSectionTopInset          10.0
#define HeaderFlowLayoutSectionBottomInset       10.0


@interface SFMPageHeaderLayoutViewController ()

@property(nonatomic, strong) SFMHeaderSection *pageHeaderSection;

@end

@implementation SFMPageHeaderLayoutViewController

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
    self.pageCollectionView.delegate = self;
    self.pageCollectionView.dataSource = self;
    
    [self setUpPageHeaderSection];
    
    // Do any additional setup after loading the view.
}

-(void)setUpPageHeaderSection
{
    NSArray *sectionsArray = self.sfmPageView.sfmPage.process.pageLayout.headerLayout.sections;
    
    if ([sectionsArray count]>self.selectedSection) {
        if(self.pageHeaderSection == nil)
        {
            self.pageHeaderSection = [self.sfmPageView.sfmPage.process.pageLayout.headerLayout.sections objectAtIndex:self.selectedSection];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.pageCollectionView.layer.borderColor = [UIColor colorWithHexString:kSeperatorLineColor].CGColor;
    self.pageCollectionView.layer.borderWidth = 1.0;
    self.pageCollectionView.layer.cornerRadius = 5.00;

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
    
    int columnCount = (int)[self.pageHeaderSection noOfColumns];
    CGFloat cellWidth = self.pageCollectionView.frame.size.width;
    if (columnCount > 0)
    {
        cellWidth = self.pageCollectionView.frame.size.width/columnCount;
    }
    return CGSizeMake(cellWidth - edgeInsets.left - edgeInsets.right,FlowLayoutItemHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SFMPageFieldCollectionHeaderView *headerView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        headerView = (SFMPageFieldCollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewIdentifier forIndexPath:indexPath];
        headerView.titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize20];
        if ([StringUtil isStringEmpty:self.pageHeaderSection.title]) {
            headerView.titleLabel.text = [[TagManager sharedInstance]tagByName:kTagInformation];

        }
        else{
            headerView.titleLabel.text = self.pageHeaderSection.title;

        }
    }
    return headerView;
}

- (CGFloat)contentViewHeight
{
    [self setUpPageHeaderSection];
    CGFloat collectionViewHeight = 0.0;
    int sectionCount = (int)[self numberOfSectionsInCollectionView:self.pageCollectionView];
    
    for (int sectionIndex=0; sectionIndex<sectionCount; sectionIndex++) {
        int itemCount = (int)[self.pageFields count];
        int columnCount = (int)[self.pageHeaderSection noOfColumns];
        NSInteger rowCount = itemCount;
        if (columnCount>0) {
            rowCount= itemCount/columnCount;
            
            if ((itemCount%columnCount)!=0)
            {
                rowCount++;
            }
        }
        collectionViewHeight += HeaderFlowLayoutHeaderReferenceHeight+HeaderFlowLayoutFooterReferenceHeight+ HeaderFlowLayoutSectionTopInset+HeaderFlowLayoutSectionBottomInset;
        
        for (int itemIndex=0; itemIndex<rowCount; itemIndex++) {
            collectionViewHeight += FlowLayoutItemHeight  + FlowLayoutMinimumLineSpacing ;       }
        
    }
    return collectionViewHeight;
}




-(SFMRecordFieldData *)getValueForField:(NSString *)fieldApiName;
{
    return [self.sfmPageView.sfmPage getHeaderFieldDataForName:fieldApiName];
}


@end
