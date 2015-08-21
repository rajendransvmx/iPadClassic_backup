//
//  ProductIQHomeViewController.m
//  ServiceMaxiPad
//
//  Created by Admin on 19/08/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "ProductIQHomeViewController.h"
#import "FileManager.h"
#import "HTMLJSWrapper.h"

@interface ProductIQHomeViewController ()

@end

@implementation ProductIQHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self populateNavigationBar];
    [self loadJsExecuterToView];
    
    
    //TODO:FOR TESTING ONLY. REMOVE IT
    [self debugButtonForProductIQ];
}

/** Populating navigation bar **/
- (void)populateNavigationBar
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Left bar button
    //    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:self.opdocTitleString style:UIBarButtonItemStylePlain target:self action:@selector(popNavigationController:)];
    //    self.navigationItem.leftBarButtonItem = customBarItem;
    
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OPDocBackArrow.png"]];
    
    UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, arrow.frame.size.height)];
    backLabel.text = @"Back";
    backLabel.font = [UIFont systemFontOfSize:17];
    backLabel.textColor = [UIColor whiteColor];
    backLabel.backgroundColor = [UIColor clearColor];
    backLabel.textAlignment = NSTextAlignmentLeft;
    backLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (arrow.frame.size.width + backLabel.frame.size.width), arrow.frame.size.height)];
    backView.backgroundColor = [UIColor clearColor];
    [backView addSubview:arrow];
    [backView addSubview:backLabel];
    backView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backView)];
    [backView addGestureRecognizer:tap];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:backView];
    self.navigationItem.leftBarButtonItem = barBtn;
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    titleLabel.text = @"ProductIQ";
    titleLabel.font = [UIFont boldSystemFontOfSize:21];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    
   
    
}

-(void)debugButtonForProductIQ
{
    
    UILabel *TestLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, 35)];
    TestLabel.text = @"TapToDebug";
    TestLabel.font = [UIFont systemFontOfSize:17];
    TestLabel.textColor = [UIColor whiteColor];
    TestLabel.backgroundColor = [UIColor clearColor];
    TestLabel.textAlignment = NSTextAlignmentLeft;
    TestLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIView *backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 300, (30 + TestLabel.frame.size.width), 35)];
    backView1.backgroundColor = [UIColor clearColor];
    [backView1 addSubview:TestLabel];
    backView1.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(testButton)];
    [backView1 addGestureRecognizer:tap1];
    
    UIBarButtonItem *barBtn1 = [[UIBarButtonItem alloc] initWithCustomView:backView1];
    self.navigationItem.rightBarButtonItem = barBtn1;
    

}
-(void)testButton
{
    [self loadJsExecuterToView];
}
- (void)backView
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}


- (void)loadJsExecuterToView {
    
//    NSString *codeSnippet =  [HTMLJSWrapper getWrapperForCodeSnippet];
    
    NSString *corelibDir = [FileManager getCoreLibSubDirectoryPath];
    corelibDir = [corelibDir stringByAppendingPathComponent:@"PRODUCTJS"];
    corelibDir = [corelibDir stringByAppendingPathComponent:@"src"];

    NSString *htmlfilepath = [corelibDir stringByAppendingPathComponent:@"installigence-index.html"];
    
//    if([[NSFileManager defaultManager] fileExistsAtPath:htmlfilepath])
//        [[NSFileManager defaultManager] removeItemAtPath:htmlfilepath error:NULL];
    
//    [codeSnippet writeToFile:htmlfilepath
//                  atomically:NO
//                    encoding:NSUTF8StringEncoding
//                       error:NULL];
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    if(self.jsExecuter == nil)
    {
        JSExecuter *tempVar = [[JSExecuter alloc] initWithParentView:self.view andCodeSnippet:nil andDelegate:self andFrame:rect];
        self.jsExecuter = tempVar;
        tempVar = nil;
    }
    
    [self.jsExecuter loadHTMLFileFromPath:htmlfilepath];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
