//
//  SFMLookUpViewController.h
//  ServiceMaxMobile
//
//  Created by Sahana on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageEditControlDelegate.h"
#import "BarCodeScannerUtility.h"
#import "SFMLookUpFilter.h"
#import "SFMPageField.h"

typedef enum : NSUInteger {
    singleSelectionMode,
    multiSelectionMode,
} LookUpSelectionMode;


@interface SFMLookUpViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIPopoverControllerDelegate,BarCodeScannerProtocol>
@property (nonatomic, strong) SFMPageField *pageField;
@property (nonatomic,strong) NSString *lookUpId;
@property (nonatomic,strong) NSString * objectName;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (assign, nonatomic) id <PageEditControlDelegate> delegate;
@property (strong, nonatomic) IBOutlet UISearchBar *searchView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *filterButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addSelectedButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (strong, nonatomic) IBOutlet UILabel *SerachObjectName;
@property (strong, nonatomic) IBOutlet UIImageView *barcodeImage;
@property (strong, nonatomic) IBOutlet UIToolbar *lookUpToolBar;
@property (nonatomic) LookUpSelectionMode selectionMode;
@property (strong, nonatomic) NSString *  callerFieldName;
@property (strong, nonatomic) IBOutlet UIButton *singleAddButton;
@property (strong, nonatomic) NSString *contextObjectName;

- (SFMRecordFieldData *)getValueForLiteral:(NSString *)literal;
- (SFMRecordFieldData *)getValueForContextFilterForfieldName:(NSString *)fieldName forHeaderObject:(NSString *)headerValue;

@end


#define SelectImg       @"check.png"
#define UnselectImg     @"uncheck.png"

#define InfoImage       @"info.png"