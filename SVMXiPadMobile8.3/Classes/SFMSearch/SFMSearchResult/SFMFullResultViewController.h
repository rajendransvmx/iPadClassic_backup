//
//  SFMFullResultViewController.h
//  SFMSearch
//
//  Created by Siva Manne on 12/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#define SectionHeaderHeight      45 

@class iServiceAppDelegate;
@interface SFMFullResultViewController : UIViewController
{
    iServiceAppDelegate * appDelegate;
}
@property (nonatomic, retain) NSDictionary *data;
@property(nonatomic,retain) IBOutlet UIButton *actionButton,*detailButton;
- (IBAction)dismissView:(id)sender;
- (IBAction) accessoryButtonTapped:(id)sender;
@end
