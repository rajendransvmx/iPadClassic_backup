//
//  PageEditLongTexFieldController.m
//  SFM
//
//  Created by Radha Sathyamurthy on 07/10/14.
//  Copyright (c) 2014 Radha Sathyamurthy. All rights reserved.
//

#import "PageEditLongTexFieldController.h"
#import "StyleGuideConstants.h"
#import "TagManager.h"
#import "StyleManager.h"

@interface PageEditLongTexFieldController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleView;
@property (weak, nonatomic) IBOutlet UIToolbar *tollBar;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong)NSString *tabBarTitle;
@property (nonatomic, strong)SFMRecordFieldData *pageData;



- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;


@end

@implementation PageEditLongTexFieldController

- (id)initWithTitle:(NSString *)title recordData:(SFMRecordFieldData *)model
{
    self = [super init];
    if (self) {
    _tabBarTitle = title;
    _pageData = model;

    }
    return self;
}

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
    // Do any additional setup after loading the view from its nib.
    [self initialSetUp];
    
}

- (void)initialSetUp
{
    NSDictionary *barButtonItemAttributes = @{NSFontAttributeName: [UIFont fontWithName:kHelveticaNeueThin size:kFontSize16], NSForegroundColorAttributeName :[UIColor colorWithHexString:@"#E15001"]};
    
    [self.cancelButton setTitle:[[TagManager sharedInstance] tagByName:kCancelButtonTitle]];
    [self.cancelButton setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
    [self.doneButton setTitle:[[TagManager sharedInstance] tagByName:kDoneButtonTitle]];
    [self.doneButton setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
    [self.titleView setTitle:self.tabBarTitle];
    [self.titleView setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18],NSForegroundColorAttributeName :[UIColor  blackColor]} forState:UIControlStateNormal];
    self.titleView.enabled = NO;
    
    self.textView.delegate = self;
    self.textView.editable = YES;
    self.textView.text = self.pageData.displayValue;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.view.superview.bounds = CGRectMake(0, 0, 600, 415);
    
    self.view.superview.layer.masksToBounds = YES;
    self.view.superview.layer.cornerRadius  = 6.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {

    self.pageData.internalValue = self.textView.text;
    self.pageData.displayValue = self.textView.text;
    
    if ([self.delegate conformsToProtocol:@protocol(PageEditControlDelegate)]) {
        [self.delegate valueForField:self.pageData forIndexPath:self.indexPath sender:self];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
