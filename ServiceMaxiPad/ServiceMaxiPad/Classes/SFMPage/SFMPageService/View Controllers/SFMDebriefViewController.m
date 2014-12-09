//
//  SFMDebriefViewController.m
//  ServiceMaxMobile
//
//  Created by Sahana on 12/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMDebriefViewController.h"
#import "StyleGuideConstants.h"
#import "SFMPageChildLayoutViewController.h"
#import "ViewControllerFactory.h"
#import "SFMRecordFieldData.h"
//#import "Utility.h"
#import "StyleManager.h"
#import "StringUtil.h"
@interface SFMDebriefViewController ()
@property (nonatomic, strong) NSMutableDictionary * expandedSections;
@end

@implementation SFMDebriefViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.shouldScrollContent = YES;
    }
    return self;
}

- (void)addTableHeaderView
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(self.debriefTableView.bounds.origin.x , self.debriefTableView.bounds.origin.y , self.debriefTableView.frame.size.width , 30)];
    
    UILabel * tableViewTitle = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.origin.x +10 , view.bounds.origin.y , self.debriefTableView.frame.size.width , 30)];
    tableViewTitle.text = [self getTitleForTableView];
    
    tableViewTitle.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
    self.debriefTableView.backgroundColor = [UIColor whiteColor];
    [view addSubview:tableViewTitle];
    self.debriefTableView.tableHeaderView = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.debriefTableView.backgroundColor = [UIColor whiteColor];

    [self addTableHeaderView];
    
    self.debriefTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[self debriefTableView] registerClass:[DebriefSectionView class] forHeaderFooterViewReuseIdentifier:@"headerView"];

    // Do any additional setup after loading the view from its nib.
   // self.debriefTableView.frame = self.view.frame;

    self.expandedSections = [[NSMutableDictionary alloc] init];
    
    self.debriefTableView.scrollEnabled = self.shouldScrollContent;
    [self expandImageWidth];
    
    
//    self.debriefTableView.layer.borderColor = [UIColor blackColor].CGColor;
//    self.debriefTableView.layer.borderWidth = 1;
    SXLogInfo(@"%@",NSStringFromCGRect(self.debriefTableView.frame));

    
 

    SXLogInfo(@"%@",NSStringFromCGRect(self.debriefTableView.frame));
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self setBorder];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self isSectionExpanded:section])
    {
        return 1;
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell_temp"];

    if(cell == nil)
    {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_temp"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        NSArray * subViews = [cell.contentView subviews];
        for(UIView * view in subViews){
            [view removeFromSuperview];
        }
    }

    UIViewController * dbriefView = [self getDebriefView:indexPath.section];
    dbriefView.view.clipsToBounds = YES;
    
    CGRect deBriefRect  = dbriefView.view.frame;
    deBriefRect.origin.x = self.cellGapFromBorder;
    
    dbriefView.view.frame = deBriefRect;
    
    SXLogInfo(@"%@",NSStringFromCGRect(cell.frame));
    [self addChildViewController:dbriefView];
    [cell.contentView addSubview:dbriefView.view];
    
    [dbriefView didMoveToParentViewController:self];

    cell.clipsToBounds = YES;
   
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self getSectionCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    
    if([self getSectionCount] -1 == section){
        return nil;
    }
    
    UITableViewHeaderFooterView * footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footer"];
    
    if(footerView == nil)
    {
       footerView =  [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"footer"];
        
        UIView * view2 = [[UIView alloc] initWithFrame:CGRectMake(footerView.contentView.bounds.origin.x + 30, 0, tableView.bounds.size.width - 30 , 1)];
        
        
        view2.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColor];
        
        [footerView.contentView addSubview:view2];
    }
    
    
 
    return footerView;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   DebriefSectionView  * dbriefView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    if(dbriefView == nil){
          dbriefView = [[DebriefSectionView alloc]initWithReuseIdentifier:@"headerView"];
    }
  //  dbriefView.backgroundColor = [UIColor whiteColor];
    dbriefView.delegate = self;
    dbriefView.sectionLabel.text = [self getTitleForIndex:section];
    dbriefView.section = section;
    [dbriefView setExpandImage:[self isSectionExpanded:section]];
    return dbriefView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   CGFloat height = [self getHeightForSection:indexPath.section];
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self getHeightForSection:indexPath.section];
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
}

-(NSString *)getTitleForIndex:(NSInteger)section
{
    NSString * secTitle =[self titleForSection:section];
    return secTitle;
}

-(void)sectionTapped:(DebriefSectionView *)dbriefView
{
    if(self.expandedSections == nil)
    {
        self.expandedSections = [[NSMutableDictionary alloc] init];
    }
    NSString * key = [self getKeyForSection:dbriefView.section];
    
    if([self isSectionExpanded:dbriefView.section])
    {
        UIViewController * debriefView = [self.expandedSections objectForKey:key];
        
        [debriefView willMoveToParentViewController:nil];
        [debriefView.view removeFromSuperview];
        [debriefView removeFromParentViewController];
        
        [self.expandedSections removeObjectForKey:key];
        [dbriefView setExpandImage:NO];
        
        [self removeCellFromTappedSection:dbriefView.section];
        
    }
    else
    {
        [self addDbriefViewForSection:dbriefView.section];
        [dbriefView setExpandImage:YES];
        
        [self addCellToTappedSection:dbriefView.section];
    }
    [self notifyParentView];

    
    [self setBorder];

}

-(void)addCellToTappedSection:(NSInteger)section
{
   // [self.debriefTableView reloadData];
    
    [self.debriefTableView reloadSections:[[NSIndexSet alloc] initWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
-(void)notifyParentView
{
    if([self.debriefDelagte conformsToProtocol:@protocol(SFMDebriefViewControllerDelegate) ])
    {
        [self.debriefDelagte reloadParentViewForSection:self.selectedSection];
    }
}


-(void)removeCellFromTappedSection:(NSInteger)section
{
//    [self.debriefTableView reloadData];
    [self.debriefTableView reloadSections:[[NSIndexSet alloc] initWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];

}

-(NSString *)getKeyForSection:(NSInteger)section
{
    return  [[NSString alloc] initWithFormat:@"%d",section];
}


- (void)dealloc {
    
}

-(SFMPageChildLayoutViewController *)getDebriefView:(NSInteger)section
{
    NSString * key = [self getKeyForSection:section];

    SFMPageChildLayoutViewController * debriefView =  [self.expandedSections objectForKey:key];
    if(debriefView == nil)
    {
        SXLogWarning(@"Should Not come here");
//        debriefView = [[SFMPageChildLayoutViewController alloc] allo];
//        [self.expandedSections setObject:debriefView forKey:key];
        
    }
    return debriefView;
}

-(void)addDbriefViewForSection:(NSInteger)section
{
    NSString * key = [self getKeyForSection:section];
    
    SFMPageChildLayoutViewController * debriefView =  [self.expandedSections objectForKey:key];
    if(debriefView == nil)
    {
       debriefView = (SFMPageChildLayoutViewController *)[ViewControllerFactory createViewControllerByContext:ViewControllerPageViewDetail];
    }
    
   // debriefView
    SFMPageLayout *pageLayout = self.sfmPageView.sfmPage.process.pageLayout;
    NSArray *detailLayouts =pageLayout.detailLayouts;
    SFMDetailLayout *detailLayout= [detailLayouts objectAtIndex:self.selectedSection];
    [debriefView setSelectedSection:self.selectedSection];
    [debriefView setSfmPageView:self.sfmPageView];
    [debriefView setPageFields:detailLayout.detailSectionFields];
    debriefView.selectedRecord = section;
    
    [self.expandedSections setObject:debriefView forKey:key];
}

-(BOOL)isSectionExpanded:(NSInteger)section
{
    NSString * key = [self getKeyForSection:section];
    UIViewController  * dbriefVc  =  [self.expandedSections objectForKey:key];
    if(dbriefVc != nil)
    {
        return YES;
    }
    return NO;
}
-(CGFloat)getHeightForSection:(NSInteger)section
{
    SFMPageChildLayoutViewController* testVC = [self getDebriefView:section];
    CGFloat height = [testVC contentViewHeight];
    SXLogInfo(@"cVHeight %f ection %d",height,section);
    return height;
}


-(NSInteger)getSectionCount
{
   NSMutableDictionary * detailDict =  self.sfmPageView.sfmPage.detailsRecord;
    SFMPageLayout *pageLayout = self.sfmPageView.sfmPage.process.pageLayout;
    NSArray *detailLayouts =pageLayout.detailLayouts;
    SFMDetailLayout *detailLayout= [detailLayouts objectAtIndex:self.selectedSection];
    NSArray * detailRecords = [detailDict objectForKey:detailLayout.processComponentId];
    return [detailRecords count];
}

-(NSString *)titleForSection:(NSInteger)section
{
    
    NSString  * title = @"?";
    NSMutableDictionary * detailDict =  self.sfmPageView.sfmPage.detailsRecord;
    
    SFMPageLayout *pageLayout = self.sfmPageView.sfmPage.process.pageLayout;
    NSArray *detailLayouts =pageLayout.detailLayouts;
  
    
    SFMDetailLayout *detailLayout= [detailLayouts objectAtIndex:self.selectedSection];
    NSArray * detailFields = detailLayout.detailSectionFields;
    NSArray * detailRecords = [detailDict objectForKey:detailLayout.processComponentId];
    
    SFMPageField * field  = nil;
    if([detailFields count] > 0)
    {
        field  = [detailFields objectAtIndex:0];
    }
    
    if([detailRecords count] > section)
    {
        NSDictionary * recordDict = [detailRecords objectAtIndex:section];
        SFMRecordFieldData * fieldData = [recordDict objectForKey:field.fieldName];
        title = fieldData.displayValue;
        title = (![StringUtil isStringEmpty:title])?title:@"?";
    }
    return  title;
    
}

-(void)expandImageWidth
{
//    UIImage * img = [UIImage imageNamed:@"Section_down_arrow@2x.png"];
//    UIImageView * imgView = [[UIImageView alloc] initWithImage:img];
//    
//    //CGFloat  imgWidth = CGRectGetWidth(imgView.frame)/2;
    self.cellGapFromBorder = 20;
}

-(NSString *)getTitleForTableView
{
    SFMPageLayout *pageLayout = self.sfmPageView.sfmPage.process.pageLayout;
    NSArray *detailLayouts =pageLayout.detailLayouts;
    
    
    SFMDetailLayout *detailLayout= [detailLayouts objectAtIndex:self.selectedSection];
    return detailLayout.name;
}

-(CGFloat)contentViewHeight
{
    CGFloat totalHeight = 0;
    
    NSInteger sectionCount = [self getSectionCount];
    
    for ( NSInteger i = 0 ; i < sectionCount; i++) {
        
        totalHeight = [self tableView:self.debriefTableView heightForHeaderInSection:i] + totalHeight;
        if([self isSectionExpanded:i])
        {
            SFMPageChildLayoutViewController * childview = [self getDebriefView:i];
            totalHeight  = [childview contentViewHeight] + totalHeight;
        }
    }
    
    
    return totalHeight + 60 + sectionCount ;
}
-(void)setBorder
{
    
    NSArray * subLayers  = [self.debriefTableView.layer  sublayers];
    BOOL sublayerPresent = NO;
    
    CGFloat   contentViewRect = [self contentViewHeight] -30 ;
    CGRect  layerFrame = CGRectMake(0
                             , 0,  self.debriefTableView.contentSize.width , contentViewRect);
    
    for ( CALayer * layer in subLayers) {
        if([layer.name isEqualToString:@"border"]){
            sublayerPresent = YES;
            layer.frame = layerFrame;
        }
    }
    
//    SXLogInfo(@"Layerframe%@",NSStringFromCGRect(layerFrame));
    
    if(!sublayerPresent)
    {
        CALayer * layer = [[CALayer alloc] init];
        layer.name = @"border";
        layer.frame = layerFrame;
        layer.borderColor = [UIColor colorWithHexString:kSeperatorLineColor ].CGColor;//[UIColor grayColor].CGColor;
        layer.borderWidth = 1;
        layer.cornerRadius = 4;

        [self.debriefTableView.layer addSublayer:layer];
    }
    
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setBorder];
    
    [self.debriefTableView  reloadData];
}

- (void)resetViewPage:(SFMPageViewModel*)sfmViewPageModel
{
    self.sfmPageView = sfmViewPageModel;
    
    NSArray *allExpandedSections = [self.expandedSections allKeys];
    
    for (int index=0; index<[allExpandedSections count]; index++) {
        NSNumber *expandedSection = [allExpandedSections objectAtIndex:index];
        if([self isSectionExpanded:[expandedSection intValue]]){
            SFMPageChildLayoutViewController *childVC = [self getDebriefView:expandedSection.intValue];
            [childVC resetViewPage:self.sfmPageView];
            SFMPageLayout *pageLayout = self.sfmPageView.sfmPage.process.pageLayout;
            NSArray *detailLayouts =pageLayout.detailLayouts;
            SFMDetailLayout *detailLayout= [detailLayouts objectAtIndex:self.selectedSection];

            [childVC setPageFields:detailLayout.detailSectionFields];
            
        }
    }
    
    [self.debriefTableView reloadData];
    [self setBorder];
}

@end
