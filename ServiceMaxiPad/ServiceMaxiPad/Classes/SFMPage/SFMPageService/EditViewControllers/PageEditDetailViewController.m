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


static NSInteger kKeyBoardHeight = 360.0;

@interface PageEditDetailViewController ()

@property (retain, nonatomic) IBOutlet UIButton *sectionButton;
@property(nonatomic, retain) SMSplitPopover *masterPopoverController;

@property(nonatomic,strong)NSMutableArray *childPageLayoutViewControllers;

@property(nonatomic,assign)CGRect childViewFrame;
@property(nonatomic,strong)NSIndexPath *selectedMasterIndexpath;

@property(nonatomic,assign) CGFloat keyBoardHeight;

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
   
    
    self.keyBoardHeight = 360.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    [self.tableView reloadData];
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
    ChildEditViewController *pageLayoutViewController = [self.childPageLayoutViewControllers objectAtIndex:indexPath.section];
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
    
    for (ChildEditViewController *controller in newChildViewControllers    ) {
        controller.view.layer.cornerRadius = 10.0;
        controller.view.layer.borderColor = [[UIColor colorWithHexString:kSeperatorLineColor] CGColor];
        controller.view.layer.borderWidth = 1.0;
        controller.delegate = self;
        [self addChildViewController:controller];
    }
    
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
    
    CGRect viewFrame = splitViewController.detailViewController.view.bounds;
    viewFrame.origin.y=44;
    viewFrame.size.height-= 44;
    
    self.tableView.frame = viewFrame;
    self.masterPopoverController = popover;
    
}


- (void)splitViewController:(SMSplitViewController *)splitViewController didShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem{
    
    //Landscape
    self.sectionButton.hidden = YES;
    
    CGRect viewFrame = splitViewController.detailViewController.view.bounds;
    viewFrame.origin.y=0;
    self.tableView.frame = viewFrame;
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
    bottomBorder.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColor].CGColor;
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
        NSLog(@"%@",NSStringFromCGRect(rowRect));
        
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
    self.tableView.frame = tableViewFrame;
}
- (CGFloat)getTableViewFrameOnkeyboard {
    
    
    if (UIInterfaceOrientationIsPortrait( [[UIApplication sharedApplication] statusBarOrientation])) {
       return  self.view.frame.size.height - self.keyBoardHeight - 20 ;
    }
    else if (UIInterfaceOrientationIsLandscape( [[UIApplication sharedApplication] statusBarOrientation])){
       return  self.view.frame.size.height - self.keyBoardHeight;
    }
    return self.view.frame.size.height;
}
- (void)resetOriginalTableViewFrame {
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = self.view.frame.size.height - tableViewFrame.origin.y;
    self.tableView.frame = tableViewFrame;
}

#pragma mark End

#pragma mark - Key board handlers
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSLog(@"UserInfo :%@",notification.userInfo);
    NSLog(@"Dismission the key board item");
    [self resetOriginalTableViewFrame];
}

- (void)keyboardWillShow:(NSNotification *)notification
{

    NSValue *rectValue  = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyBoardFrame = [rectValue CGRectValue];
    if (keyBoardFrame.size.height < keyBoardFrame.size.width ) {
        self.keyBoardHeight = keyBoardFrame.size.height;
    }
    else{
        self.keyBoardHeight = keyBoardFrame.size.width;
    }
        NSLog(@"Key Board will be shown %f",self.keyBoardHeight);
    if (self.keyBoardHeight) {
        
    }
}


#pragma mark - ChildEditViewControllerDelegate Delegates
- (void)keyboardShownInSelectedIndexPath:(NSIndexPath *)indexPath {
    [self resizeViewForKeyboardOfIndexpath:indexPath];
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
        if ([self isInShowllMode]) {
            /*Reload only particular section*/
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationNone];
        }
        else{
            /*Reload tableview*/
            
            //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
            [indexPathArray addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
            
        }
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



#pragma mark End

- (void)dealloc {
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
