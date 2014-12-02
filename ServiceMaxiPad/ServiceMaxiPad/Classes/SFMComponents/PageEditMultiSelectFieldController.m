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
#import "SFMPickerData.h"
#import "BarCodeScannerUtility.h"
#import "Utility.h"

@interface PageEditMultiSelectFieldController () <BarCodeScannerProtocol>
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

@property (nonatomic, strong)BarCodeScannerUtility *barCodeScanner;

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
    
    [self setSearchBarBackGround];
    
    self.searchBar.inputAccessoryView = [self barcodeView];
}

- (void)updateSelectedValueDataSource
{
    if (self.selectedItemArray == nil) {
        self.selectedItemArray = [NSMutableArray new];
    }
    
    NSString *string = self.recordData.displayValue;
    if ([string length] > 0){
        NSArray *labels = [self.recordData.displayValue componentsSeparatedByString:@";"];
        NSArray *values = [self.recordData.internalValue componentsSeparatedByString:@";"];
        
        for (int i = 0; i <[labels count]; i++) {
            SFMPickerData *model = [[SFMPickerData alloc] initWithPickerValue:[values objectAtIndex:i] label:[labels objectAtIndex:i] index:0];
            [self.selectedItemArray addObject:model];
        }
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
    
    [self.updateButton setTitle:[[TagManager sharedInstance] tagByName:kTag_Update]];
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
    [self resignKeyboard];
    if (tableView == self.multiSelectTable) {
        
        if (self.selectedItemArray == nil) {
            self.selectedItemArray = [NSMutableArray new];
        }
        SFMPickerData *data = [self selectedDataForCell:tableView indexPath:indexPath];
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"pickerLabel CONTAINS[c] %@", data.pickerLabel];
        NSArray *newArray = [self.selectedItemArray filteredArrayUsingPredicate:resultPredicate];
        
        if (data != nil && [newArray count] == 0 ) {
            [self.selectedItemArray addObject:data];
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
    NSString *selectedValue = [self getDisplayValue];
    NSString *internalValue = [self getInternalValue];
    
    self.recordData.internalValue = selectedValue;
    self.recordData.displayValue = internalValue;
    
    [self.delegate valueForField:self.recordData forIndexPath:self.indexPath sender:self];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSString *)getDisplayValue
{
    return [self getSelectedData:YES];
}

- (NSString *)getInternalValue
{
    return [self getSelectedData:NO];
}

- (NSString *)getSelectedData:(BOOL)isDisplayValue
{
    NSMutableString *valueString = [NSMutableString new];
    for (SFMPickerData *model in self.selectedItemArray) {
        if (model != nil) {
            NSString *string = nil;
            if (isDisplayValue) {
                string = model.pickerLabel;
            }
            else {
                string = model.pickerValue;
            }
            
            if ([valueString length] > 0) {
                [valueString appendFormat:@";%@", string];
            }
            else {
                [valueString appendFormat:@"%@", string];
            }
        }
    }
    return valueString;
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
    SFMPickerData *model = nil;
    if (tableView == self.multiSelectTable) {
        if (self.searchOn) {
            model = [self.searchResults objectAtIndex:indexPath.row];
            if (model != nil) {
                text = model.pickerLabel;
            }
        }
        else {
            model = [self.dataSource objectAtIndex:indexPath.row];
            if (model != nil) {
                text = model.pickerLabel;
            }
        }
    }
    else {
        model = [self.selectedItemArray objectAtIndex:indexPath.row];
        if (model != nil) {
            text = model.pickerLabel;
        }
    }
    return text;
}


- (SFMPickerData *)selectedDataForCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    SFMPickerData *model = nil;
    if (tableView == self.multiSelectTable) {
        if (self.searchOn) {
            model = [self.searchResults objectAtIndex:indexPath.row];
        }
        else {
            model = [self.dataSource objectAtIndex:indexPath.row];
        }
    }
    return model;
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
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"pickerLabel CONTAINS[c] %@", searchText];
        NSArray *newArray = [self.dataSource filteredArrayUsingPredicate:resultPredicate];
        if ([newArray count] > 0) {
            self.searchResults = newArray;
        }
       // NSLog(@"newArray = %@", self.searchResults);
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

- (void)setSearchBarBackGround
{
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.searchBarStyle = UIBarStyleBlackTranslucent;
    self.searchBar.layer.cornerRadius = 5;
    self.searchBar.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.searchBar.layer.borderWidth = 1;
    [[NSClassFromString(@"UISearchBarTextField") appearanceWhenContainedIn:[UISearchBar class], nil] setBorderStyle:UITextBorderStyleNone];
    self.searchBar.layer.borderColor = [UIColor colorWithHexString:kSeperatorLineColor].CGColor;
}

- (void)resignKeyboard
{
    [self.searchBar resignFirstResponder];
}

- (UIView *)barcodeView
{
    if ([Utility isCameraAvailable]) {
        UIView *barCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
        barCodeView.backgroundColor = [UIColor colorWithHexString:@"B5B7BE"];
        
        CGRect buttonFrame = CGRectMake(0, 6, 72, 32);
        
        UIButton *barCodeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [barCodeButton setBackgroundImage:[UIImage imageNamed:@"barcode.png"] forState:UIControlStateNormal];
        
        CGFloat xPosition = CGRectGetWidth(barCodeView.frame) - 90;
        buttonFrame.origin.x = xPosition;
        
        barCodeButton.frame = buttonFrame;
        
        barCodeButton.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [barCodeButton addTarget:self
                          action:@selector(lauchBarCode)
                forControlEvents:UIControlEventTouchUpInside];
        [barCodeView addSubview:barCodeButton];
        
        return barCodeView;
    }
    return nil;
    
}

- (void)lauchBarCode
{
    if (self.barCodeScanner == nil) {
        self.barCodeScanner = [[BarCodeScannerUtility alloc] init];
        self.barCodeScanner.scannerDelegate = self;
    }
    [self.barCodeScanner loadScannerOnViewController:self];
}
- (void)barcodeSuccessfullyDecodedWithData:(NSString *)decodedData
{
    self.searchBar.text = decodedData;
    [self reloadTableOnBarCodeSearch:decodedData];
}

- (void)reloadTableOnBarCodeSearch:(NSString *)data
{
    self.searchResults = nil;
    [self searchDataInMultiTable:data];
    [self.multiSelectTable reloadData];
}

- (void)barcodeCaptureCancelled
{
    SXLogInfo(@"Barcode Cancelled");
}
@end
