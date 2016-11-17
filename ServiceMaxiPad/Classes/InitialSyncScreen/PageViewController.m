//
//  PageViewController.m
//  ServiceMaxMobile
//
//  Created by Damodar on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "PageViewController.h"
#import "InitialSyncContentViewController.h"

@interface PageViewController ()
@property (nonatomic, strong) UIPageViewController *pageViewCtr;
@property (strong, nonatomic) NSArray *pageImages;
@end

@implementation PageViewController

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
    
    self.pageImages = @[@"Tutorial-1.png",
                        @"Tutorial-2.png",
                        @"Tutorial-3.png",
                        @"Tutorial-4.png",
                        @"Tutorial-5.png"];
    
    self.pageViewCtr = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                       navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                     options:nil];
    self.pageViewCtr.dataSource = self;
    
    InitialSyncContentViewController *firstViewController = [self getViewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:firstViewController];
    [self.pageViewCtr setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    self.pageViewCtr.view.frame = CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height-20);
    
    [self addChildViewController:_pageViewCtr];
    [self.view addSubview:_pageViewCtr.view];
    [self.pageViewCtr didMoveToParentViewController:self];

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

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((InitialSyncContentViewController*) viewController).pageIndex;
    
    //return nil if for first page or if index is not found
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self getViewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((InitialSyncContentViewController*) viewController).pageIndex;
    
    //return nil if index is not found
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    //return nil if for last page
    if (index == [self.pageImages count]) {
        return nil;
    }
    
    return [self getViewControllerAtIndex:index];
}

- (InitialSyncContentViewController *)getViewControllerAtIndex:(NSUInteger)index
{
    if([self.pageImages count] == 0) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    InitialSyncContentViewController *tipsRotator = [[InitialSyncContentViewController alloc] initWithNibName:@"InitialSyncContentViewController" bundle:nil];
    tipsRotator.imageFile = self.pageImages[index];
    tipsRotator.pageIndex = index;
    
    return tipsRotator;
}



- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageImages count];
}


- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
