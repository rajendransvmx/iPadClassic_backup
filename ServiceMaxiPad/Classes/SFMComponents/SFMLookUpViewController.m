//
//  SFMLookUpViewController.m
//  ServiceMaxMobile
//
//  Created by Sahana on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFMLookUpViewController.h"
#import "SFMPageLookUpHelper.h"
#import "SFMLookUp.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "SFMLookUpDeatilViewController.h"
#import "TagManager.h"
#import "SFMLookUpFilterViewController.h"
#import "StringUtil.h"
#import "PushNotificationHeaders.h"
#import "SFMOnlineLookUpManager.h"
#import "AlertMessageHandler.h"
#import "CacheManager.h"
#import "TransactionObjectModel.h"
#import "CacheConstants.h"
#import "StringUtil.h"

#import "PageEditChildListViewController.h"

@interface SFMLookUpViewController () <LookUpFilterDelegate>
@property (nonatomic, strong) SFMPageLookUpHelper * lookUpHelper;
@property (nonatomic, strong) SFMLookUp *lookUpObject;

@property (nonatomic, strong) NSMutableArray *selectedRecords;
@property (nonatomic, strong) UIPopoverController * popOverController;
@property (nonatomic, strong)  BarCodeScannerUtility *barcodeScannerUtil;
@property (nonatomic, strong) SFMOnlineLookUpManager *manager;
@property (nonatomic, assign) BOOL isOnlineLookUpSelected;
@end

@implementation SFMLookUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.preferredContentSize = CGSizeMake(730, 600);

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self.filterButton setTitle:[[TagManager sharedInstance]tagByName:kTag_Filters] forState:UIControlStateNormal];

    [self setUpIncludeOnlineButton];
    [self setUpSearchButton];
    [self setUpFilterButton];
    
    self.lookUpHelper   = [[SFMPageLookUpHelper alloc] init];
    self.lookUpHelper.viewControllerdelegate = self;
    self.lookUpObject   = [[SFMLookUp alloc] init];
    self.selectedRecords = [[NSMutableArray alloc] init];
    
    self.lookUpObject.lookUpId   = self.lookUpId;
    self.lookUpObject.objectName = self.objectName;

    [self addContextFilter];


    [self setTableHeaderView];
    [self setUpViews];
    
    [self loadLookUpMetadata];
    
    [self fillLookUpSearchFilterMetaData];

    [self loadLookUpData];
    
    [self setUpSearchBar];
    [self noRecordsToDisplay];
    [self setGestureForBarcode];
    
    [self configureFilterButton];
    [self setSearchBarBackGround];
    [self registerForPopOverDismissNotification];
}

-(void)setUpIncludeOnlineButton
{
    
    self.isOnlineLookUpSelected = NO; // Default: Online not included in search
    
    UIImage *checkboxImage = [UIImage imageNamed:@"checkbox-unselected.png"];
    [self.includeOnlineButton setImage:checkboxImage  forState:UIControlStateNormal];
    [self.includeOnlineButton setTitleColor:[UIColor getUIColorFromHexValue:@"#FF6633"] forState:UIControlStateNormal];
    
    NSString *includeOnlineTitle = [[TagManager sharedInstance]tagByName:kTag_IncludeOnline];
    if (!includeOnlineTitle) {
        includeOnlineTitle = @"include online";
    }
    [self.includeOnlineButton setTitle:includeOnlineTitle forState:UIControlStateNormal];
    
    CGFloat spacing = 5; // the amount of spacing to appear between image and title
    self.includeOnlineButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    self.includeOnlineButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
    
}

-(void)setUpFilterButton
{
//    [self.filterButton setTitle:@"Add/Edit Filters" forState:UIControlStateNormal];

    NSString *addEditFilters = [[TagManager sharedInstance]tagByName:kTag_AddEditFilters];
    if (!addEditFilters) {
        addEditFilters = @"Add/Edit Filters";
    }
    [self.filterButton setTitle:addEditFilters forState:UIControlStateNormal];
    [self.filterButton setTitleEdgeInsets:UIEdgeInsetsMake(-5.0, 0.0, 0.0, 0.0)];
}

-(void)setUpSearchButton
{
    [self.searchButton.layer setBorderColor:[[UIColor getUIColorFromHexValue:@"#FF6633"] CGColor]];
    [self.searchButton.layer setBorderWidth:1.0];
    [self.searchButton setTitleColor:[UIColor getUIColorFromHexValue:@"#FF6633"] forState:UIControlStateNormal];
    [self.searchButton setTitle:[[TagManager sharedInstance]tagByName:kTagSfmLookUpSearch] forState:UIControlStateNormal];
}

-(BOOL)isValidContextString:(NSString *)contextString {
    
    contextString = [contextString lowercaseString];
    if ([StringUtil containsString:@"none" inString:contextString]) {
        return NO;
    }
    return YES;
}
-(void)addContextFilter
{
    SFMLookUpFilter *filter = [[SFMLookUpFilter alloc] init];
    
    //If nothing is selected "None is returned from server, we ignore it by setting nil.
    filter.lookupContext = [self isValidContextString:self.pageField.lookUpContext]?self.pageField.lookUpContext:@"";
    filter.lookupQuery = [self isValidContextString:self.pageField.lookUpQueryField]?self.pageField.lookUpQueryField:@"";

    filter.allowOverride = [self.pageField.allowOverRide boolValue];
    filter.lookContextDisplayValue = self.pageField.label;
    filter.sourceObjectName = self.pageField.sourceObjectField;
    filter.lookupContextParentObject = self.contextObjectName;
    self.lookUpObject.contextLookupFilter = filter;
    
    [self checkIfObjectPermissionForFilter:self.lookUpObject.contextLookupFilter];

}
#pragma mark - Context filter private method
- (void) checkIfObjectPermissionForFilter:(SFMLookUpFilter *) lookupFilter {
    if (lookupFilter.lookupContext != nil || ![lookupFilter.lookupContext isEqualToString:@""]) {
       
        //object permission will always be yes for context filter.
        lookupFilter.objectPermission = YES;
        lookupFilter.defaultOn = YES;
    }
}

- (void)setUpSearchBar
{
    self.searchView.delegate = self;
    self.SerachObjectName.text = self.lookUpObject.serachName;
}

-(void)setGestureForBarcode
{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barCodeImageTapped)];
    [self.barcodeImage addGestureRecognizer:tapGesture];
    self.barcodeImage.userInteractionEnabled = YES;
}

-(void)barCodeImageTapped
{
    if(self.barcodeScannerUtil == nil)
    {
        self.barcodeScannerUtil = [[BarCodeScannerUtility alloc] init];
        self.barcodeScannerUtil.scannerDelegate = self;
    }
    [ self.barcodeScannerUtil loadScannerOnViewController:self forModalPresentationStyle:UIModalPresentationOverCurrentContext];
}

-(void)noRecordsToDisplay
{
    if(self.selectionMode == multiSelectionMode){
      if([self.lookUpObject.dataArray count] == 0 )
      {
          self.tableView.hidden = YES;
          
          NSString *clickToaddSingleLine = [[TagManager sharedInstance]tagByName:kTag_AddSingleLine];
          if (!clickToaddSingleLine) {
              clickToaddSingleLine = @"Click here to add a single line";
          }
          [self.singleAddButton setTitle:clickToaddSingleLine forState:UIControlStateNormal];
          self.singleAddButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

      }
      else
      {
          self.singleAddButton.hidden= YES;//
          self.tableView.hidden = NO;

      }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotificationReceived:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)configureFilterButton
{
    if (self.selectionMode == singleSelectionMode || self.selectionMode == multiSelectionMode) {
        if ([self.lookUpObject.advanceFilters count] > 0  || (self.lookUpObject.contextLookupFilter.lookupContext != nil && ![self.lookUpObject.contextLookupFilter.lookupContext isEqualToString:@""] && self.lookUpObject.contextLookupFilter.allowOverride)) {
            self.filterButton.userInteractionEnabled = YES;
        }
        else {
            self.filterButton.userInteractionEnabled = NO;
            [self.filterButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    else {
        self.filterButton.userInteractionEnabled = NO;
        [self.filterButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

-(void)setUpViews
{
    NSDictionary *barButtonItemAttributes = @{NSFontAttributeName: [UIFont fontWithName:kHelveticaNeueThin size:kFontSize16], NSForegroundColorAttributeName :[UIColor getUIColorFromHexValue:@"#E15001"]};
    
    
    self.lookUpToolBar.backgroundColor = [UIColor getUIColorFromHexValue:kPageViewMasterBGColor];
    self.searchView.layer.borderWidth = 2;
    self.searchView.layer.borderColor = [UIColor getUIColorFromHexValue:kPageViewMasterBGColor].CGColor;
    self.searchView.layer.cornerRadius = 5;
    
    [self.cancelBarButtonItem setTitle:[[TagManager sharedInstance] tagByName:kCancelButtonTitle]];
    [self.cancelBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
    [self.addSelectedButtonItem setTitle:[[TagManager sharedInstance] tagByName:kTag_AddSelected]];
    [self.addSelectedButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
  
    
    [self.titleBarButtonItem setTitle:[self getLookUpTitleLabel]];
    [self.titleBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18],NSForegroundColorAttributeName :[UIColor  blackColor]} forState:UIControlStateNormal];
}

-(NSString *)getLookUpTitleLabel
{  NSString * objectLabel = [ self.lookUpHelper getObjectLabel:self.objectName];
    
    NSString *lookUpTag = [[TagManager sharedInstance] tagByName:kTag_LookUpTitle];
    
    if(!lookUpTag) {
        lookUpTag = @"Lookup";
    }
    
    NSString * titleStr = nil;
    if([objectLabel length] > 0 ){
       titleStr = [[NSString alloc] initWithFormat:@"%@ %@",objectLabel,lookUpTag];
    }
    else
    {
        titleStr = [[NSString alloc] initWithFormat:@"%@",lookUpTag];
    }
    return titleStr;
}

-(void)setTableHeaderView{
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)loadLookUpMetadata
{
    [self.lookUpHelper loadLookUpConfigarationForLookUpObject:self.lookUpObject];
}

-(void)loadLookUpData
{
    [self.lookUpHelper fillDataForLookUpObject:self.lookUpObject];
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
   // self.view.superview.bounds = CGRectMake(0, 0, 730, 600);
     self.preferredContentSize = CGSizeMake(730, 600);
}

- (void)dealloc {
    _barcodeScannerUtil.scannerDelegate = nil;
    _barcodeScannerUtil = nil;
    self.isOnlineLookUpSelected = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [self deregisterForPopOverDismissNotification];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lookUpObject.dataArray count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UITableViewHeaderFooterView * headerView  =  [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionView"];
    if(headerView == nil)
    {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"sectionView"];
    }
  
    UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    UILabel * tableViewHeader = [[UILabel alloc] initWithFrame:CGRectMake(10,0, self.tableView.frame.size.width-20, 30)];
    tableViewHeader.backgroundColor = [UIColor getUIColorFromHexValue:kPageViewMasterBGColor];
    [subView addSubview:tableViewHeader];
    [headerView.contentView addSubview:subView];
    
    tableViewHeader.text = [[NSString alloc] initWithFormat:@"  %@(%lu)",[[TagManager sharedInstance]tagByName:kTagSfmSearchResults],(unsigned long)[self.lookUpObject.dataArray count]];
    subView.backgroundColor = [UIColor whiteColor];
    headerView.contentView.backgroundColor  = [UIColor whiteColor];
    return headerView;
}

//TODO:Testing Online LookUP.
-(void)launchOnlineAPI
{
    self.manager = [[SFMOnlineLookUpManager alloc] init];
    self.manager.delegate = self;
    [self.manager performOnlineLookUpWithLookUpObject:self.lookUpObject andSearchText:self.searchView.text];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"lookUpCell"];
    
    if(cell == nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"lookUpCell"];
    }
    cell.textLabel.text = [self getTitleForIndexPath:indexPath];
    cell.detailTextLabel.text =[self getdetailTextForIndexPath:indexPath];
    
    if([self isSelectedAtIndexPath:indexPath])//if([self.selectedIndexPaths containsObject:indexPath])
    {
        cell.imageView.image = [UIImage imageNamed:SelectImg];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:UnselectImg];

    }
    
    CGSize imgSize = [UIImage imageNamed:InfoImage].size;
     UIButton * imgView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,imgSize.width +20  ,  imgSize.height+20)];
   
    [imgView setImage:[UIImage imageNamed:InfoImage] forState:UIControlStateNormal];
    
    imgView.imageView.contentMode = UIViewContentModeCenter;
    
    [imgView addTarget:self action:@selector(infoTapped:) forControlEvents:UIControlEventTouchUpInside];
  
    cell.accessoryView = imgView;
    imgView.tag = indexPath.row;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18];
    cell.textLabel.textColor = [UIColor getUIColorFromHexValue:@"#434343"];
    
    cell.detailTextLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize14];
    cell.detailTextLabel.textColor = [UIColor getUIColorFromHexValue:@"#797979"];

    
    return cell;
}

-(void)infoTapped:(id)sender
{
    [self.searchView resignFirstResponder];
    
    UIButton * button = (UIButton *) sender;
    
    if(self.popOverController != nil)
    {
        [self.popOverController dismissPopoverAnimated:YES];
        self.popOverController = nil;
    }
   
    SFMLookUpDeatilViewController * lookUpDetail = [[SFMLookUpDeatilViewController alloc] init];
    lookUpDetail.lookUpObject = self.lookUpObject;
    lookUpDetail.SelectedIndex =  button.tag;
    
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:lookUpDetail];
    [self.popOverController setPopoverContentSize:CGSizeMake(360, 200)];

    [self.popOverController presentPopoverFromRect:button.imageView.frame inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (IBAction)addFilters:(id)sender {
    
    [self.searchView resignFirstResponder];
    
    UIButton *button = (UIButton *)sender;
    
    if(self.popOverController.isPopoverVisible)
    {
        [self.popOverController dismissPopoverAnimated:YES];
        self.popOverController = nil;
    }
    SFMLookUpFilterViewController *filterView = [[SFMLookUpFilterViewController alloc] init];
    filterView.dataSource = self.lookUpObject.advanceFilters;
    filterView.delegate = self;
    
    
    CGSize size = [filterView getPoPOverContentSize];
    
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:filterView];
    [self.popOverController setPopoverContentSize:size];
    
    self.popOverController.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = button.frame;
    frame.origin.x = frame.origin.x;
    
    self.popOverController.popoverLayoutMargins = UIEdgeInsetsMake(0, 200, 0, 180);
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        self.popOverController.popoverLayoutMargins = UIEdgeInsetsMake(0, 300, 0, 50);
    }
    
    [self.popOverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)dismissPoPover
{
    if(self.popOverController != nil)
    {
        [self.popOverController dismissPopoverAnimated:YES];
        self.popOverController = nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchView resignFirstResponder];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    SFMRecordFieldData * recordField = [self getRecordFieldForIndexPath:indexPath];
    
    if([self isSelectedAtIndexPath:indexPath])
    {
        [self removeSelectedRecordForIndexPath:recordField];
        cell.imageView.image = [UIImage imageNamed:UnselectImg];
    }
    else
    {
        SFMRecordFieldData * nameField = [self getNameFieldForIndexPath:indexPath];
        recordField.displayValue = nameField.displayValue;
        [self.selectedRecords addObject:recordField];
        cell.imageView.image = [UIImage imageNamed:SelectImg];
    }
    if(self.selectionMode == singleSelectionMode)
    {
        NSMutableArray * removeRecords = [NSMutableArray array];
        for (SFMRecordFieldData * selectedRecord in self.selectedRecords ) {
            
            NSIndexPath * selectedIndexPath = [self getIndexPathForRecord:selectedRecord];
            UITableViewCell * prevSelectedCell = [tableView cellForRowAtIndexPath:selectedIndexPath];
            if(![recordField.internalValue isEqualToString:selectedRecord.internalValue])
            {
                prevSelectedCell.imageView.image = [UIImage imageNamed:UnselectImg];
                [removeRecords addObject:selectedRecord];
            }
        }
        
        for (NSIndexPath * removeRecord in removeRecords) {
            
            [self.selectedRecords removeObject:removeRecord];
        }
    }
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    /*
    self.lookUpObject.searchString = searchBar.text;
    [self loadLookUpData];
    [self.tableView reloadData];

    [searchBar resignFirstResponder];
    */
    
//    self.lookUpObject.searchString = searchBar.text;
    [self searchButtonActionMethod:nil];
    //    [self loadLookUpData];
    //    [self.tableView reloadData];
    
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.lookUpObject.searchString = nil;
    [self loadLookUpData];
    //[self removePreviouslySelectedData]; //IPAD-4733
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
    
}

-(void)removePreviouslySelectedData
{
    [self.selectedRecords removeAllObjects];
}

-(NSString *)getTitleForIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dictionary = [self.lookUpObject.dataArray  objectAtIndex:indexPath.row];
    NSString * defaultColumnName = self.lookUpObject.defaultColoumnName;
    
    SFMRecordFieldData *recordField  = [dictionary objectForKey:defaultColumnName];
    return     recordField.displayValue;
}
-(NSString *)getdetailTextForIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dictionary = [self.lookUpObject.dataArray  objectAtIndex:indexPath.row];
    SFNamedSearchComponentModel * componentModel  = nil;
    if([self.lookUpObject.displayFields count] > 0)
    {
        componentModel = [self.lookUpObject.displayFields objectAtIndex:0];

        if([componentModel.fieldName isEqualToString:self.lookUpObject.defaultColoumnName]){
            if([self.lookUpObject.displayFields count] >= 2)
            {
                 componentModel = [self.lookUpObject.displayFields objectAtIndex:1];
            }
            else
            {
                componentModel = nil;
            }
        }
        
    }
    NSString * detailFieldName  = componentModel.fieldName;
    SFMRecordFieldData *recordField  = [dictionary objectForKey:detailFieldName];
    return recordField.displayValue;
}

- (IBAction)addSelectedItems:(id)sender{
    
    //update view controller with delegate
    if([self.delegate conformsToProtocol:@protocol(PageEditControlDelegate) ])
    {
        for (SFMRecordFieldData * recordField in self.selectedRecords) {
            recordField.name = self.callerFieldName;
        }
        
        [self addOnlineRecordToObjectNameFieldValueForSingleSelectionMode];
        
        [self.delegate valuesForField:self.selectedRecords forIndexPath:self.indexPath selectionMode:self.selectionMode];
    }
    [self dismissLookUpForm];
    
}

- (IBAction)cancelButtonClicked:(id)sender {
    
    [self dismissLookUpForm];
}

-(void)dismissLookUpForm
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)addOnlineRecordToObjectNameFieldValueForSingleSelectionMode {
    
    @autoreleasepool {
        NSMutableDictionary *onlineRecords = [[CacheManager sharedInstance] getCachedObjectByKey:kObjectNameFieldValueCacheData];
        
        if (onlineRecords == nil) {
            onlineRecords = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        
        NSArray *allKeys = [onlineRecords allKeys];
        
        for(SFMRecordFieldData *recordField in self.selectedRecords) {
            
            if (![allKeys containsObject:recordField.internalValue] && [SFMLookUpViewController isOnlineRecord:recordField]) {
                NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
                [currentDictionary setValue:recordField.internalValue forKey:@"Id"];
                [currentDictionary setValue:recordField.displayValue forKey:@"Value"];
                TransactionObjectModel *model = [[TransactionObjectModel alloc] init];
                [model mergeFieldValueDictionaryForFields:currentDictionary];
                
                [onlineRecords setObject:model forKey:recordField.internalValue];
            }
        }
        
        [[CacheManager sharedInstance] pushToCache:onlineRecords byKey:kObjectNameFieldValueCacheData];
    }
}

-(BOOL)isSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dictionary = [self.lookUpObject.dataArray  objectAtIndex:indexPath.row];
 //   SFMRecordFieldData * selectedIndexPath = [dictionary objectForKey:@"Id"];
//    SFMRecordFieldData * selectedIndexPath = [dictionary objectForKey:@"localId"];
//    
//    BOOL isOnlineRecord = [SFMLookUpViewController isOnlineRecord:selectedIndexPath];
//    if (isOnlineRecord == YES) {
//        selectedIndexPath = [dictionary objectForKey:@"Id"];
//    }
    
    /*  this change for record-Id or record-localId */
    SFMRecordFieldData * selectedIndexPath = [SFMLookUpViewController getSfIdOrLocalIdOfTheRecord:dictionary];

    for (int counter = 0; counter < [self.selectedRecords count]; counter ++)
    {
        SFMRecordFieldData * recordField = [self.selectedRecords objectAtIndex:counter];
        if([selectedIndexPath.internalValue isEqualToString:recordField.internalValue])
        {
            return YES;
        }
    }

    return NO;
}

-(void)addRecordfieldForIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dictionary = [self.lookUpObject.dataArray  objectAtIndex:indexPath.row];
//    SFMRecordFieldData * recordField = [dictionary objectForKey:@"Id"];
//    SFMRecordFieldData * recordField = [dictionary objectForKey:@"localId"];
//    BOOL isOnlineRecord = [SFMLookUpViewController isOnlineRecord:recordField];
//    
//    if (isOnlineRecord == YES) {
//        recordField = [dictionary objectForKey:@"Id"];
//    }
    
    /*  this change for record-Id or record-localId */
    SFMRecordFieldData * recordField = [SFMLookUpViewController getSfIdOrLocalIdOfTheRecord:dictionary];
    [self.selectedRecords addObject:recordField];
}

-( NSIndexPath *)getIndexPathForRecord:(SFMRecordFieldData *)fieldData
{
    NSIndexPath * indexPath = nil;
    
    for (int counter = 0; counter < [self.lookUpObject.dataArray count]; counter ++)
    {
        NSDictionary * dictionary = [self.lookUpObject.dataArray  objectAtIndex:counter];
////        SFMRecordFieldData * recordField = [dictionary objectForKey:@"Id"];
//        SFMRecordFieldData * recordField = [dictionary objectForKey:@"localId"];
//        BOOL isOnlineRecord = [SFMLookUpViewController isOnlineRecord:recordField];
//        
//        if (isOnlineRecord == YES) {
//            recordField = [dictionary objectForKey:@"Id"];
//        }
        
        
        /*  this change for record-Id or record-localId */
        SFMRecordFieldData * recordField = [SFMLookUpViewController getSfIdOrLocalIdOfTheRecord:dictionary];
         if([recordField.internalValue isEqualToString:fieldData.internalValue])
         {
             indexPath =[NSIndexPath indexPathForRow:counter inSection:0];
         }
    }
    return indexPath;
}

-( SFMRecordFieldData *)getRecordFieldForIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dictionary = [self.lookUpObject.dataArray  objectAtIndex:indexPath.row];
    
//    SFMRecordFieldData * recordField = [dictionary objectForKey:@"Id"];
    /*
    SFMRecordFieldData * recordField = [dictionary objectForKey:@"localId"];
    BOOL isOnlineRecord = [SFMLookUpViewController isOnlineRecord:recordField];
    
    if (isOnlineRecord == YES) {
        recordField = [dictionary objectForKey:@"Id"];
    }
     */
    
    /*  this change for record-Id or record-localId */
    return [SFMLookUpViewController getSfIdOrLocalIdOfTheRecord:dictionary];
}
-( SFMRecordFieldData *)getNameFieldForIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dictionary = [self.lookUpObject.dataArray  objectAtIndex:indexPath.row];
    SFMRecordFieldData * recordField = nil;
    if(self.lookUpObject.defaultColoumnName != nil){
        recordField = [dictionary objectForKey:self.lookUpObject.defaultColoumnName];
    }
    if ([StringUtil isStringEmpty:recordField.displayValue] && self.lookUpObject.defaultObjectColumnName != nil ) {
        recordField = [dictionary objectForKey:self.lookUpObject.defaultObjectColumnName];
    }
    return recordField;
}

-(void)removeSelectedRecordForIndexPath:(SFMRecordFieldData *)fieldData
{

    SFMRecordFieldData *removeRecordField = nil;
    
    for (int counter = 0; counter < [self.selectedRecords count]; counter ++)
    {
        SFMRecordFieldData * recordField = [self.selectedRecords objectAtIndex:counter];
        if([fieldData.internalValue isEqualToString:recordField.internalValue])
        {
            removeRecordField = recordField;
        }
    }
    
    if(removeRecordField != nil){
        
        [self.selectedRecords removeObject:removeRecordField];
    }
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    /*
     Damodar
     Hack code: This code enables the search key even if there are no text in search bar text field
     (By default Apple disables the search key on the keyboard until a text character is present)
     
     UISearchBar [ iOS 7 hierarchy ]
     |------> UIView (0 0 320 44)
     |------> UISearchBarBackground
     |------> UISearchBarTextField
     
     #warning : If this hierarchy changes with OS updates then this code breaks.
     */
    
    NSArray *searchBarViews = [[self.searchView.subviews objectAtIndex:0] subviews];
    UITextField *searchBarTextField = nil;
    for (UIView *subview in searchBarViews)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchBarTextField = (UITextField *)subview;
            break;
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
{
    if (!self.isOnlineLookUpSelected) {
        [self searchButtonActionMethod:nil];
    }
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

+ (BOOL)isOnlineRecord:(SFMRecordFieldData*)recordFieldData
{
    if (recordFieldData.internalValue.length > 30) {
        return NO;
    } else {
        return YES;
    }
}
#pragma mark - Keyboard notification method
- (void)keyboardWillHideNotificationReceived:(NSNotification *)sender
{
    if(self.popOverController != nil)
    {
        [self.popOverController dismissPopoverAnimated:YES];
        self.popOverController = nil;
    }
}

-(IBAction)singleAddClicked:(id)sender
{
    if( self.selectionMode == multiSelectionMode)
    {
        if(self.selectedRecords  == nil)
        {
            self.selectedRecords = [[NSMutableArray alloc] initWithCapacity:0];
        }
        
        SFMRecordFieldData * recordField = [[SFMRecordFieldData alloc] initWithFieldName:self.callerFieldName value:@"" andDisplayValue:@""];
        [self.selectedRecords addObject:recordField];
        
        [self.delegate valuesForField:self.selectedRecords forIndexPath:self.indexPath selectionMode:self.selectionMode];
    }

    [self dismissLookUpForm];
}

#pragma mark - Barcode Scanner Utility
- (void) barcodeSuccessfullyDecodedWithData:(NSString *)decodedData
{
    self.searchView.text = decodedData;
    self.lookUpObject.searchString = decodedData;
    [self loadLookUpData];
//    [self removePreviouslySelectedData];
    [self.tableView reloadData];
}
- (void) barcodeCaptureCancelled
{
    
}

#pragma  End -


#pragma mark - Advance LookUpFilters

- (void)fillLookUpSearchFilterMetaData
{
    NSArray *preFilters = [self getPrefilterInfo];
    
    if (preFilters != nil) {
        self.lookUpObject.preFilters = preFilters;
    }
    
    if (self.selectionMode == singleSelectionMode || self.selectionMode == multiSelectionMode) {
        NSArray *advnaceFilter = [self getAdvanceFilterInfo];
        if (advnaceFilter != nil) {
            self.lookUpObject.advanceFilters = advnaceFilter;
        }
        if (![StringUtil isStringEmpty:self.lookUpObject.contextLookupFilter.lookupContext] && self.lookUpObject.contextLookupFilter) {
            if(advnaceFilter.count)
            {
                NSMutableArray *arr = [NSMutableArray arrayWithArray:advnaceFilter];
                [arr insertObject:self.lookUpObject.contextLookupFilter atIndex:0];
                self.lookUpObject.advanceFilters = (NSArray*)arr;
            }
            else
            {
                self.lookUpObject.advanceFilters = [NSArray arrayWithObjects:self.lookUpObject.contextLookupFilter, nil];
            }
            
        }
    }
}

- (NSArray *)getPrefilterInfo
{
    return [self.lookUpHelper getLookupSearchFiltersForId:self.lookUpObject.lookUpId forType:kSearchFilterObject];
}

- (NSArray *)getAdvanceFilterInfo
{
    return [self.lookUpHelper getLookupSearchFiltersForId:self.lookUpObject.lookUpId forType:kSearchFilterCriteria];
}

- (SFMRecordFieldData *)getValueForLiteral:(NSString *)literal
{    
    return [self.delegate getInternalValueForLiteral:literal];
}
- (SFMRecordFieldData *)getValueForContextFilterForfieldName:(NSString *)fieldName forHeaderObject:(NSString *)headerValue {
    
    return [self.delegate filterCriteriaForContextFilter:fieldName forHeaderObject:headerValue];
}
-(id)getValueForContextFilterThroughDelegateForfieldName:(NSString *)fieldName forHeaderObject:(NSString *)headerValue{
    return [self.delegate filterCriteriaForContextFilter:fieldName forHeaderObject:headerValue];
}

-(id)getLiteralValueThroughDelegateForLiteral:(NSString *)literal;
{
//   Commenting due to re-opening of 026110
// if ([self.delegate isKindOfClass:[PageEditChildListViewController class]])
//        return [self.delegate getInternalValueForLiteralForLookUp:literal];
//    else
        return [self.delegate getInternalValueForLiteral:literal];
}

- (void)applyFilterChanges:(NSArray *)advanceFilter
{
    [self dismissPoPover];
    
    if ([self.lookUpObject.advanceFilters count] > 0) {
        self.lookUpObject.advanceFilters = nil;
    }
    SFMLookUpFilter *filter = [advanceFilter firstObject];
    if (filter.lookupContext != nil && filter.lookupContext.length > 0) {
        self.lookUpObject.contextLookupFilter = filter;
    }
    self.lookUpObject.contextLookupFilter = [advanceFilter firstObject];
    self.lookUpObject.advanceFilters = advanceFilter;
    
    if (!self.isOnlineLookUpSelected) {
        
        [self loadLookUpData];
        //[self removePreviouslySelectedData]; //IPAD-4733
        [self.tableView reloadData];
        [self noRecordsToDisplay];
    }

}
#pragma mark - End
- (void)setSearchBarBackGround
{
    self.searchView.backgroundColor = [UIColor whiteColor];
    self.searchView.searchBarStyle = UIBarStyleBlackTranslucent;
    self.searchView.layer.cornerRadius = 5;
    self.searchView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.searchView.layer.borderWidth = 1;
    [[NSClassFromString(@"UISearchBarTextField") appearanceWhenContainedIn:[UISearchBar class], nil] setBorderStyle:UITextBorderStyleNone];
    self.searchView.layer.borderColor = [UIColor getUIColorFromHexValue:kSeperatorLineColor].CGColor;
    

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self dismissPoPover];
}

-(void)registerForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissPopoverLookUP)
                                                 name:POP_OVER_DISMISS
                                               object:nil];
}

-(void)deregisterForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POP_OVER_DISMISS object:nil];
}

- (void)dismissPopoverLookUP
{
    [self performSelectorOnMainThread:@selector(dismissPopoverIfNeeded) withObject:self waitUntilDone:YES];
}


- (void)dismissPopoverIfNeeded
{
    if ([self.popOverController isPopoverVisible] &&
        self.popOverController) {
        
        [self.popOverController dismissPopoverAnimated:YES];
        self.popOverController = nil;
    }
}

- (IBAction)includeOnlineActionMethod:(id)sender {
    
    if (self.isOnlineLookUpSelected) {
        self.isOnlineLookUpSelected = NO;
        [self.includeOnlineButton setImage:[UIImage imageNamed:@"checkbox-unselected.png"]  forState:UIControlStateNormal];


    }
    else
    {
        self.isOnlineLookUpSelected = YES;
        [self.includeOnlineButton setImage: [UIImage imageNamed:@"checkbox-selected.png"] forState:UIControlStateNormal];

    }
    
}

- (IBAction)searchButtonActionMethod:(id)sender {
    
    self.searchButton.enabled = NO;
    self.lookUpObject.searchString = self.searchView.text;
    if (self.isOnlineLookUpSelected) {
        [self launchOnlineAPI];
    }
    else
    {
        
        [self loadLookUpData];
        //[self removePreviouslySelectedData]; //IPAD-4733
        [self.tableView reloadData];
        [self noRecordsToDisplay];
        [self enableSearchButton];
    }
}

#pragma mark - SFMOnlineLookUpManagerDelegate methods

- (void)onlineLookupSearchSuccessfullwithResponse:(NSMutableArray *)dataArray {
    
    [self.lookUpHelper fillOnlineLookupData:dataArray forLookupObject:self.lookUpObject];
    //[self removePreviouslySelectedData]; //IPAD-4733
    [self.tableView reloadData];
    [self noRecordsToDisplay];
    [self enableSearchButton];

}

- (void)onlineLookupSearchFailedwithError:(NSError *)error {
    
    [self enableSearchButton];
    
    @synchronized([self class]) {
        
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
    }

}

-(void)enableSearchButton
{
    self.searchButton.enabled = YES;

}


/* In this function i am checking for sfid and localId */
+(SFMRecordFieldData *)getSfIdOrLocalIdOfTheRecord:(NSDictionary *)dictionary
{
    /* here we are checking for sfId, If id is there then we are sending sfId otherwise sending localId of the record */
    SFMRecordFieldData * recordField = [dictionary objectForKey:@"Id"];
    if (recordField)
    {
        if (![StringUtil checkIfStringEmpty:recordField.internalValue])
        {
            return recordField;
        }
    }
    
    /* if sfid is not there then sending local id of the record */
    recordField = [dictionary objectForKey:@"localId"];
    if (recordField) {
        return recordField;
    }
    
    /* else sending blanck string */
    return nil;
}


@end
