//
//  SFMPageHeaderViewController.m
//  ServiceMaxMobile
//
//  Created by Aparna on 10/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageLayoutViewController.h"
#import "SFMPageFieldCollectionViewCell.h"
#import "SFMPage.h"
#import "SFMHeaderSection.h"
#import "SFMHeaderLayout.h"
#import "SFMPageField.h"
#import "SFMRecordFieldData.h"
#import "SFMPageFieldCollectionHeaderView.h"
#import "StyleGuideConstants.h"
#import "SFMPageFieldCollectionViewCell.h"

#import "SFMPageViewController.h"
#import "NSString+StringUtility.h"
//#import "Utility.h"

#import "MorePopOverViewController.h"
#import "StringUtil.h"

#import "SFMPageViewManager.h"
#import "ContactInfo.h"

#import "PushNotificationHeaders.h"



NSString *const kHeaderViewIdentifier = @"HeaderIdentifier";
NSString *const kCellIdentifier = @"CellIdentifier";
NSString *const kReferenceCellIdentifier = @"ReferenceCellIdentifier";

@interface SFMPageLayoutViewController ()


@end

@implementation SFMPageLayoutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.shouldScrollContent = YES;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect collectionViewFrame = self.view.frame;
    collectionViewFrame.origin.x = 10;
    collectionViewFrame.size.width = self.view.frame.size.width - 20;
    collectionViewFrame.origin.y = 10;
    collectionViewFrame.size.height = self.view.frame.size.height - 20;
    self.pageCollectionView.frame = collectionViewFrame;
    self.pageCollectionView.backgroundColor = [UIColor clearColor];
    /*Register classed used for cell and section header*/
    [self.pageCollectionView registerClass:[SFMPageFieldCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self.pageCollectionView registerClass:[SFMPageFieldCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewIdentifier];
    
    [self.pageCollectionView registerClass:[SFMPageReferenceFieldCollectionViewCell class] forCellWithReuseIdentifier:kReferenceCellIdentifier];

    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)[self.pageCollectionView collectionViewLayout];
    flowLayout.minimumLineSpacing = 15.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.pageCollectionView.scrollEnabled = self.shouldScrollContent;
    
    [self registerForPopOverDismissNotification];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self adjustHeightOfCollectionView];

}

- (void)adjustHeightOfCollectionView
{
    CGFloat height = self.pageCollectionView.contentSize.height;
    CGFloat maxHeight = self.pageCollectionView.superview.frame.size.height - self.pageCollectionView.frame.origin.y;
    
    if (height > maxHeight)
        height = maxHeight;
    
    CGRect frame = self.pageCollectionView.frame;
    frame.size.height = height;
    self.pageCollectionView.frame = frame;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) loadSFMPage:(SFMPageViewModel *)page
          withFields:(NSArray *)pageFields
{
    self.sfmPageView = page;
    self.pageFields = pageFields;

}


#pragma mark -
#pragma mark UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.pageFields count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFMPageField *pageField = [self.pageFields objectAtIndex:indexPath.item];
    SFMRecordFieldData *recordData = [self getValueForField:pageField.fieldName];
    
    [self formatNumericField:pageField recordData:recordData];
   // double val =   recordData.internalValue.doubleValue;
    SFMPageFieldCollectionViewCell *cell;
    
    if ([pageField.dataType isEqualToString:kSfDTReference] && (![pageField.fieldName isEqualToString:kSfDTRecordTypeId])) {
        
        cell = (SFMPageReferenceFieldCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:kReferenceCellIdentifier forIndexPath:indexPath];
        if (nil == cell) {
            cell = [[SFMPageReferenceFieldCollectionViewCell alloc] init];
        }
        [((SFMPageReferenceFieldCollectionViewCell *)cell) setDelegate:self];
        
        [((SFMPageReferenceFieldCollectionViewCell *)cell) isRefernceRecordExist:recordData.isReferenceRecordExist];
        [((SFMPageReferenceFieldCollectionViewCell *)cell) setIndex:indexPath.item];
//        NSLog(@"===============================Page %@= Reference = %d", pageField.fieldName, recordData.isReferenceRecordExist);
        
        
        NSArray *fieldNames = [self.sfmPageView.contactInfoDict allKeys];
        
        if ([fieldNames containsObject:pageField.fieldName]) {
            [self addMailAndMeaasageForContactField:(SFMPageReferenceFieldCollectionViewCell *)cell
                                         fieldValue:recordData.displayValue];
        }

    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
        if (nil == cell) {
            cell = [[SFMPageFieldCollectionViewCell alloc] init];
        }
    }
    
    cell.fieldApiName = pageField.fieldName;
    
    cell.fieldName.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    cell.fieldName.textColor = [UIColor grayColor];
    cell.fieldName.text = pageField.label;
    cell.fieldName.backgroundColor = [UIColor clearColor];

    cell.fieldValue.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize16];
    cell.fieldValue.backgroundColor = [UIColor clearColor];//HS 12 Jan
    cell.fieldValue.text = recordData.displayValue;

    if ([StringUtil isStringEmpty:recordData.displayValue ]) {
        cell.fieldValue.text = @"--";
    }
    cell.fieldValue.lineBreakMode = NSLineBreakByClipping;
    cell.fieldValue.numberOfLines = 1;
    //get text width, if it is greater than cell width show text in popover
    
    if ([pageField.dataType isEqualToString:kSfDTReference] && recordData.isReferenceRecordExist) {
        cell.fieldValue.lineBreakMode = NSLineBreakByTruncatingTail;//HS 12 Jan
        //cell.fieldValue.lineBreakMode = NSLineBreakByClipping;//HS 12 Jan
        cell.fieldValue.backgroundColor = [UIColor clearColor];
       // NSLog(@"frame of fieldValue in controller is %@",NSStringFromCGRect(cell.fieldValue.frame) );
        //HS 12 Jan
    }
    else{
        CGSize textSize =  [StringUtil getSizeOfText:recordData.displayValue withFont:cell.fieldValue.font];
        
        if (textSize.width > cell.fieldValue.frame.size.width || [recordData.displayValue custContainsString:@"\n"]) {
            
            //reduce the with field value labe to accommadate button
            cell.isShowMoreButton = YES;
           
            [cell resetLayout]; //HS 12 Nov
            //add gradient effect to the label. TO:DO need to add image once we get it
            // [self addGradientEffectForLabel:cell.fieldValue];
        }
        [cell.moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    

    return cell;
}

-(void)formatNumericField:(SFMPageField*)pageField recordData:(SFMRecordFieldData *)recordField{
    
    if(!([StringUtil isStringEmpty:recordField.internalValue])
       && ([pageField.dataType isEqualToString:kSfDTCurrency]  //Except integer for other numberfields should consider.
           || [pageField.dataType isEqualToString:kSfDTDouble]
           || [pageField.dataType isEqualToString:kSfDTPercent])){
        
        double value = recordField.internalValue.doubleValue;
        NSString * finalValue  = [[NSString alloc] initWithFormat:@"%.*f",pageField.scale.intValue,value];
        

        recordField.internalValue = finalValue;
        recordField.displayValue = finalValue;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SFMPageFieldCollectionHeaderView *headerView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        headerView = (SFMPageFieldCollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewIdentifier forIndexPath:indexPath];
        headerView.titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize20];
    }
    return headerView;
}


#pragma mark -
#pragma mark UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout Methods


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
     [self.pageCollectionView.collectionViewLayout invalidateLayout];
//    [self.pageCollectionView performBatchUpdates:nil completion:nil];
    if (self.popOver) {
        [self.popOver dismissPopoverAnimated:YES];
    }
}


#pragma mark - button action

- (void)moreButtonClicked:(id)sender
{
    UIButton *tempButton = (UIButton*)sender;
    UIView * cellContentView = [tempButton superview];
    SFMPageFieldCollectionViewCell *cell = (SFMPageFieldCollectionViewCell*) [cellContentView superview];
    MorePopOverViewController *morePopoverController = [[MorePopOverViewController alloc]init];
    self.popOver = [[UIPopoverController alloc] initWithContentViewController:morePopoverController];
    [self.popOver presentPopoverFromRect:tempButton.frame inView:tempButton.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    morePopoverController.fieldNameLabel.text = cell.fieldName.text;
    morePopoverController.fieldValueTextView.text = cell.fieldValue.text;
}

-(SFMRecordFieldData *)getValueForField:(NSString *)fieldApiName
{
    return nil;
    
}
#pragma mark - private method

- (void)addGradientEffectForLabel:(UILabel*)label
{
    CGSize textSize = [StringUtil getSizeOfText:label.text withFont:label.font];
    
    if (textSize.width > label.frame.size.width) {
        
        CAGradientLayer *gradLayer=[CAGradientLayer layer];
        gradLayer.frame = label.layer.bounds;
        
        [gradLayer setColors:[NSArray arrayWithObjects:(id)([UIColor blackColor].CGColor), (id)([UIColor clearColor].CGColor),nil]];
        gradLayer.startPoint = CGPointMake(0.0, 0.0);
        gradLayer.endPoint = CGPointMake(1.0, 0.0);
        label.layer.mask = gradLayer;
        
    } else {
        label.layer.mask = nil;
    }
}
#pragma mark - END

- (void)addMailAndMeaasageForContactField:(SFMPageReferenceFieldCollectionViewCell *)cell fieldValue:(NSString *)value
{
    if ([value length] > 0){
        
        [cell configureCellForContext:ContactSubviewTypeBoth];
    }
}

-(void)showSFMPageViewForRerenceField:(NSInteger)index
{
    SFMPageField *pageField = [self.pageFields objectAtIndex:index];
    SFMRecordFieldData *recordData = [self getValueForField:pageField.fieldName];
    
    if ([recordData.internalValue length] > 0) {
        
        SFMPageViewController *pageView = [[SFMPageViewController alloc] init];
        SFMPageViewManager *pageManager = [[SFMPageViewManager alloc] initWithObjectName:pageField.relatedObjectName recordId:recordData.internalValue];
        
        NSString *localId = [pageManager getLocalIdForSFID:recordData.internalValue objectName:pageField.relatedObjectName];
        
        if ([localId length] > 0) {
            pageManager.recordId = localId;
            pageView.sfmPageView = [pageManager sfmPageView];
            [self.navigationController pushViewController:pageView animated:YES];
        }
    }
    
}

- (void)openContactMeaageOrMail:(id)sender fieldName:(NSString *)fieldName
{
    UIButton *button = (UIButton *)sender;
    
    
    ContactInfo *model = [self.sfmPageView.contactInfoDict objectForKey:fieldName];
    
    if (button.tag == 888) {
        NSString *contactNumber  = model.contactNUmber;
        NSString *cleanedtelStr = [[contactNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
        
        NSString *chatStr = [NSString stringWithFormat:@"sms://%@",cleanedtelStr];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:chatStr]];
    }
    else {
        NSString *mail  = model.contactMail;
        NSString *mailStr = [NSString stringWithFormat:@"mailto:%@",mail];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailStr]];
        
    }
}

- (CGFloat)contentViewHeight
{
    /*Subclass must override this method*/
    return 0;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self adjustHeightOfCollectionView];
}

- (void)resetViewPage:(SFMPageViewModel*)sfmViewPageModel
{
    self.sfmPageView = sfmViewPageModel;
    [self.pageCollectionView reloadData];
}

-(void)registerForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissPopoverPageLayout)
                                                 name:POP_OVER_DISMISS
                                               object:nil];
}

-(void)deregisterForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POP_OVER_DISMISS object:nil];
}

- (void)dismissPopoverPageLayout
{
    [self performSelectorOnMainThread:@selector(dismissPopoverIfNeeded) withObject:self waitUntilDone:YES];
}


- (void)dismissPopoverIfNeeded
{
    if ([self.popOver isPopoverVisible] &&
        self.popOver) {
        
        [self.popOver dismissPopoverAnimated:YES];
        self.popOver = nil;
    }
}

-(void)dealloc{
    
    [self deregisterForPopOverDismissNotification];
}


@end
