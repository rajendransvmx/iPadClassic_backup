//
//  ChatterViewController.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 15/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterViewController.h"
#import "TagManager.h"
#import "StyleManager.h"
#import "ChatterCell.h"
#import "ChatterFooterView.h"
#import "ChatterSectionView.h"
#import "ChatterManager.h"
#import "ChatterHelper.h"
#import "NonTagConstant.h"
#import "FileManager.h"
#import "ChatterFeedPost.h"
#import "ChatterFeedComments.h"
#import "MBProgressHUD.h"
#import "ChatterTextFieldDelegate.h"
#import "CusTextField.h"
#import "StringUtil.h"
#import "SNetworkReachabilityManager.h"
#import "AlertMessageHandler.h"
#import "AsyncImageLoader.h"

/* This value is in second, Every given time interval we are fetching data from server and refreshing chatter screen */
#define TIMERINTERVAL   15

@interface ChatterViewController () <UITableViewDataSource, UITableViewDelegate, ChatterTextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *topProductLabel;

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *leftProductLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong)UIImageView *imageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightContraint;

@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelHeightContraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelVerticalSpacing;

@property (weak, nonatomic) IBOutlet UILabel *rightViewProductLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewHorizontalSpacing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewTrailing;

@property NSInteger leftViewOriginalWidth;
@property NSInteger topViewOriginalHeight;

@property NSInteger labelHeight;
@property NSInteger labelSpacing;

@property NSInteger horizontalSpacing;
@property NSInteger trailingSpace;


@property (nonatomic, strong)MBProgressHUD *hudView;
@property (nonatomic, strong)CusTextField  *textField;

@property (nonatomic, strong)NSMutableArray     *chatterData;
@property(nonatomic, strong)NSMutableDictionary *textValueDict;

@property(nonatomic, assign)BOOL isKeyboardShowing;

@property(nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong) NSString *chatMessage;
@property (nonatomic)CGFloat widthOfChatText;

@end

@implementation ChatterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.widthOfChatText = 0;
    
    [self registerNotification];
    [self registerNetoworkNotification];
    
    [self initialSetUp];
    [self setUpTableView];
    
    [self pushProductIdToCache];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showAnimator];
    [self initiateChatter];
    
}

- (void)initiateChatter
{
    [[ChatterManager sharedInstance] setFirstTimeloadflag:YES];
    [[ChatterManager sharedInstance] fetchChatterDetails];
}

- (void)initialSetUp
{
    self.navigationItem.titleView =  [UILabel navBarTitleLabel:[[TagManager sharedInstance]
                                                                tagByName:kTagChatterTitle]];
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.leftViewOriginalWidth = self.leftViewWidthConstraint.constant;
    self.topViewOriginalHeight = self.topViewHeightContraint.constant;
    
    self.labelHeight = self.labelHeightContraint.constant;
    self.labelSpacing = self.labelVerticalSpacing.constant;
    
    
    self.horizontalSpacing = self.rightViewHorizontalSpacing.constant;
    self.trailingSpace = self.rightViewTrailing.constant;
    
    
    self.isKeyboardShowing = NO;
}

- (void)setUpTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatterCell" bundle:nil] forCellReuseIdentifier:@"Chatter"];
    [self.tableView registerClass:[ChatterFooterView class] forHeaderFooterViewReuseIdentifier:@"Footer"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self tableHeaderView];
}

- (void)updateLabelText:(UILabel *)label
{
    label.text = self.productName;
    label.textColor = [UIColor colorFromHexString:@"#262626"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (self.leftImageView.image || self.topImageView.image) {
        [self updateViewForProductImage];
    }
    else {
        [self updateViewForNoProductImage];
    }
    
    [self setUpImageView];
}


- (void)updateViewForProductImage
{
    if ([self isViewInLandScape]) {
        self.topViewHeightContraint.constant = 0;
        self.leftViewWidthConstraint.constant = self.leftViewOriginalWidth;
        [self updateLabelText:self.leftProductLabel];
    }
    else {
        self.leftViewWidthConstraint.constant = 0;
        self.topViewHeightContraint.constant = self.topViewOriginalHeight;
        [self updateLabelText:self.topProductLabel];
    }
    self.labelHeightContraint.constant = 0;
    self.labelVerticalSpacing.constant = 0;
    
    
    self.rightViewHorizontalSpacing.constant = self.horizontalSpacing;
    self.rightViewTrailing.constant = self.trailingSpace;
}

- (void)updateViewForNoProductImage
{
    self.leftViewWidthConstraint.constant = 0;
    self.topViewHeightContraint.constant = 0;
    
    self.rightViewHorizontalSpacing.constant = 120;
    self.rightViewTrailing.constant = 120;
    
    [self updateLabelText:self.rightViewProductLabel];
    
    self.labelHeightContraint.constant = self.labelHeight;
    self.labelVerticalSpacing.constant = self.labelSpacing;

}

- (void)setUpImageView
{
    self.leftImageView.layer.cornerRadius = 150;
    self.leftImageView.clipsToBounds = YES;
    
    self.topImageView.layer.cornerRadius = 70;
    self.topImageView.clipsToBounds = YES;
}

- (void)tableHeaderView
{
    NSArray *subViews = [self.rightView subviews];
    
    for (id subView in subViews) {
       if ([subView isKindOfClass:[ChatterSectionView class]]){
           ChatterSectionView *view = (ChatterSectionView *)subView;
           view.sectionTextFieldDelegate = self;
       }
    }
}

- (void)pushProductIdToCache
{
    [[ChatterManager sharedInstance] setProductId:self.productId];
}

- (BOOL)isViewInLandScape
{
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return YES;
    }
    return NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self invalidateTimer];
    [self hideAnimator];
}

- (void)registerNotification
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chatterDataModified:)
                                                 name:kChatterDataModified
                                               object:nil];
}

- (void)deregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatterDataModified object:nil];
}

- (void)dealloc
{
    self.textValueDict = nil;
    self.chatterData = nil;
    self.textField = nil;
    self.hudView = nil;
    
    [self deregisterNotification];
    [self deRegisterNetoworkNotification];
    [[ChatterManager sharedInstance] stopAllTasks];
    [[ChatterManager sharedInstance] updateUserImagesToRefresh];
    [[AsyncImageLoader sharedInstance] cancelAllRequests];
    [[ChatterManager sharedInstance] clearCache];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSValue *rectValue  = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyBoardFrame = [rectValue CGRectValue];
    
    CGFloat keyBoardHeight = 365.0;
    if (keyBoardFrame.size.height < keyBoardFrame.size.width ) {
        keyBoardHeight = keyBoardFrame.size.height;
    }
    else{
        keyBoardHeight = keyBoardFrame.size.width;
    }
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, keyBoardHeight, 0.0f);
    self.tableView.contentInset = edgeInsets;
    self. tableView.scrollIndicatorInsets = edgeInsets;
    
    [self invalidateTimer];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = edgeInsets;
    self.tableView.scrollIndicatorInsets = edgeInsets;
    
    self.isKeyboardShowing = NO;
    [self scheduleTimer];
}

- (void)resignKeyBoard
{
    [self.textField resignFirstResponder];
}

#pragma mark - TableView Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.chatterData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ChatterFeedPost *post = [self.chatterData objectAtIndex:section];
    
    return [post.feedComments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Chatter" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ChatterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Chatter"];
    }
    ChatterFeedComments *comment = [self getFeetCommentForIndexPath:indexPath];
    cell.chatText.numberOfLines = 0;
    [cell updateCellView:comment];
    [cell updateUserImage];
    cell.path = indexPath;
    cell.separatorInset =  UIEdgeInsetsMake(0, 85, 0, 0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height ;
    CGFloat value = 0;
    ChatterCell *cell = [[ChatterCell alloc] init];
    
    ChatterFeedComments *comment = [self getFeetCommentForIndexPath:indexPath];
    if([comment.commentBody length] > 0)
    {
     height= [self getTheHeightOfTheMessageLableForTheString:comment.commentBody withTheWIdth:cell.frame.size.width];
        
        if(height > 25)
        {
            value = 80 + height - 25;
            return value;
        }
        else
        {
            return 80.0f;
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    ChatterFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Footer"];
    
    if (footerView == nil) {
        footerView = [[ChatterFooterView alloc] initWithReuseIdentifier:@"Footer"];
    }
    
    footerView.footerTextFieldDelegate = self;
    footerView.section = section;
    NSString *value = [self txtValueForKey:[self getFeedPostIdForCurrentSection:section]];
    [footerView setTextFieldValue:value];
    
    return footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorFromHexString:kActionBgColor];
}

- (ChatterFeedComments *)getFeetCommentForIndexPath:(NSIndexPath *)indexPath
{
    ChatterFeedComments *comment = nil;
    
    ChatterFeedPost *post = [self.chatterData objectAtIndex:indexPath.section];
    
    if ([post.feedComments count]) {
        comment =   [post.feedComments objectAtIndex:indexPath.row];
    }
    return comment;
}

#pragma mark - End


- (void)hideAnimator
{
    if (self.hudView) {
        [self.hudView hide:YES];
        self.hudView = nil;
    }
}

- (void)showAnimator
{
    if (!self.hudView) {
        self.hudView = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:self.hudView];
        self.hudView.mode = MBProgressHUDModeIndeterminate;
        self.hudView.labelText = [[TagManager sharedInstance]tagByName:kTagLoading];
        [self.hudView show:YES];
    }
}


#pragma mark - Chatter Manager Delegate
- (void)chatterDataModified:(NSNotification*)aNotif
{
    ChatterResponseStatus status = [[[aNotif userInfo] objectForKey:@"Status"] intValue];
    
    switch (status) {
        case ResponseStatusProductImage:
            [self getProductImage];
            break;
        case ResponseStatusChatterData:
            [self getChatterPostDetails];
            break;
        case ResponseStatusChatterFeed:
            [self refreshData];
            break;
        case ResponseStatusFailed:
            [self updateUIOnFailure];
            break;
        default:
            break;
    }
}

- (void)updateUIOnFailure
{
    [self hideAnimator];
    [self invalidateTimer];
    [self scheduleTimer];
}

- (void)getProductImage
{
    UIImage *image = [[ChatterManager sharedInstance] chatterProductImage];
    
    if (image) {
        [self setUpProductImage:image];
    }
    [self.view setNeedsLayout];
}

- (void)getChatterPostDetails
{
    self.chatterData = [[ChatterManager sharedInstance] ChatterDataDetails];
    if ([self.chatterData count] > 0) {
        if (!self.isKeyboardShowing)
            [self reloadTable];
    }
    [self hideAnimator];
    [self invalidateTimer];
    [self scheduleTimer];
}

- (void)scheduleTimer
{
    @synchronized ([self class]) {
      self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMERINTERVAL
                                                      target:self
                                                    selector:@selector(refreshChatterData)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}



- (void)refreshChatterData
{
    SXLogInfo(@"Refresh Started");
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]
        && !self.isKeyboardShowing) {
        SXLogInfo(@"Refresh Triggered");
        [self showAnimator];
        [self refreshData];
    }
}

- (void)invalidateTimer
{
    if([self.timer isValid] && self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)refreshData
{
    [[ChatterManager sharedInstance] refreshData];
}

- (void)requestFailed
{
    [self hideAnimator];
}

- (void)reloadTable
{
    [self.tableView reloadData];
}

- (void)setUpProductImage:(UIImage *)image
{
    if (image != nil) {
        self.leftImageView.layer.borderColor = [UIColor colorFromHexString:kSeperatorLineColor].CGColor;
        self.leftImageView.layer.borderWidth = 1.0f;
        self.leftImageView.image = image;
        
        self.topImageView.layer.borderColor = [UIColor colorFromHexString:kSeperatorLineColor].CGColor;
        self.topImageView.layer.borderWidth = 1.0f;
        self.topImageView.image = image;
    }
}
#pragma mark - End


#pragma mark - TextFieldDelegate
- (void)textEditingBegan:(id)sender
{
    if ([sender isKindOfClass:[UITextField class]]) {
        self.textField = (CusTextField *)sender;
    }
}

- (void)textFieldReturned
{
    [self updateTxtValueDict];
}

- (void)textEditingDone
{
    [self postFeedComment];
    [self clearTextField];
}

- (void)sectiontextEditingDone:(id)sender
{
    if ([sender isKindOfClass:[UITextField class]]) {
        self.textField = (CusTextField *)sender;
    }
    [self.textField becomeFirstResponder];
    [self resignKeyBoard];
    [self postNewFeed];
    [self clearTextField];
}

- (void)clearTextField
{
    self.textField.text = @"";
}

- (void)postNewFeed
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        if (![StringUtil isStringEmpty:self.textField.text]) {
            [self showAnimator];
            [[ChatterManager sharedInstance] postNewFeed:[self getNewFeed]];
        }
    }
    else {
        [self showNewWorkErrorAlert];
    }
}

- (void)postFeedComment
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        if (![StringUtil isStringEmpty:self.textField.text]) {
            [self showAnimator];
            [[ChatterManager sharedInstance] postFeedComment:[self getNewFeedComment]];
        }
    }
    else {
        [self showNewWorkErrorAlert];
    }
    [self clearTxtValueDict:[self getFeedPostIdForCurrentSection:self.textField.section]];
}

- (void)showNewWorkErrorAlert
{
    [[AlertMessageHandler sharedInstance] showCustomMessage:[[TagManager sharedInstance] tagByName:KTagAlertInrnetNotAvailableError]
                                               withDelegate:nil
                                                        tag:0
                                                      title:[[TagManager sharedInstance] tagByName:kTagSyncErrorMessage]
                                          cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                       andOtherButtonTitles:nil];
}

- (ChatterFeedPost *)getNewFeed
{
    ChatterFeedPost *feed = [[ChatterFeedPost alloc] init];
    feed.parentId = self.productId;
    feed.commentBody = self.textField.text;
    
    return feed;
}

- (ChatterFeedComments *)getNewFeedComment
{
    ChatterFeedComments *comments = [[ChatterFeedComments alloc] init];
    ChatterFeedPost *post = [self.chatterData objectAtIndex:self.textField.section];
    
    comments.feedItemId = post.postId;
    comments.commentBody = self.textField.text;
    return comments;
}

- (NSString *)getFeedPostIdForCurrentSection:(NSInteger)section
{
    ChatterFeedPost *post = [self.chatterData objectAtIndex:section];
    return post.postId;
}

- (void)updateTxtValueDict
{
    if (self.textValueDict == nil) {
        self.textValueDict = [NSMutableDictionary new];
    }
    NSString *postId = [self getFeedPostIdForCurrentSection:self.textField.section];
    
    if (![StringUtil isStringEmpty:postId]) {
        [self.textValueDict setObject:self.textField.text forKey:postId];
    }
}

- (void)clearTxtValueDict:(NSString *)key
{
    if ([key length] > 0) {
        [self.textValueDict removeObjectForKey:key];
    }
}

- (NSString *)txtValueForKey:(NSString *)key
{
    return [self.textValueDict objectForKey:key];
}

#pragma mark - Handling Network Change
- (void)registerNetoworkNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidChangeNotification:) name:kNetworkConnectionChanged object:nil];
}

-(void)networkDidChangeNotification:(NSNotification *)notification {
    NSNumber *networkStatus = (NSNumber *)[notification object];
    switch ([networkStatus intValue]) {
        case 0:
            [self invalidateTimer];
            break;
        case 1:
            [self scheduleTimer];
            break;
        default:
            break;
    }
}

- (void)deRegisterNetoworkNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
}

- (CGFloat)getTheHeightOfTheMessageLableForTheString:(NSString *)message withTheWIdth:(CGFloat)width
{
    width = width - 90;
    
   NSDictionary *userAttributes = @{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueRegular size:10]};
    CGRect expectedRect = [message boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes:userAttributes
                                                context:nil];
    return expectedRect.size.height;

}

#pragma mark -END


@end
