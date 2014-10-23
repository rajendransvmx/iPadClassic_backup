//
//  SFMLookUpViewController.h
//  ServiceMaxMobile
//
//  Created by Sahana on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageEditControlDelegate.h"

typedef enum : NSUInteger {
    singleSelectionMode,
    multiSelectionMode,
} LookUpSelectionMode;


@interface SFMLookUpViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIPopoverControllerDelegate>
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
@end


#define SelectImg       @"check.png"
#define UnselectImg     @"uncheck.png"

#define InfoImage       @"info.png"


/*
-(void)presentLookUp
 {
 SFMLookUpViewController * lookUp = [[SFMLookUpViewController alloc] initWithNibName:@"SFMLookUpViewController" bundle:nil];
 lookUp.lookUpId= 
 lookUp.indexPath =
 lookUp.delegate =
 lookUp.modalPresentationStyle = UIModalPresentationFormSheet;
 [self presentViewController:lookUp animated:YES completion:^{
 
 }];
 
 }
*/