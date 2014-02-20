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

@protocol ProductManualDelegate

@optional
- (void) showMap;

@end

@interface ProductManual : UIViewController
<UITableViewDelegate, UITableViewDataSource, ChatterDelegate>
{
    id <ProductManualDelegate> delegate;
    
    AppDelegate * appDelegate;
    IBOutlet UITableView * tableView;
    
    iOSInterfaceObject * iOSObject;

    NSString * productName, * productId;
    
    ZipArchive * zip;

    NSArray * bodyArray;
    NSMutableArray *array;
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
    
    NSInteger _index;
    
    IBOutlet UINavigationBar *mainNavigationBar;
    
    IBOutlet UIImageView *backImageView;
}

@property (nonatomic, assign) id <ProductManualDelegate> delegate;

@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic,retain) IBOutlet UINavigationBar *mainNavigationBar;
@property (nonatomic,retain)UIImageView *backImageView;
- (IBAction) Help;
- (IBAction) Done;
- (IBAction) GoToMap;

- (IBAction) showChatter;

- (BOOL) unzipAndViewFile:(NSString *)_file;
- (void) showManualForIndex:(NSUInteger)index;

- (IBAction) launchSmartVan;

@end
