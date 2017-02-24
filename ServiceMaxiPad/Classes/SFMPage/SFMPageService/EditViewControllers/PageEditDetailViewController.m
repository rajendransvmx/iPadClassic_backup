//
//  PageEditDetailViewController.m
//  ServiceMaxMobile
//
//  Created by shravya on 29/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "PageEditDetailViewController.h"
#import "PageLayoutEditViewController.h"
#import "ChildEditViewController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "Utility.h"
#import "TagManager.h"

//static NSInteger kKeyBoardHeight = 360.0;

@interface PageEditDetailViewController (){
    NSIndexPath *selectedIndexpath;
}

@property (strong, nonatomic) IBOutlet UIButton *sectionButton;
@property(nonatomic, strong) SMSplitPopover *masterPopoverController;

@property(nonatomic,strong)NSMutableArray *childPageLayoutViewControllers;

@property(nonatomic,assign)CGRect childViewFrame;
@property(nonatomic,strong)NSIndexPath *selectedMasterIndexpath;

@property(nonatomic,assign) CGFloat keyBoardHeight;

@property(nonatomic,assign) CGRect keyBoardFrame;

@property(nonatomic, strong) NSMutableArray *bizRulesErrors;
@property(nonatomic, strong) IBOutlet UIView *bizRuleButton;
@property(nonatomic, strong) IBOutlet UITextField *bizRuleLabel;
@property(nonatomic) BOOL bizRuleBtnTapped;
@property(nonatomic, strong) BizRulesViewController *bizRuleVc;
@property(nonatomic, strong) UIView  *overlayView;
@end


static NSInteger cellSubViewTag = 1001;
static NSString *cellIdentifier = @"cellIdentifier";

@implementation PageEditDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSFPage:(SFMPage *)sfPage {
    
    self = [super initWithNibName:@"PageEditDetailViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.sfmPage = sfPage;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.childViewFrame = CGRectMake(20, 10, self.view.bounds.size.width - 60, 280);
    [self addBottomBorder];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
    //[self initiateBuissRules];
    [self setUpBizRuleLabelUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    // [self.tableView reloadData];
    
}

#pragma mark - Tableview data source and delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.childPageLayoutViewControllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        UIView *someView = [cell.contentView viewWithTag:cellSubViewTag];
        [someView removeFromSuperview];
    }
    cell.clipsToBounds = YES;
    ChildEditViewController *pageLayoutViewController = nil;
    if ([self.childPageLayoutViewControllers count] > indexPath.section)
        pageLayoutViewController = [self.childPageLayoutViewControllers objectAtIndex:indexPath.section];
    pageLayoutViewController.view.tag = cellSubViewTag;
    pageLayoutViewController.view.frame = CGRectMake(10, 10, tableView.frame.size.width - 20, [self getHeightForIndexPath:indexPath]);
    [cell.contentView addSubview: pageLayoutViewController.view];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self getHeightForIndexPath:indexPath] + 20.0;
}

#pragma mark End

#pragma mark - setting getting view controller
- (void)addChildViewControllersToData:(NSArray *)newChildViewControllers {
    self.childPageLayoutViewControllers = [[NSMutableArray alloc] initWithArray:newChildViewControllers];
    for (int counter = 0 ; counter < [self.childViewControllers count];counter++) {
        UIViewController *controller = [self.childViewControllers objectAtIndex:counter];
        
        ChildEditViewController *editViewController = (ChildEditViewController *)controller;
        if ([editViewController conformsToProtocol:@protocol(PageEditDetailViewControllerDelegate)]) {
            [editViewController willRemoveViewFromSuperView];
        }
        [controller removeFromParentViewController];
    }
    
    self.tableView.scrollEnabled = YES;
    BOOL isTableScrollable = YES;
    for (ChildEditViewController *controller in newChildViewControllers    ) {
        
        if ([controller conformsToProtocol:@protocol(PageEditDetailViewControllerDelegate)]) {
            isTableScrollable = [controller scrollableTableView];
            
            isTableScrollable = [controller isBorderNeeded];
            if (isTableScrollable) {
                controller.view.layer.cornerRadius = 10.0;
                controller.view.layer.borderColor = [[UIColor getUIColorFromHexValue:kSeperatorLineColor] CGColor];
                controller.view.layer.borderWidth = 1.0;
            }
        }
        controller.delegate = self;
        [self addChildViewController:controller];
    }
    
    self.tableView.scrollEnabled = isTableScrollable;
}

- (NSArray *)allChildViewController {
    return self.childPageLayoutViewControllers;
}

- (CGFloat)getHeightForIndexPath:(NSIndexPath *)indexPath {
    if ([self.childPageLayoutViewControllers count] > indexPath.section) {
        
        ChildEditViewController *editViewController = [self.childPageLayoutViewControllers objectAtIndex:indexPath.section];
        if ([editViewController conformsToProtocol:@protocol(PageEditDetailViewControllerDelegate)]) {
            return [editViewController heightOfTheView];
        }
    }
    return 0.0;
}
#pragma mark - SMSplitViewControllerDelegate Methods

-(void)splitViewController:(SMSplitViewController *)splitViewController didHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover
{
    //Portrait
    self.sectionButton.hidden = NO;
    
    [self.sectionButton addTarget:barButtonItem.target action:barButtonItem.action forControlEvents:UIControlEventTouchUpInside];
    [self portrait:splitViewController];
    
    self.masterPopoverController = popover;
    
}


- (void)splitViewController:(SMSplitViewController *)splitViewController didShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem{
    
    //Landscape
    self.sectionButton.hidden = YES;
    
    [self landScape:splitViewController];
    self.masterPopoverController = nil;
}

#pragma mark End
- (void)setContentWithItem:(id)item
{
    [self.sectionButton setTitle:[item description] forState:UIControlStateNormal];
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
}

-(void) addBottomBorder
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, CGRectGetHeight(self.sectionButton.bounds)-1, CGRectGetWidth(self.sectionButton.bounds), 1.0f);
    bottomBorder.backgroundColor = [UIColor getUIColorFromHexValue:kSeperatorLineColor].CGColor;
    [self.sectionButton.layer addSublayer:bottomBorder];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self.tableView reloadData];
}

#pragma mark - Key board handling

- (void)resizeViewForKeyboardOfIndexpath:(NSIndexPath *)selectedIndexPath {
    
    /*  Show all is selected  */
    NSIndexPath *newSelectedIndexpath = nil;
    NSInteger childIndex = selectedIndexPath.row;
    if ([self.childPageLayoutViewControllers count] > 1) {
        newSelectedIndexpath = [NSIndexPath indexPathForRow:0 inSection:selectedIndexPath.row];
    }
    else {
        /*Only first row */
        newSelectedIndexpath = nil;
        childIndex = 0;
    }
    
    if ([self.childPageLayoutViewControllers count] > childIndex ) {
        
        ChildEditViewController *editController = [self.childPageLayoutViewControllers objectAtIndex:childIndex];
        if ([editController conformsToProtocol:@protocol(PageEditDetailViewControllerDelegate)]) {
            CGFloat internalOffSet =  [editController internalOffsetToSelectedIndex];
            
            [self scrollTableViewToIndexPath:newSelectedIndexpath andInternalOffSet:internalOffSet];
        }
    }
}

- (void)scrollTableViewToIndexPath:(NSIndexPath *)indexPath andInternalOffSet:(CGFloat )internalOffSet {
    

    [self reduceTableViewByHalf];
    
    [self scrollTableViewToGivenIndexPath:indexPath andInternalOffset:internalOffSet];
    
    
}

- (void)scrollTableViewToGivenIndexPath:(NSIndexPath *)indexPath
                      andInternalOffset:(CGFloat)internalOffSet {
    CGFloat bottomOffset = 30;
    
    CGFloat tableViewHeighInKeyBoardMode = [self getTableViewFrameOnkeyboard];
    tableViewHeighInKeyBoardMode = tableViewHeighInKeyBoardMode - bottomOffset;
    if (indexPath == nil) {
        
        CGPoint currentContentOffset = self.tableView.contentOffset;
        if (internalOffSet < self.tableView.frame.size.height) {
            /* We need not do any thing as selected textfield is already in visible Area */
        }
        else {
            currentContentOffset.y = internalOffSet  - tableViewHeighInKeyBoardMode;
            [self.tableView setContentOffset:currentContentOffset animated:NO];
        }
    }
    else{
        
        CGRect rowRect  = [self.tableView rectForRowAtIndexPath:indexPath];
        SXLogInfo(@"%@",NSStringFromCGRect(rowRect));
        
        CGPoint currentContentOffset =self.tableView.contentOffset;
        
        CGFloat offsetY = rowRect.origin.y + internalOffSet;
        if (offsetY < self.tableView.frame.size.height) {
            /* We need not do any thing as selected textfield is already in visible Area */
        }
        else{
            currentContentOffset.y = offsetY - tableViewHeighInKeyBoardMode;
            //self.tableView.contentOffset = currentContentOffset;
            [self.tableView setContentOffset:currentContentOffset animated:NO];
        }
    }
    
}
- (void)reduceTableViewByHalf {
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = [self getTableViewFrameOnkeyboard];
    [UIView animateWithDuration:1.0 animations:^{
        self.tableView.frame = tableViewFrame;
    }];
}
- (CGFloat)getTableViewFrameOnkeyboard {
//    NSLog(@"NavBar Height %.0f",self.navigationController.navigationBar.frame.size.height);
//    NSLog(@"View Height %.0f",self.view.frame.size.height);
//    NSLog(@"Keyboard Origin.y %.0f",self.keyBoardFrame.origin.y);
//    NSLog(@"Keyboard Height %.0f",self.keyBoardHeight);
    CGFloat visibleKeyboarHeight = self.view.frame.size.height - self.keyBoardFrame.origin.y;
//    NSLog(@"Keyboard VisibleHeight %.0f",visibleKeyboarHeight);

    CGFloat bizRuleButtonHeight = 0;
    if (!self.bizRuleButton.hidden) {
        bizRuleButtonHeight = self.bizRuleButton.frame.size.height;
    }
    
    if (UIInterfaceOrientationIsPortrait( [[UIApplication sharedApplication] statusBarOrientation])) {
        
        if (self.keyBoardFrame.origin.y + self.keyBoardHeight > self.view.frame.size.height + self.navigationController.navigationBar.frame.size.height +  [UIApplication sharedApplication].statusBarFrame.size.height){
            return  self.view.frame.size.height - visibleKeyboarHeight - 40 - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - bizRuleButtonHeight ;
        }
        else{
            return  self.view.frame.size.height - self.keyBoardHeight - self.navigationController.navigationBar.frame.size.height - bizRuleButtonHeight ;
        }
        
    }
    else if (UIInterfaceOrientationIsLandscape( [[UIApplication sharedApplication] statusBarOrientation])){
        
        
        if (self.keyBoardFrame.origin.y + self.keyBoardHeight > self.view.frame.size.height + self.navigationController.navigationBar.frame.size.height +  [UIApplication sharedApplication].statusBarFrame.size.height){
            return  self.view.frame.size.height - visibleKeyboarHeight - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - bizRuleButtonHeight ;
        }
        else{
            return  self.view.frame.size.height - self.keyBoardHeight - bizRuleButtonHeight ;
        }


    }
    
    return self.view.frame.size.height - bizRuleButtonHeight;
}
- (void)resetOriginalTableViewFrame {
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = self.view.frame.size.height - tableViewFrame.origin.y;
    self.tableView.frame = tableViewFrame;
}

- (CGFloat)getKeyBoardHeightIfHeightZero {
    
    if (UIInterfaceOrientationIsPortrait( [[UIApplication sharedApplication] statusBarOrientation])) {
        return ([ Utility isCameraAvailable])? 310.0:264;
    }
    else if (UIInterfaceOrientationIsLandscape( [[UIApplication sharedApplication] statusBarOrientation])){
        return  ([ Utility isCameraAvailable])? 398.0:352;
    }
    return 0;
}


#pragma mark End

#pragma mark - Key board handlers
- (void)keyboardWillHide:(NSNotification *)notification
{
    [self resetOriginalTableViewFrame];

    SXLogInfo(@"UserInfo :%@",notification.userInfo);
    SXLogInfo(@"Dismission the key board item");
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    
    NSValue *rectValue  = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    self.keyBoardFrame = [rectValue CGRectValue];
    if (self.keyBoardFrame.size.height < self.keyBoardFrame.size.width ) {
        self.keyBoardHeight = self.keyBoardFrame.size.height;
    }
    else{
        self.keyBoardHeight = self.keyBoardFrame.size.width;
    }

    

}


#pragma mark - ChildEditViewControllerDelegate Delegates
- (void)keyboardShownInSelectedIndexPath:(NSIndexPath *)indexPath {
    selectedIndexpath=indexPath;
    [self resizeViewForKeyboardOfIndexpath:selectedIndexpath];

}


- (void) reloadDataForIndexPath:(NSIndexPath *)indexPath reloadAll:(BOOL)reloadAllSections;
{
    if (reloadAllSections) {
        if ([self isInShowllMode]) {
            if (self.selectedMasterIndexpath.section == 0) {
                for (PageLayoutEditViewController *pageLayoutViewController in self.childPageLayoutViewControllers) {
                    [self reloadDataAsync:pageLayoutViewController];
                }
            }
        }
    }
    else {
        /*if ([self isInShowllMode]) {
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationNone];
         }
         else{
         
         //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
         NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
         [indexPathArray addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
         
         [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
         
         }*/
        [self.tableView reloadData];
    }
}

- (void)reloadDataAsync:(PageLayoutEditViewController *)pageLayoutCollection {
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [pageLayoutCollection.pageLayoutCollectionView reloadData];
                       
                   });
}


- (BOOL) isInShowllMode
{
    BOOL isShowAllMode = NO;
    
    if ([self.allChildViewController count]>1) {
        isShowAllMode = YES;
    }
    
    return isShowAllMode;
}


- (BOOL)isDelgateInShowAllMode {
    return [self isInShowllMode];
}

#pragma mark End

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -
- (void)resignAnyFirstResponders{
    
    for (int counter = 0 ; counter < [self.childPageLayoutViewControllers count];counter++) {
        UIViewController *controller = [self.childPageLayoutViewControllers objectAtIndex:counter];
        ChildEditViewController *editViewController = (ChildEditViewController *)controller;
        if ([editViewController conformsToProtocol:@protocol(PageEditDetailViewControllerDelegate)]) {
            [editViewController resignAllFirstResponders];
        }
        
    }
}
#pragma mark  End



#pragma mark - BuissRule

#pragma mark - Biz Rule implemetation

-(void)portrait:(SMSplitViewController *)splitViewController
{
    CGRect summaryButton = self.sectionButton.frame;
    CGRect bizRuleRect = self.bizRuleButton.frame;
    
    CGFloat yaxis = summaryButton.size.height  ;
    
    if([self.bizRulesErrors count] > 0){
        self.bizRuleButton.hidden = NO;
        yaxis = yaxis + bizRuleRect.size.height;
        
        bizRuleRect.origin.y = summaryButton.size.height;
        self.bizRuleButton.frame = bizRuleRect;
    }
    else
    {
        self.bizRuleButton.hidden = YES;
    }
    
    CGRect viewFrame = splitViewController.detailViewController.view.bounds;
    viewFrame.origin.y=yaxis;
    viewFrame.size.height-= yaxis;
    
    self.tableView.frame = viewFrame;
    [self resetBizRuleDropDownFrame:splitViewController];
    
    [self updateOverlayFrame];
}


-(void)landScape:(SMSplitViewController *)splitViewController
{
    CGFloat yaxis = 0 ;
    CGRect bizRuleRect = self.bizRuleButton.frame;
    CGRect summaryButton = self.sectionButton.frame;
    
    if([self.bizRulesErrors count] > 0){
        self.bizRuleButton.hidden = NO;
        yaxis = yaxis + bizRuleRect.size.height;
        
        bizRuleRect.origin.y = summaryButton.origin.y;
        self.bizRuleButton.frame = bizRuleRect;
        
    }
    else{
        self.bizRuleButton.hidden = YES;
    }
    
    CGRect viewFrame = splitViewController.detailViewController.view.bounds;
    viewFrame.origin.y=yaxis;
    viewFrame.size.height-= yaxis;
    
    self.tableView.frame = viewFrame;
    [self resetBizRuleDropDownFrame:splitViewController];
    [self updateOverlayFrame];
}
-(void)resetBizRuleDropDownFrame:(SMSplitViewController *)splitViewController
{
    if(self.bizRuleBtnTapped && [self.bizRulesErrors count] > 0)
    {
        CGRect vcFrame  =  self.bizRuleVc.view.frame;
        vcFrame.origin.x = self.bizRuleButton.frame.origin.x + 10;
        vcFrame.origin.y = self.bizRuleButton.frame.origin.y;
        vcFrame.size.width =  CGRectGetWidth(self.view.bounds) - 20;
        //vcFrame.size.width =  CGRectGetWidth(self.tableView.frame);
        
        self.bizRuleVc.view.frame = vcFrame;
    }
}
-(void)bizRuleButtonTapped
{
    self.bizRuleBtnTapped = !self.bizRuleBtnTapped;
    [self animateBizRuleView];
}

-(void)animateBizRuleView
{
    CGRect vcFrame  =  self.bizRuleVc.view.frame;
    
    vcFrame.origin.x = self.bizRuleButton.frame.origin.x + 10;
    vcFrame.origin.y = self.bizRuleButton.frame.origin.y;
    vcFrame.size.width =  CGRectGetWidth(self.view.bounds) - 20;
    //vcFrame.size.width =  CGRectGetWidth(self.tableView.frame);
    
    [self setUpBizRuleLabel];
    
    if(self.bizRuleVc == nil){
        self.bizRuleVc = [[BizRulesViewController alloc] initWithNibName:@"BizRulesViewController" bundle:nil];
        self.bizRuleVc.view.clipsToBounds = YES;
        vcFrame.size.height = 0;
        self.bizRuleVc.view.frame = vcFrame;
        self.bizRuleVc.deleagte = self;
        self.bizRuleVc.bizRulesArray =self.bizRulesErrors;
        
        
    }
    
    if(self.bizRuleBtnTapped){
        
        [self addOverLay];
        
        vcFrame.size.height = 300;
        
        [UIView animateWithDuration:0.20 delay:0 options:0 animations:^{
            self.bizRuleVc.view.frame = vcFrame;
            [self.view addSubview:self.bizRuleVc.view];
            
        } completion:^(BOOL finished) {
            [self.bizRuleVc showDisclosureButton];
        }];
    }
    else
    {
        
        vcFrame.size.height = 0;
        [UIView animateWithDuration:0.20 delay:0 options:0 animations:^{
            self.bizRuleVc.view.frame = vcFrame;
            
            
        } completion:^(BOOL finished) {
            [self.bizRuleVc.view removeFromSuperview];
            self.bizRuleVc = nil;
            [self removeOverlay];
        }];
        
        [self.containerViewControlerDelegate refreshBizRuleData];
        
        
    }
}


-(void)initiateBuissRulesData:(NSMutableArray *)dataArray
{
    
    self.bizRulesErrors = dataArray;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bizRuleButtonTapped)];
    
    [self.bizRuleButton addGestureRecognizer:tapGesture];
    
    [self refreshDetailViewFrames];
    [self setUpBizRuleLabel];
}

-(void)refreshDetailView
{
    if([self.bizRulesErrors count] > 0){
        [self dismissBizRuleUI];
    }
    [self refreshDetailViewFrames];
}

-(void)refreshDetailViewFrames

{
    CGRect frame;
    frame = [[UIScreen mainScreen] bounds];
    if (frame.size.width != [UIApplication sharedApplication].statusBarFrame.size.width) {
        [self landScape:(SMSplitViewController *)self.containerViewControlerDelegate];
        
    } else
    {
        [self portrait:(SMSplitViewController *)self.containerViewControlerDelegate];
    }
    
    /*if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
     [self landScape:(SMSplitViewController *)self.containerViewControlerDelegate];
     }
     else {
     [self portrait:(SMSplitViewController *)self.containerViewControlerDelegate];
     }*/
}

-(void)dismissBizRuleUI
{
    self.bizRuleBtnTapped = NO;
    [self animateBizRuleView];
}


#pragma mark - end

-(void)addOverLay
{
    if (!self.overlayView) {
        self.overlayView =  [[UIView alloc] initWithFrame:CGRectZero];
        self.overlayView.userInteractionEnabled = YES;
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha  = 0.3;
        [self.view addSubview:self.overlayView];
        [self.view bringSubviewToFront:self.overlayView];
        [self updateOverlayFrame];
    }
    
}

- (void)updateOverlayFrame
{
    if (self.overlayView) {
        CGRect frame;
        frame = [[UIScreen mainScreen] bounds];
        if (frame.size.width != [UIApplication sharedApplication].statusBarFrame.size.width) {
            frame = CGRectMake(-(frame.size.height-CGRectGetWidth(self.view.bounds)),0, frame.size.height, frame.size.width);
        } else {
            frame = CGRectMake(-(frame.size.width-CGRectGetWidth(self.view.bounds)), 0, frame.size.width, frame.size.height);
        }
        if (CGRectGetWidth(frame) < CGRectGetHeight(frame)) {
            //frame.origin.y = 44;
        }
        self.overlayView.frame = self.view.bounds;
        
        UITapGestureRecognizer * gestureRecognizer  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissBizRuleUI)];
        
        [self.overlayView addGestureRecognizer:gestureRecognizer];
        
    }
}

- (void)removeOverlay
{
    if (self.overlayView) {
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;
    }
    
}

-(void)setUpBizRuleLabel{
    NSString *cannotsave = [[TagManager sharedInstance]tagByName:kTag_CannotSave];
    NSString * confirmMsg = [[TagManager sharedInstance]tagByName:kTag_IssuesNeedResolution];
    NSString *finalText = [[NSString alloc] initWithFormat:@"%@ %lu %@",cannotsave,(unsigned long)[self.bizRulesErrors count],confirmMsg];
    self.bizRuleLabel.text = finalText;
    [self.bizRuleLabel sizeToFit];
}

-(void)setUpBizRuleLabelUI
{
    self.bizRuleLabel.rightView = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:@"arrow_down.png"]];
    self.bizRuleLabel.rightViewMode = UITextFieldViewModeAlways;
}


#pragma mark - Linked Process
- (void)loadLinkedSFMProcessForProcessInfo:(LinkedProcess *)processInfo
{
    PageEditViewController *editViewController = (PageEditViewController *)self.containerViewControlerDelegate;
    //Extra space for button title to look properly
    [editViewController showLinkedSFMProcessForProcessInfo:processInfo];
}
#pragma mark - End

@end
