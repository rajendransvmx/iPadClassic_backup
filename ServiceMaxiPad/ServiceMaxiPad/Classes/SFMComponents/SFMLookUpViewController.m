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

@interface SFMLookUpViewController ()
@property (nonatomic, strong) SFMPageLookUpHelper * lookUpHelper;
@property (nonatomic, strong) SFMLookUp *lookUpObject;

@property (nonatomic, strong) NSMutableArray *selectedRecords;
@property (nonatomic, strong) UIPopoverController * popOverController;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lookUpHelper   = [[SFMPageLookUpHelper alloc] init];
    self.lookUpObject   = [[SFMLookUp alloc] init];
    self.selectedRecords = [[NSMutableArray alloc] init];
    
    
    self.lookUpObject.lookUpId   = self.lookUpId;
    self.lookUpObject.objectName = self.objectName;
    
    [self setTableHeaderView];
    [self setUpViews];
    
    [self loadLookUpMetadata];
    [self loadLookUpData];
    
    [self.searchView becomeFirstResponder];
    self.searchView.delegate = self;
    self.SerachObjectName.text = self.lookUpObject.serachName;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotificationReceived:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)setUpViews
{
    NSDictionary *barButtonItemAttributes = @{NSFontAttributeName: [UIFont fontWithName:kHelveticaNeueThin size:kFontSize16], NSForegroundColorAttributeName :[UIColor colorWithHexString:@"#E15001"]};
    
    
    self.lookUpToolBar.backgroundColor = [UIColor colorWithHexString:kPageViewMasterBGColor];
    self.searchView.layer.borderWidth = 2;
    self.searchView.layer.borderColor = [UIColor colorWithHexString:kPageViewMasterBGColor].CGColor;
    self.searchView.layer.cornerRadius = 5;
    
    [self.cancelBarButtonItem setTitle:[[TagManager sharedInstance] tagByName:kCancelButtonTitle]];
    [self.cancelBarButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
    [self.addSelectedButtonItem setTitle:@"Add Selected"];
    [self.addSelectedButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
    NSString * objectLabel = [ self.lookUpHelper getObjectLabel:self.objectName];
    NSString * titleStr = [[NSString alloc] initWithFormat:@"%@ Lookup",objectLabel];
    
    [self.titleBarButtonItem setTitle:titleStr];
    [self.titleBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18],NSForegroundColorAttributeName :[UIColor  blackColor]} forState:UIControlStateNormal];
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
    self.view.superview.bounds = CGRectMake(0, 0, 730, 600);

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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
    tableViewHeader.backgroundColor = [UIColor colorWithHexString:kPageViewMasterBGColor];
    [subView addSubview:tableViewHeader];
    [headerView.contentView addSubview:subView];
    
    tableViewHeader.text = [[NSString alloc] initWithFormat:@"  %@(%d)",@"Search Results",[self.lookUpObject.dataArray count]];
    subView.backgroundColor = [UIColor whiteColor];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
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
   
    UITapGestureRecognizer * gesture =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoTapped:)];
    UIImageView * imgView  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:InfoImage]];
   
    imgView.userInteractionEnabled = YES;
  
    cell.accessoryView = imgView;
    imgView.tag = indexPath.row;
    
    [cell.accessoryView addGestureRecognizer:gesture];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
-(void)infoTapped:(id)sender
{
    NSLog(@"infoButton Tapped");
    UITapGestureRecognizer * gesture = (UITapGestureRecognizer *) sender;
    
     UIView * imgView = gesture.view;
    
    UITableViewCell * cell = (UITableViewCell *)[imgView superview];
    
    //UIImageView * imgView = (UIImageView *)sender;
    
    if(self.popOverController != nil)
    {
        [self.popOverController dismissPopoverAnimated:YES];
        self.popOverController = nil;
    }
   
    
    SFMLookUpDeatilViewController * lookUpDetail = [[SFMLookUpDeatilViewController alloc] init];
    lookUpDetail.lookUpObject = self.lookUpObject;
    lookUpDetail.SelectedIndex =  imgView.tag
;
    
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:lookUpDetail];
    [self.popOverController setPopoverContentSize:CGSizeMake(360, 200)];

    [self.popOverController presentPopoverFromRect:imgView.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
     
}


- (IBAction)addFilters:(id)sender {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    self.lookUpObject.searchString = searchBar.text;
    [self loadLookUpData];
    [self.tableView reloadData];

    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.lookUpObject.searchString = nil;
    [self loadLookUpData];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
    
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

-(BOOL)isSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dictionary = [self.lookUpObject.dataArray  objectAtIndex:indexPath.row];
    SFMRecordFieldData * selectedIndexPath = [dictionary objectForKey:@"Id"];

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
    SFMRecordFieldData * recordField = [dictionary objectForKey:@"Id"];
    [self.selectedRecords addObject:recordField];
}

-( NSIndexPath *)getIndexPathForRecord:(SFMRecordFieldData *)fieldData
{
    NSIndexPath * indexPath = nil;
    
    for (int counter = 0; counter < [self.lookUpObject.dataArray count]; counter ++)
    {
        NSDictionary * dictionary = [self.lookUpObject.dataArray  objectAtIndex:counter];
        SFMRecordFieldData * recordField = [dictionary objectForKey:@"Id"];
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
    SFMRecordFieldData * recordField = [dictionary objectForKey:@"Id"];
    return recordField;
}
-( SFMRecordFieldData *)getNameFieldForIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dictionary = [self.lookUpObject.dataArray  objectAtIndex:indexPath.row];
    SFMRecordFieldData * recordField = nil;
    if(self.lookUpObject.defaultColoumnName != nil){
        recordField = [dictionary objectForKey:self.lookUpObject.defaultColoumnName];
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

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
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

@end
