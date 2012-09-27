//
//  ImageViewController.h
//  Navigation
//
//  Created by Siva Manne on 09/06/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
@property (nonatomic, retain) IBOutlet  UIImageView *imageView;
@property (nonatomic, retain)           UIButton    *closeButtonView;
@property (nonatomic, retain)           NSString    *imageName;
@property (nonatomic, assign)           BOOL        displayCloseButton;
@end
