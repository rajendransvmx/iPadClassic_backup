//
//  PageEditMutiSelectFieldController.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 14/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "PageEditMultiSelectFieldController.h"
#import "StringUtil.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "TagManager.h"

@interface PageEditMultiSelectFieldController ()
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *multiSelectTable;
@property (weak, nonatomic) IBOutlet UITableView *selectedItemTable;
@property (weak, nonatomic) IBOutlet UILabel *selectedItemlabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedlabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleLabel;

@property (nonatomic, strong)NSMutableArray *selectedItemArray;
@property (nonatomic, strong)NSString *fieldTitle;

/* Search Bar*/
@property (nonatomic, assign)BOOL searchOn;
@property (nonatomic, strong)NSArray *searchResults;

@end

@implementation PageEditMultiSelectFieldController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title recordData:(SFMRecordFieldData *)model
{
    if (self = [super init]){
        self.recordData = model;
        _fieldTitle = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpUI];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.view.superview.bounds = CGRectMake(0, 0, 700, 600);
    self.view.superview.layer.masksToBounds = YES;
    self.view.superview.layer.cornerRadius  = 6.0;
}

-(void)setUpUI
{
    [self defaultSetUp];
    [self setLabelValues];
    [self customizeSeachBar];
    [self updateSelectedValueDataSource];
}

- (void)updateSelectedValueDataSource
{
    NSString *string = self.recordData.displayValue;
    if ([string length] > 0){
        self.selectedItemArray =  [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@";"]];
    }
}

-(void)defaultSetUp
{
    self.selectedItemTable.layer.cornerRadius = 5.0;
    self.selectedItemTable.layer.borderWidth = 2.0;
    self.selectedItemTable.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.selectedItemTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.selectedItemlabel.text = @"Tap any item to add to Selected List";
    self.selectedItemlabel.textColor = [UIColor colorWithHexString:@"#434343"];
    
    self.selectedlabel.text = @"Selected";
}

- (void)setLabelValues
{
    NSDictionary *barButtonItemAttributes = @{NSFontAttributeName: [UIFont fontWithName:kHelveticaNeueThin size:kFontSize16], NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#E15001"]};
    
    [self.cancelButton setTitle:[[TagManager sharedInstance] tagByName:kCancelButtonTitle]];
    [self.cancelButton setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
    [self.updateButton setTitle:@"Update"];
    [self.updateButton setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
    [self.titleLabel setTitle:self.fieldTitle];
    [self.titleLabel setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18], NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateNormal];
    self.titleLabel.enabled = NO;
}

- (void)customizeSeachBar
{
    self.searchBar.layer.borderWidth = 1.0;
    self.searchBar.layer.cornerRadius = 5.0;
    self.searchBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.searchBar.delegate = self;
  //  [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource and Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [self getNumberOfRows:tableView];
    
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"CellIdentiifier"];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentiifier"];
    }
    
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#434343"];
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
    
    cell.textLabel.text = [self textForCell:tableView indexPath:indexPath];
    
    if (tableView == self.selectedItemTable){
        
        cell.textLabel.text = [self.selectedItemArray objectAtIndex:indexPath.row];
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RemoveNew.png"]];
        view.userInteractionEnabled = YES;
        view.tag = indexPath.row;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeSelecteditem:)];
        tap.numberOfTapsRequired = 1;
        [view addGestureRecognizer:tap];
        
        cell.accessoryView = view;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.multiSelectTable) {
        
        if (self.selectedItemArray == nil) {
            self.selectedItemArray = [NSMutableArray new];
        }
        NSString *item = [self textForCell:tableView indexPath:indexPath];
        if (![StringUtil isStringEmpty:item] && ![self.selectedItemArray containsObject:item]) {
            [self.selectedItemArray addObject:item];
            [self reloadSelectedTableView];
        }
    }
}

#pragma mark - END

- (void)removeSelecteditem:(id)sender
{
    UITapGestureRecognizer * gesture = (UITapGestureRecognizer *) sender;
    
    UIImageView * imgView = (UIImageView *)gesture.view;
    
    if ([self.selectedItemArray count] > 0) {
        [self.selectedItemArray removeObjectAtIndex:imgView.tag];
        [self reloadSelectedTableView];
    }
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)updateData:(id)sender
{
    NSString *selectedValue = [self getSelectedData];
    
    self.recordData.internalValue = selectedValue;
    self.recordData.displayValue = selectedValue;
    
    [self.delegate valueForField:self.recordData forIndexPath:self.indexPath sender:self];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSString *)getSelectedData
{
    return [self.selectedItemArray componentsJoinedByString:@";"];
}

- (void)reloadSelectedTableView
{
    [self.selectedItemTable reloadData];
}

- (void)reloadTableOnSearch
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.multiSelectTable reloadData];
                   });
}

- (NSInteger)getNumberOfRows:(UITableView *)tableView
{
    NSInteger rows = 0;
    
    if (tableView == self.multiSelectTable) {
        if (self.searchOn) {
            rows = [self.searchResults count];
        }
        else {
            rows = [self.dataSource count];
        }
    }
    else if (tableView == self.multiSelectTable){
        rows = [self.searchResults count];
    }
    else if (tableView == self.selectedItemTable) {
        rows = [self.selectedItemArray count];
    }
    return rows;
}

- (NSString *)textForCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *text = @"";
    if (tableView == self.multiSelectTable) {
        if (self.searchOn) {
            text = [self.searchResults objectAtIndex:indexPath.row];
        }
        else {
            text = [self.dataSource objectAtIndex:indexPath.row];
        }
    }
    else {
        text = [self.selectedItemArray objectAtIndex:indexPath.row];
    }
    return text;
}

#pragma mark - SearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchResults = nil;
    [self searchDataInMultiTable:searchText];
    [self.multiSelectTable reloadData];
}

- (void)searchDataInMultiTable:(NSString *)searchText
{
    if ([searchText length] > 0 && ![searchText isEqualToString:@" "]) {
        
        self.searchOn = YES;
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", searchText];
        NSArray *newArray = [self.dataSource filteredArrayUsingPredicate:resultPredicate];
        if ([newArray count] > 0) {
            self.searchResults = newArray;
        }
        NSLog(@"newArray = %@", self.searchResults);
    }
    else {
        self.searchOn = NO;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
#pragma mark - END

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}
@end
