//
//  AboutViewController.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "AboutViewController.h"

#import "CustomerOrgInfo.h"
#import "AppMetaData.h"
#import "StyleGuideConstants.h"
#import "TagManager.h"


@interface AboutViewController ()
@property (strong, nonatomic) IBOutlet UILabel *customAttributedString;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutTitle;
@end

@implementation AboutViewController

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
    //self.smSplitViewController.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]tagByName:kTagAbout]];
    [self.smPopover dismissPopoverAnimated:YES];
    self.aboutTitle.text = [[TagManager sharedInstance]tagByName:kTagAbout];
    [self updateAboutScreenData];
}

- (void)updateAboutScreenData
{
    /**
     * Get Org details from customer org info.
     */
    
    
    UIFont *fontType1 = [UIFont fontWithName:kHelveticaNeueRegular
                                        size:kFontSize18];
    UIColor *colorType2 = [UIColor colorWithRed:127.0f/255
                                          green:127.0f/255
                                           blue:127.0f/255
                                          alpha:1];
    
    UIFont *fontType2 = [UIFont fontWithName:kHelveticaNeueLight
                                        size:kFontSize18];
    UIColor *colorType1 = [UIColor colorWithRed:67.0f/255
                                          green:67.0f/255
                                           blue:67.0f/255
                                          alpha:1];
    
    NSDictionary *attrsDictionaryType1 = @{NSFontAttributeName:fontType1,
                                           NSForegroundColorAttributeName:colorType1};
    NSDictionary *attrsDictionaryType2 = @{NSFontAttributeName:fontType2,
                                          NSForegroundColorAttributeName:colorType2};
    
    NSString *signedIntoStringFromTag = [[TagManager sharedInstance]tagByName:kTagSignedinto];
    signedIntoStringFromTag = [signedIntoStringFromTag stringByAppendingString:@" "];
    NSAttributedString *attrSignedIntoString = [[NSAttributedString alloc] initWithString:signedIntoStringFromTag
                                                                               attributes:attrsDictionaryType2];

    CustomerOrgInfo *customerOrgInfo = [CustomerOrgInfo sharedInstance];
    
    NSAttributedString *attrHostString = [[NSAttributedString alloc] initWithString:customerOrgInfo.userLoggedInHost
                                                                         attributes:attrsDictionaryType1];
    
    NSString *asStringFromTag = @" ";
    asStringFromTag = [asStringFromTag stringByAppendingString:[[TagManager sharedInstance]tagByName:kTagAboutLoggedInfoAsTitle]];
    asStringFromTag = [asStringFromTag stringByAppendingString:@" "];
    NSAttributedString *attrAsString = [[NSAttributedString alloc] initWithString:asStringFromTag
                                                                       attributes:attrsDictionaryType2];
    NSAttributedString *attrUserNameString = [[NSAttributedString alloc] initWithString:customerOrgInfo.userDisplayName
                                                                             attributes:attrsDictionaryType1];
    /**
     * Finally append all the attributed string together :)
     */
    NSMutableAttributedString *finalCustomString = [[NSMutableAttributedString alloc]initWithString:@""];
    [finalCustomString appendAttributedString:attrSignedIntoString];
    [finalCustomString appendAttributedString:attrHostString];
    [finalCustomString appendAttributedString:attrAsString];
    [finalCustomString appendAttributedString:attrUserNameString];
    
    
    self.customAttributedString.attributedText = finalCustomString;
    self.userNameLabel.text = customerOrgInfo.currentUserName;
    self.customAttributedString.numberOfLines = 1;
    
    [[AppMetaData sharedInstance] loadApplicationMetaData];
    NSString *currentApplicationVersion = [[AppMetaData sharedInstance] getCurrentApplicationVersion];
    
    if (currentApplicationVersion == nil)
    {
        currentApplicationVersion = @"";
    }
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@", currentApplicationVersion];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
   
}
@end
