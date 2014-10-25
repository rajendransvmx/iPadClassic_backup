//
//  SFMPageHeaderViewController.h
//  ServiceMaxMobile
//
//  Created by Aparna on 10/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMPageViewModel.h"
#import "MorePopOverViewController.h"
#import "SFMPageReferenceFieldCollectionViewCell.h"


#define FlowLayoutHeaderReferenceHeight    0
#define FlowLayoutFooterReferenceHeight    0
#define FlowLayoutSectionTopInset          0
#define FlowLayoutSectionBottomInset       0
#define FlowLayoutItemHeight               40
#define FlowLayoutMinimumLineSpacing       15.0


extern NSString *const kHeaderViewIdentifier ;
extern NSString *const kCellIdentifier ;

@interface SFMPageLayoutViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, SFMPageReferenceFieldDedegate>

@property(nonatomic, strong) IBOutlet UICollectionView *pageCollectionView;
//@property(nonatomic, strong) SFMPage *sfmPage;
@property(nonatomic, strong) SFMPageViewModel *sfmPageView;
@property(nonatomic, strong) NSArray *pageFields;
@property(nonatomic, assign)NSUInteger selectedSection;
@property (nonatomic, assign)BOOL shouldScrollContent;
@property(nonatomic, strong) UIPopoverController * popOver;


- (void) loadSFMPage:(SFMPage *)page
          withFields:(NSArray *)pageFields;

-(SFMRecordFieldData *)getValueForField:(NSString *)fieldApiName;
- (CGFloat) contentViewHeight;

@end


