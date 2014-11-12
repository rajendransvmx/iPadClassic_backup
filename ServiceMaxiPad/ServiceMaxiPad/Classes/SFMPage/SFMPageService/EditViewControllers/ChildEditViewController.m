//
//  ChildEditViewController.m
//  ServiceMaxMobile
//
//  Created by shravya on 30/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "ChildEditViewController.h"

@interface ChildEditViewController ()

@end

@implementation ChildEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - PageEditDetailViewControllerDelegate methods

- (CGFloat)heightOfTheView {
    return 280.0;
}
- (CGFloat)internalOffsetToSelectedIndex {
    return 0.0;
}
- (void)willRemoveViewFromSuperView {
    
}
- (void)resignAllFirstResponders {
    
}
#pragma mark End


- (void) loadDataWithSfmPage:(SFMPage *)sfmPage
                forIndexPath:(NSIndexPath *)indexPath
{
    self.sfmPage = sfmPage;
    self.selectedIndexPath = indexPath;
}



@end
