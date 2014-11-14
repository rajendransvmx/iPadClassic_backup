//
//  PageContentViewController.h
//  ServiceMaxMobile
//
//  Created by Damodar on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (assign, nonatomic) NSUInteger pageIndex;
@property (strong, nonatomic) NSString *imageFile;

@end
