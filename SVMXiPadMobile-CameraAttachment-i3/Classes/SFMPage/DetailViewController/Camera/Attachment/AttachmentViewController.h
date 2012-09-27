//
//  AttachmentViewController.h
//  TabView
//
//  Created by Siva Manne on 15/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface AttachmentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>
@property (retain, nonatomic) NSMutableDictionary   *dataDict;
@property (retain, nonatomic) NSMutableArray        *itemsArray;
@property (retain, nonatomic) UIWebView *webView;
@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *webActivityIndicator;
@property (retain, nonatomic) IBOutlet UITableView *attachmentsTable;
@property (retain, nonatomic) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) NSString *folderName;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *videoPath;
@property (nonatomic, retain) NSString *pdfPath;
@property (nonatomic, retain) NSString *recordId;
- (void) showHelp;
- (void)loadPDFAtPath:(NSString *)filePath;
- (void)loadImageWithImage:(UIImage *)imageFile;
- (void)loadVideoAtPath:(NSString *)filePath;
- (void) removeSubViews;
- (void) releaseAllViews;
- (NSArray *) getImages;
- (NSArray *) getVideos;
- (NSArray *) getPDF;
- (void)startPlayingMovieWithURLString;
@end
