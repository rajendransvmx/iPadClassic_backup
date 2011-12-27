//
//  Troubleshooting.h
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Chatter.h"
#import "iOSInterfaceObject.h"
#import "ZipArchive.h"
#import "Base64.h"

@protocol ProductManualDelegate

@optional
- (void) showMap;

@end

@interface ProductManual : UIViewController
<UITableViewDelegate, UITableViewDataSource, ChatterDelegate>
{
    id <ProductManualDelegate> delegate;
    
    iServiceAppDelegate * appDelegate;
    IBOutlet UITableView * tableView;
    
    iOSInterfaceObject * iOSObject;

    NSString * productName, * productId;
    
    ZipArchive * zip;

    NSArray * array, * bodyArray;
    NSString * folderNameToCreate;
    
    IBOutlet UILabel * topic;
    IBOutlet UIWebView * webView;
    
    BOOL willGoToMap;
    
    IBOutlet UISearchBar * mSearchBar;
    IBOutlet UIActivityIndicatorView * activity;
    
    NSUInteger lastIndex;
    
    NSURLConnection * connection;
    IBOutlet UINavigationItem *navigationBar;
    
    NSString * serviceMax, * alert_ok, * productManual;
    
    BOOL didRunOperation;
}

@property (nonatomic, assign) id <ProductManualDelegate> delegate;

@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productId;

- (IBAction) Help;
- (IBAction) Done;
- (IBAction) GoToMap;

- (IBAction) showChatter;

- (BOOL) unzipAndViewFile:(NSString *)_file;
- (void) showManualForIndex:(NSUInteger)index;

- (IBAction) launchSmartVan;

@end
