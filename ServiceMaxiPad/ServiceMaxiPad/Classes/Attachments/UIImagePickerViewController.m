//
//  UIImagePickerViewController.m
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "UIImagePickerViewController.h"
#import "StyleManager.h"

@interface UIImagePickerViewController ()

@end

@implementation UIImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.tintColor = [UIColor colorWithHexString:kOrangeColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotate
{
    return YES;
}
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated    {
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        
        UINavigationBar *bar = navigationController.navigationBar;
        bar.tintColor=[UIColor colorWithHexString:kOrangeColor];
       // UINavigationItem *top = bar.topItem;
        
        //UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(imagePickerControllerDidCancel:)];
       // [top setLeftBarButtonItem:cancel];
        
    } else {
        
        //do non imagePickerController things 
        
    }
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
//    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
//        return YES;
//    }
//    else {
//        return NO;
//    }
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
