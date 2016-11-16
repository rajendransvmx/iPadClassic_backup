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

@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, assign) CGRect coveredFrame;
@property (nonatomic, assign) CGRect textViewFrame;

@property (nonatomic, strong) UITextView *cTextView;

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
        self.textView.delegate = self;
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initialSetUp
{
    NSDictionary *barButtonItemAttributes = @{NSFontAttributeName: [UIFont fontWithName:kHelveticaNeueThin size:kFontSize16], NSForegroundColorAttributeName :[UIColor colorFromHexString:@"#E15001"]};
    
    [self.cancelButton setTitle:[[TagManager sharedInstance] tagByName:kCancelButtonTitle]];
    [self.cancelButton setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
    [self.doneButton setTitle:[[TagManager sharedInstance] tagByName:kDoneButtonTitle]];
    [self.doneButton setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    
    [self.titleView setTitle:self.tabBarTitle];
    [self.titleView setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18],NSForegroundColorAttributeName :[UIColor  blackColor]} forState:UIControlStateNormal];
    self.titleView.enabled = NO;
    
    //    self.textView.delegate = self;
    //    self.textView.editable = NO;
    //    self.textView.text = self.pageData.displayValue;
    
    self.textView.editable = NO;
    self.textView.userInteractionEnabled = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    
    //    Note: TextView in xib is not being used anymore as the constraint is causing different positions for ios7/ios8/ios9. New Textview is sub-viewed and frame hardcoded. 25-Sept-2015
    
    self.cTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 65, 560, 330)];
    self.textViewFrame = self.cTextView.frame;
    self.cTextView.delegate = self;
    self.cTextView.text = self.pageData.displayValue;
    self.cTextView.font = [UIFont systemFontOfSize:14.0];
    self.cTextView.backgroundColor = [UIColor clearColor];
    self.cTextView.editable = YES;
    [self.view addSubview:self.cTextView];
    
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
    
    self.pageData.internalValue = self.cTextView.text;
    self.pageData.displayValue = self.cTextView.text;
    
    if ([self.delegate conformsToProtocol:@protocol(PageEditControlDelegate)]) {
        [self.delegate valueForField:self.pageData forIndexPath:self.indexPath sender:self];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"])
    {
        [self reconfigureTheFrameOfTextView];
    }
    return YES;
}

- (void)keyboardWasShown:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGRect keyboardInfoFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // get the height of the keyboard by taking into account the orientation of the device too
    CGRect windowFrame = [self.view.window convertRect:self.view.frame fromView:self.view];
    self.keyboardFrame = CGRectIntersection (windowFrame, keyboardInfoFrame);
    self.coveredFrame = [self.view.window convertRect:self.keyboardFrame toView:self.view];
    [self reconfigureTheFrameOfTextView];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    [self.cTextView setContentOffset:CGPointZero];
    self.cTextView.frame = self.textViewFrame;
}

-(void)reconfigureTheFrameOfTextView
{
    if (self.keyboardFrame.size.height>0)
    {
        CGRect line = [self.cTextView caretRectForPosition: self.cTextView.selectedTextRange.start];
        CGRect frame =  self.cTextView.frame;
        frame.size.height = self.textViewFrame.size.height - self.coveredFrame.size.height/2 - line.size.height*2;
        [self.cTextView setFrame:frame];
        [self.cTextView scrollRangeToVisible:[self.cTextView selectedRange]];
    }
}

@end
