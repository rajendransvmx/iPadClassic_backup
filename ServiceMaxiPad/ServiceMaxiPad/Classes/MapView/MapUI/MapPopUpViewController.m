//
//  MapPopUpViewController.m
//  MapPopUp
//
//  Created by Anoop on 9/8/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "MapPopUpViewController.h"
#import "TextCell.h"
#import "ContactCell.h"
#import "ServiceLocationCell.h"
#import "ContactImageModel.h"
#import "MapHelper.h"

@interface MapPopUpViewController ()

@property (nonatomic, strong) NSMutableDictionary *titleValueMap;
@property (nonatomic, strong) NSArray *titleData;
@property (nonatomic, strong) NSArray *titleKeyData;
@property (nonatomic, strong) TextCell *textCell;
@property (nonatomic, strong) ContactCell *contactCell;
@property (nonatomic, strong) ServiceLocationCell *serviceLocationCell;

@end

@implementation MapPopUpViewController

static NSString *MapPopUpGenericCellIdentifier = @"MapPopUpGenericCellIdentifier";
static NSString *MapPopUpContactCellIdentifier = @"MapPopUpContactCellIdentifier";
static NSString *MapPopUpServiceLocationCellIdentifier = @"MapPopUpServiceLocationCellIdentifier";


#pragma mark -
#pragma mark === Accessors ===
#pragma mark -

- (NSMutableDictionary *)titleValueMap
{
    if (!_titleValueMap)
    {
        _titleValueMap = [MapHelper objectValueMapDictionary:self.workOrderSummaryModel];
        
    }
    return _titleValueMap;
}

- (NSArray *)titleData
{
    if (!_titleData)
    {
        _titleData = [MapHelper allTagValuesForWorkOrderPopup];
        
    }
    return _titleData;
}

- (NSArray *)titleKeyData
{
    if (!_titleKeyData)
    {
        _titleKeyData = [MapHelper allKeysForWorkOrderPopup];
        
    }
    return _titleKeyData;
}

#pragma mark -
#pragma mark === View Life Cycle ===
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerLabel.text = @"Work Order";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
    _titleData = nil;
    _titleKeyData = nil;
    _titleValueMap = nil;
    _workOrderSummaryModel = nil;
    _contactCell = nil;
    _textCell = nil;
    _serviceLocationCell = nil;
    _headerLabel = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _delegate = nil;
    _tableView = nil;
    
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark === UITableViewDataSource ===
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titleData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self uniqueCellForIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleString = [self.titleData objectAtIndex:indexPath.row];
    NSString *key = [self.titleKeyData objectAtIndex:indexPath.row];
    
    if ([cell isKindOfClass:[TextCell class]])
    {
        TextCell *textCell = (TextCell *)cell;
        if (indexPath.row == 0)
            textCell.descriptionLabel.textColor = [UIColor colorWithRed:255/255 green:80/255 blue:1/255 alpha:1.0f];
        [textCell configureCellWithTitle:titleString
                          andDescription:[self.titleValueMap valueForKey:key]];
    }
    if ([cell isKindOfClass:[ServiceLocationCell class]])
    {
        ServiceLocationCell *serviceLocationCell = (ServiceLocationCell *)cell;
        [serviceLocationCell configureCellWithTitle:titleString
                                 andServiceLocation:[self.titleValueMap valueForKey:key]];
    }
    if ([cell isKindOfClass:[ContactCell class]])
    {
        ContactCell *contactCell = (ContactCell *)cell;
        [contactCell configureCellWithContact:[self.titleValueMap valueForKey:key]
                                     andTitle:titleString];
    }
}

// Use it for cellForRowAtIndexPath
- (id)uniqueCellForIndexPath:(NSIndexPath*)indexPath {
    
    switch (indexPath.row) {
        case cellTypeServiceLocation://Service Location cell
            return [self.tableView dequeueReusableCellWithIdentifier:MapPopUpServiceLocationCellIdentifier forIndexPath:indexPath];
            break;
            
        case cellTypeContact://Contact cell
            return [self.tableView dequeueReusableCellWithIdentifier:MapPopUpContactCellIdentifier forIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    return [self.tableView dequeueReusableCellWithIdentifier:MapPopUpGenericCellIdentifier forIndexPath:indexPath];
    
}

// Use it for heightForRowAtIndexPath
- (UITableViewCell *)dynamicPrototypeCell:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
        case cellTypeServiceLocation://Service Location cell
            if (!_serviceLocationCell)
            {
                _serviceLocationCell = [self.tableView dequeueReusableCellWithIdentifier:MapPopUpServiceLocationCellIdentifier];
            }
            return _serviceLocationCell;
            break;
            
        case cellTypeContact://Contact cell
            if (!_contactCell)
            {
                _contactCell = [self.tableView dequeueReusableCellWithIdentifier:MapPopUpContactCellIdentifier];
            }
            return _contactCell;
            break;
            
        default:
            break;
    }
    if (!_textCell)
    {
        _textCell = [self.tableView dequeueReusableCellWithIdentifier:MapPopUpGenericCellIdentifier];
    }
    return _textCell;
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:[self dynamicPrototypeCell:indexPath] forRowAtIndexPath:indexPath];
    CGSize size = [[self dynamicPrototypeCell:indexPath].contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(showJobDetailsForAnnotationIndex:)]) {
            [self.delegate showJobDetailsForAnnotationIndex:self.workOrderSummaryModel];
        }
    
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    //Xcode 6 iOS 8 changes, xcode 5.1.1 users comment locally
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
       //[self.tableView setLayoutMargins:UIEdgeInsetsZero];
        //[cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
