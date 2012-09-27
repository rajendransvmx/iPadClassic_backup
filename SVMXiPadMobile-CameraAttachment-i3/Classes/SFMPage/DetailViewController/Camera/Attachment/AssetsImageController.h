//
//  AssetsImageController.h
//  iService
//
//  Created by Siva Manne on 29/06/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@protocol AssetsImageDelegate
- (void)dismissAssetsPopOver;
@end

@interface AssetsImageController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *assets;
}
@property (nonatomic, retain) NSDictionary *attachmentDataDict;
@property (nonatomic, retain) IBOutlet UITableView *imageTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *acitivity;
@property (nonatomic, assign) id<AssetsImageDelegate> delegate;
- (IBAction) attachAssetsImagesToRecord:(id)sender;
-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize ;
@end
