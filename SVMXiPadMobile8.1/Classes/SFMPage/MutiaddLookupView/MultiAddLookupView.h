//
//  MultiAddLookupView.h
//  iService
//
//  Created by Pavamanaprasad Athani on 08/06/11.
//  Copyright 2011 Bit Order Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "iServiceAppDelegate.h"
#import "LookupField.h"

@protocol MultiAddLookupViewDelegate;

@class iServiceAppDelegate;

@interface MultiAddLookupView : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    
    id <MultiAddLookupViewDelegate> delegate;
    IBOutlet UISearchBar * searchBar;
    IBOutlet UITableView * _tableView;
    IBOutlet UIActivityIndicatorView * activity;
    NSInteger index;
    UIPopoverController * popOver;
    IBOutlet UIButton * multiAddButton;
    
    NSString * objectName, * searchKey;
    NSDictionary * lookupData;
    
    iServiceAppDelegate * appDelegate;
    
    LookupField * lField;
    ZKDescribeSObject * describeObject;
    
    NSMutableArray * selectedObjDetails;
    NSMutableDictionary * objectSelected;
    //sahana offline code for multiadd
    NSString * search_field;
    
    NSMutableDictionary * mapping_dict;
}
@property (nonatomic , retain)  NSMutableDictionary * mapping_dict;
- (IBAction)doneButtonClicked:(id)sender;
@property (nonatomic,retain) NSString * search_field;
@property (nonatomic) NSInteger index;
@property (nonatomic, assign) id <MultiAddLookupViewDelegate> delegate;
@property (nonatomic, retain) UIPopoverController * popOver;
@property (nonatomic, retain) IBOutlet UISearchBar * searchBar;
@property (nonatomic, retain) NSString * objectName, * searchKey;
@property (nonatomic, retain) NSDictionary * lookupData;
@property (nonatomic, retain) LookupField * lField;
@property (nonatomic, retain) NSMutableArray * selectedObjDetails;
@property (nonatomic, retain) NSMutableDictionary * objectSelected;

- (void) setLookupData:(NSDictionary *)_lookupDetails;
- (void) reloadData;
- (void) selectObjectValue:(NSArray *)objectHistory;

#define CHECK       @"true"
#define NOTCHECK    @"false"
@end

@protocol MultiAddLookupViewDelegate <NSObject>

@optional
- (void) addMultiChildRows:(NSMutableDictionary *)array forIndex:(NSInteger) index;

@end
