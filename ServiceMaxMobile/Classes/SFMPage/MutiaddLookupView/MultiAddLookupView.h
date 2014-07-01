//
//  MultiAddLookupView.h
//  iService
//
//  Created by Pavamanaprasad Athani on 08/06/11.
//  Copyright 2011 Bit Order Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AppDelegate.h"
#import "LookupField.h"

@protocol MultiAddLookupViewDelegate;

@class AppDelegate;

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
    
    AppDelegate * appDelegate;
    
    LookupField * lField;
    ZKDescribeSObject * describeObject;
    
    NSMutableArray * selectedObjDetails;
    NSMutableDictionary * objectSelected;
    //sahana offline code for multiadd
    NSString * search_field;  
    UITextField *txtField;
    ZBarReaderViewController *reader;
}
@property (nonatomic , retain)  NSMutableArray * mappingArray;
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
//Radha - Defect Fix 6483
@property (nonatomic, retain) NSString * searchId;

- (void) setLookupData:(NSDictionary *)_lookupDetails;
- (void) reloadData;
- (void) selectObjectValue:(NSArray *)objectHistory;
-(void) searchBarcodeResult:(NSString *) searchText;
-(void) updateTxtField: (NSString *) barCodeData;
- (NSArray *)getSubViews;

#define CHECK       @"true"
#define NOTCHECK    @"false"
@end

@protocol MultiAddLookupViewDelegate <NSObject>

@optional
- (void) addMultiChildRows:(NSMutableDictionary *)array forIndex:(NSInteger) index;
- (void) dismissMultiaddLookup;
@end
