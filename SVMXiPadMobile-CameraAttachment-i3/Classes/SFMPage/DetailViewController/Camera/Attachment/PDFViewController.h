//
//  PDFViewController.h
//  Navigation
//
//  Created by Siva Manne on 10/06/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFViewController : UIViewController
@property (nonatomic, retain) IBOutlet  UIWebView   *pdfView;
@property (nonatomic, retain)           UIButton    *closeButtonView;
@property (nonatomic, retain)           NSString    *pdfPath;
@property (nonatomic, assign)           BOOL        displayCloseButton;
@property (nonatomic, nonatomic) IBOutlet UIActivityIndicatorView *pdfActivityIndicator;
@end
