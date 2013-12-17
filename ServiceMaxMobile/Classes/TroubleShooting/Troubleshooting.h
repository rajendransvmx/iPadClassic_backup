//
//  Troubleshooting.h
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSInterfaceObject.h"
#import "ProductManual.h"
#import "Chatter.h"
#import "ZipArchive.h"
#import "AppDelegate.h"

@protocol TroubleshootingDelegate

@optional
- (void) showMap;

@end

@class MoviePlayer;

@interface Troubleshooting : UIViewController
<UITableViewDelegate,
UITableViewDataSource,
ProductManualDelegate,
ChatterDelegate,
UIWebViewDelegate,
UISearchBarDelegate>
{
    AppDelegate * appDelegate;
    id <TroubleshootingDelegate> delegate;
    
    iOSInterfaceObject * iOSObject;
    NSString * productName, * productId;
    
    ZipArchive * zip;

    IBOutlet UITableView * tableView;
    NSMutableArray * array;
    
    BOOL willGoToMap;
    
    IBOutlet UISearchBar * mSearchBar;
    IBOutlet UIActivityIndicatorView * activity;
    
    int count;

    MoviePlayer * moviePlayer;
    
    IBOutlet UILabel * subject;
    IBOutlet UIWebView * webView;
    
    NSString * folderNameToCreate;
    
    IBOutlet UIButton * back, * forward;
    
    NSString * fileId, * fileName;
    
    int referenceCount;
    
    NSString * lastClickedFile;
    NSUInteger lastClickedIndex;
    
    BOOL isLoaded;
    
    BOOL downloadInProgress;
    
    NSURLConnection * connection;
    
    //Radha 22nd April 2011
    //For Localization
    IBOutlet UIButton * backButton;
    IBOutlet UINavigationItem * navBar;
    
    IBOutlet UINavigationBar * navigationBar;
    
    NSString * serviceMax, * alert_ok, * noMatch;
    
    BOOL didGetProductName;

    BOOL didRunOperation;
    
    NSInteger _index;
    
    //shrinivas
    BOOL isSessionInvalid;
}


@property (nonatomic, assign) id <TroubleshootingDelegate> delegate;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productId;
@property BOOL isSessionInvalid;
@property (nonatomic,retain) IBOutlet UINavigationBar * navigationBar;

//- (void) showResults;//  Unused Methods

//Radha 20th August 2011
- (void) getProductNameForProductID:(NSString *)productTd;

- (IBAction) Help;

- (IBAction) Done;
- (IBAction) GoToMap;

- (IBAction) showProductManual;
- (IBAction) showChatter;

- (BOOL) unzipAndViewFile:(NSString *)_file;
- (NSString *) showTroubleshootingForIndex:(NSUInteger)index;

//- (void) showFirstTroubleshooting;//  Unused Methods

- (IBAction) goPrev;
- (IBAction) goNext;

- (IBAction) launchSmartVan;


@end
