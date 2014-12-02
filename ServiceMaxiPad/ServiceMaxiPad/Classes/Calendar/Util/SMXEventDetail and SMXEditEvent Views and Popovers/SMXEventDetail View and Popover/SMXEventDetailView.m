//
//  SMXEventDetailView.m
/**
 *  @file   FILE_NAME.m
 *  @class  CLASS_NAME
 *
 *  @brief  This class will provide .....
 *
 *
 *
 *  @author  AUTHOR_NAME
 *
 *  @bug     No known bugs
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SMXEventDetailView.h"

#import "SMXImportantFilesForCalendar.h"
#import "SMXLable.h"
#import "StyleManager.h"
#import "ServiceLocationModel.h"
#import "CalenderHelper.h"
#import "NonTagConstant.h"
#import "TagManager.h"
#import "SFMViewPageManager.h"
#import "SFObjectModel.h"
#import "SFObjectDAO.h"
#import "FactoryDAO.h"

#define FONT_HELVETICANUE @"HelveticaNeue"

#define FONT_HELVETICANUE_MEDIUM @"HelveticaNeue-Medium"
#define FONT_HELVETICANUE_BOLD @"HelveticaNeue-Bold"
#define FONT_HELVETICANUE_LIGHT @"HelveticaNeue-Light"
#define FONT_HELVETICANUE_THIN @"HelveticaNeue-Thin"

#define LABEL_TITLE_FONT_SIZE 14
#define LABEL_VALUE_FONT_SIZE 16

#define LABEL_TITLE_COLOR [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1]
#define LABEL_VALUE_COLOR [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1]
#define SMXLableWidth 270


@interface SMXEventDetailView ()
@property (nonatomic, strong) SMXEvent *event;

@property (nonatomic, strong) UILabel *labelCustomerName;
@property (nonatomic, strong) UILabel *appointmentLabel;
@property (nonatomic, strong) UILabel *labelDate;
@property (nonatomic, strong) UILabel *labelHours;

@property (nonatomic, strong) UIScrollView *cBGScrollView;


@property (nonatomic, strong) UILabel *contactTitleLabel;
@property (nonatomic, strong) SMXLable *contactNameLabel;
@property (nonatomic, strong) UILabel *phoneTitleLabel;
@property (nonatomic, strong) SMXLable *phoneNumberLabel;
@property (nonatomic, strong) UILabel *priorityTitleLabel;
@property (nonatomic, strong) SMXLable *priorityLevelLabel;
@property (nonatomic, strong) UILabel *billingTypeTitleLabel;
@property (nonatomic, strong) SMXLable *billingTypeLabel;
@property (nonatomic, strong) UILabel *serviceLocationTitleLabel;
@property (nonatomic, strong) UILabel *serviceLocationTextView;
@property (nonatomic, strong) UILabel *orderStatusTitleLabel;
@property (nonatomic, strong) SMXLable *orderStatusLabel;
@property (nonatomic, strong) UILabel *purposeOfVisitTitleLabel;
@property (nonatomic, strong) SMXLable *purposeOfVisitLabel;

@property (nonatomic, strong) UILabel *problemDescriptionTitleLabel;
@property (nonatomic, strong) UILabel *problemDescriptionLabel;

@property (nonatomic, strong) UILabel *productsAtThisLocationTitleLabel;
@property (nonatomic, strong) UILabel *productsAtThisLocationLabel;
@property (nonatomic, strong) CLLocationManager *cLocationManager;
@property (nonatomic, strong) CLLocation *cCurrentLocation;
@property (nonatomic, strong) NSString *cServiceLocationAddress;
@property (nonatomic, strong) ContactImageModel *cContactModel;
@end

@implementation SMXEventDetailView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Synthesize


@synthesize protocol;
@synthesize event;
@synthesize buttonDetailPopover;
@synthesize buttonReschedulePopover;

@synthesize labelCustomerName;
@synthesize labelDate;
@synthesize labelHours;

@synthesize appointmentLabel;
@synthesize contactTitleLabel;
@synthesize contactNameLabel;
@synthesize phoneTitleLabel;
@synthesize phoneNumberLabel;
@synthesize priorityTitleLabel;
@synthesize priorityLevelLabel;
@synthesize billingTypeTitleLabel;
@synthesize billingTypeLabel;
@synthesize serviceLocationTitleLabel;
@synthesize serviceLocationTextView;
@synthesize orderStatusTitleLabel;
@synthesize orderStatusLabel;
@synthesize purposeOfVisitTitleLabel;
@synthesize purposeOfVisitLabel;
@synthesize cBGScrollView;

@synthesize problemDescriptionTitleLabel;
@synthesize problemDescriptionLabel;
@synthesize productsAtThisLocationTitleLabel;
@synthesize productsAtThisLocationLabel;

@synthesize buttonEmail;
@synthesize buttonChat;
@synthesize buttonMap;

@synthesize cLocationManager;
@synthesize cCurrentLocation;
@synthesize cServiceLocationAddress;
@synthesize cContactModel;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame event:(SMXEvent *)_event
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        event = _event;
        
        [self.layer setBorderColor:[UIColor lightGrayCustom].CGColor];
        [self.layer setBorderWidth:1.];
        
        [self addButtonDetailPopoverWithViewSize:frame.size];
        [self addLabelCustomerNameWithViewSize:frame.size];
        [self addLine:50];
        [self addButtonReschedulePopoverWithViewSize:frame.size];

        [self addLabelDateWithViewSize:frame.size];
        
        if (event.cWorkOrderSummaryModel) {
            
            // If Event is a work order, then display work order details in the detail event.
            
            [self CurrentLocationIdentifier]; // call this method
            [self getServiceLocation];
            [self addLine:100];
            
            [self setUpScrollView];
            
            [self getContactDetails];
            [self addLabelContactName];
            [self addEmailAndChatButtons];    // Email & Chat Button
            
            [self addLabelPhoneNumber];
            [self addLabelPriority];
            [self addLabelBillingType];
            [self addLabelServiceLocation];
            [self addMapButton];       // Map Button
            
            [self addLabelOrderStatus];
            [self addLabelPurposeOfVisit];
            
            [self addProblemDescription];
            [self addProductsAtLocation];

        }
        else{
            // if Event is a non-work order related event, then display the details of the event with different layout.
            buttonDetailPopover.hidden = YES;
            [self setUpNonWorkOrderDetailsView];
        }
    }
    return self;
}


- (id)initWithEvent:(SMXEvent *)eventInit {
    
    CGSize size = CGSizeMake(320., 70.);
    
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    if (self) {
        
        event = eventInit;
        
        [self.layer setBorderColor:[UIColor lightGrayCustom].CGColor];
        [self.layer setBorderWidth:1.];
        
        [self addButtonDetailPopoverWithViewSize:size];
        [self addLabelCustomerNameWithViewSize:size];
        [self addLine:50];
        [self addButtonReschedulePopoverWithViewSize:size];
        
        [self addLabelDateWithViewSize:size];
        [self addLine:100];
        
        [self setUpScrollView];
        //        [self addLabelHoursWithViewSize:frame.size];
        
        [self addLabelContactName];
        
        [self addLabelPhoneNumber];
        [self addLabelPriority];
        [self addLabelBillingType];
        [self addLabelServiceLocation];
        
        [self addLabelOrderStatus];
        [self addLabelPurposeOfVisit];
        
        [self addProblemDescription];
        [self addProductsAtLocation];
    }
    return self;
}

#pragma mark - Button Actions

-(void)CurrentLocationIdentifier
{
    //---- For getting current gps location
    cLocationManager = [CLLocationManager new];
    cLocationManager.delegate = self;
    cLocationManager.distanceFilter = kCLDistanceFilterNone;
    cLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [cLocationManager startUpdatingLocation];
    //------
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    cCurrentLocation = [locations objectAtIndex:0];
    [cLocationManager stopUpdatingLocation];
}

-(void)getServiceLocation
{
    ServiceLocationModel *model = [CalenderHelper getServiceLocationModel:event.whatId];
    cServiceLocationAddress = model.serviceLocation;
    
}

-(void)getContactDetails
{
    cContactModel = [MapHelper getContactObjectForId: event.cWorkOrderSummaryModel.contactId];
}

-(void) addLine: (float)y
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10.0, y, self.frame.size.width - 20, 1.0)];
    [lineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    lineView.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    [self addSubview:lineView];
}

- (IBAction)buttonEditPopoverAction:(id)sender {
    
    if ([protocol respondsToSelector:@selector(showEditViewWithEvent:)]) {
        [protocol showEditViewWithEvent:event];
    }
}

#pragma mark - Add Subviews
- (void)addButtonDetailPopoverWithViewSize:(CGSize)sizeView {
    
//    CGFloat width = 130;
    CGFloat width = self.frame.size.width; //

    CGFloat height = BUTTON_HEIGHT;
    CGFloat gap = 15;

//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

//TODO:Working on this
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        width = self.frame.size.width - 2*gap - 5;
    }
    else{
        width = 768 - 2*gap;
    }
    
    buttonDetailPopover = [[UIButton alloc] initWithFrame:CGRectMake(gap, 5, width, height)];
    [buttonDetailPopover setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [buttonDetailPopover setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateNormal];
    [buttonDetailPopover setTitle:[[TagManager sharedInstance]tagByName:kTag_Details] forState:UIControlStateNormal];
    buttonDetailPopover.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [buttonDetailPopover.titleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_LIGHT size:18.]];
    [buttonDetailPopover addTarget:self action:@selector(buttonEditPopoverAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonDetailPopover setImage:[UIImage imageNamed:@"sfm_right_arrow.png"] forState:UIControlStateNormal];
    buttonDetailPopover.titleEdgeInsets = UIEdgeInsetsMake(0, -buttonDetailPopover.imageView.frame.size.width, 0, buttonDetailPopover.imageView.frame.size.width);
    buttonDetailPopover.imageEdgeInsets = UIEdgeInsetsMake(0, buttonDetailPopover.titleLabel.frame.size.width, 0, -buttonDetailPopover.titleLabel.frame.size.width -5);
    
    [self addSubview:buttonDetailPopover];
    
}

- (void)addButtonReschedulePopoverWithViewSize:(CGSize)sizeView {
    
    CGFloat width = 150;
    CGFloat height = BUTTON_HEIGHT;
    CGFloat gap = 20;
    
    buttonReschedulePopover = [[UIButton alloc] initWithFrame:CGRectMake(sizeView.width-width - gap, 55, width, height)];
    [buttonReschedulePopover setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateNormal];
    [buttonReschedulePopover setTitle:[[TagManager sharedInstance]tagByName:kTag_Reschedule] forState:UIControlStateNormal];
    buttonReschedulePopover.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

    [buttonReschedulePopover.titleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_LIGHT size:17.]];
    [buttonReschedulePopover addTarget:self action:@selector(buttonReschedulePopoverAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonReschedulePopover setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    
     [self addSubview:buttonReschedulePopover];
    
    buttonReschedulePopover.titleEdgeInsets = UIEdgeInsetsMake(0, -buttonReschedulePopover.imageView.frame.size.width, 0, buttonReschedulePopover.imageView.frame.size.width);


}

-(void)buttonReschedulePopoverAction:(id)sender
{
    if ([protocol respondsToSelector:@selector(rescheduleEvent:)]) {
        [protocol rescheduleEvent:event];
    }
}
    
- (void)addLabelCustomerNameWithViewSize:(CGSize)sizeView {
    
    CGFloat gap = 15;
    
    labelCustomerName = [[UILabel alloc] initWithFrame:CGRectMake(gap , 0, sizeView.width-3*gap - 150, BUTTON_HEIGHT)];
    labelCustomerName.backgroundColor = [UIColor clearColor];
    [labelCustomerName setText:(event.cWorkOrderSummaryModel ? (event.cWorkOrderSummaryModel.companyName.length?event.cWorkOrderSummaryModel.companyName: event.stringCustomerName) : event.stringCustomerName)];
    [labelCustomerName setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:20]];
    labelCustomerName.textColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
    [self addSubview:labelCustomerName];
    [labelCustomerName setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    


}

- (void)addLabelDateWithViewSize:(CGSize)sizeView {
    
    CGFloat gap = 15;
    
    appointmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(gap, labelCustomerName.frame.origin.y+labelCustomerName.frame.size.height + 5, 150, labelCustomerName.frame.size.height - 20 )];
    appointmentLabel.backgroundColor = [UIColor clearColor];
    appointmentLabel.text = kMapAppointment;
    [appointmentLabel setTextColor:LABEL_TITLE_COLOR];
    [appointmentLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [appointmentLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [self addSubview:appointmentLabel];

    
    labelDate = [[UILabel alloc] initWithFrame:CGRectMake(gap, appointmentLabel.frame.origin.y+appointmentLabel.frame.size.height -10, 500., labelCustomerName.frame.size.height - 10 )];
    labelDate.backgroundColor = [UIColor clearColor];

    NSString *beginDate = [NSDate stringDayOfDate:event.ActivityDateDay WithTime:event.dateTimeBegin];
    NSString *endDate = [NSDate stringDayOfDate:event.ActivityDateDay WithTime:event.dateTimeEnd];

    [labelDate setText:[NSString stringWithFormat:@"%@ to %@", beginDate, endDate]];
    [labelDate setTextColor:LABEL_VALUE_COLOR];
    [labelDate setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [labelDate setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [self addSubview:labelDate];
    
}



/*
 18/09/2014
 
 Not used According to the re-design.
 
- (void)addLabelHoursWithViewSize:(CGSize)sizeView {
    
    CGFloat gap = 30;
    CGFloat x = labelDate.frame.origin.x + labelDate.frame.size.width+gap;
    
    labelHours = [[UILabel alloc] initWithFrame:CGRectMake(x, labelDate.frame.origin.y, sizeView.width-x-gap, labelDate.frame.size.height)];
    [labelHours setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [labelHours setText:[NSString stringWithFormat:@"%@ - %@", [NSDate stringTimeOfDate:event.dateTimeBegin], [NSDate stringTimeOfDate:event.dateTimeEnd]]];
    [labelHours setTextAlignment:NSTextAlignmentRight];
    [labelHours setTextColor:[UIColor grayColor]];
    [labelHours setFont:labelDate.font];
    
    [self addSubview:labelHours];
}

*/

-(void)setUpScrollView
{
    cBGScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, labelDate.frame.origin.y+labelDate.frame.size.height + 5, self.frame.size.width, self.frame.size.height - 105)];
    cBGScrollView.backgroundColor = [UIColor clearColor];
    cBGScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:cBGScrollView];
    
}


-(void)addLabelContactName
{
    CGFloat gap = 15;

    contactTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(gap, 15, 150, appointmentLabel.frame.size.height)];
    contactTitleLabel.backgroundColor = [UIColor clearColor];
    contactTitleLabel.text = kMapContact;
    [contactTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [contactTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [contactTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [cBGScrollView addSubview:contactTitleLabel];

    
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:event];
    
    SFMViewPageManager *sfmViewPageManager = [[SFMViewPageManager alloc] init];
    
    BOOL isViewProcess = [sfmViewPageManager isViewProcessExistsForObject:objectModel.objectName recordId:cContactModel.contactId];
    
    if (contactNameLabel) {
        [contactNameLabel removeFromSuperview];
        contactNameLabel = nil;
    }
    
    contactNameLabel = [[SMXLable alloc] initWithFrame:CGRectMake(gap , contactTitleLabel.frame.origin.y+contactTitleLabel.frame.size.height, SMXLableWidth-50, contactTitleLabel.frame.size.height)];
    [contactNameLabel setText:(cContactModel.contactName.length > 0 ? cContactModel.contactName : @"--")];
    [contactNameLabel setTextColor:LABEL_VALUE_COLOR];
    [contactNameLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [contactNameLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    contactNameLabel.headerText=contactTitleLabel.text;

    if (isViewProcess) {
        
        [contactNameLabel setTextColor:[UIColor colorWithHexString:kOrangeColor]];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openViewProcessForContact:)];
        tapGesture.numberOfTapsRequired = 1;
        contactNameLabel.userInteractionEnabled = YES;

        [contactNameLabel addGestureRecognizer:tapGesture];
    }
    else
    {
        [contactNameLabel checkString];

    }
    
    [cBGScrollView addSubview:contactNameLabel];

}

-(void)openViewProcessForContact:(id)sender
{
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:event];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLICKED_WEEK object:event userInfo:@{@"contactID":cContactModel.localId, @"objectName":objectModel.objectName}];

}

-(void)addEmailAndChatButtons
{
    UIImage *lImage = [UIImage imageNamed:@"iOS-Email-Retina-Orange.png"];
    
    buttonEmail = [[UIButton alloc] initWithFrame:CGRectMake(contactNameLabel.frame.origin.x + contactNameLabel.frame.size.width +10, contactNameLabel.frame.origin.y, lImage.size.width, lImage.size.height)];
    buttonEmail.tag = 77777;
    [buttonEmail setBackgroundImage:lImage forState:UIControlStateNormal];
    [buttonEmail addTarget:self action:@selector(buttonEmailAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonEmail setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    
    [cBGScrollView addSubview:buttonEmail];
    
    lImage = [UIImage imageNamed:@"iOSChat-Retina-Orange.png"];
    
    buttonChat = [[UIButton alloc] initWithFrame:CGRectMake(buttonEmail.frame.origin.x + buttonEmail.frame.size.width +35, buttonEmail.frame.origin.y, lImage.size.width, lImage.size.height)];
    [buttonChat setBackgroundImage:lImage forState:UIControlStateNormal];
    buttonChat.tag = 88888;
    [buttonChat addTarget:self action:@selector(buttonChatAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonChat setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    
    [cBGScrollView addSubview:buttonChat];
}

-(void)buttonEmailAction:(id)sender
{

    
    
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mailto://"]])
    {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Warning!!!" message:@"You currently cannot send email." delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
        [lAlert show];
        lAlert = nil;
    }
    else
    {
        [self sendEmailORSMS:sender];
    }

    
}

-(void)buttonChatAction:(id)sender
{

    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]])
    {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Warning!!!" message:@"Your device does not support sending sms." delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
        [lAlert show];
        lAlert = nil;
    }
    else
    {
        [self sendEmailORSMS:sender];
    }
    
}

-(void)sendEmailORSMS:(id)sender
{
    if ([sender tag] == 88888) {
        NSString *contactNumber  = cContactModel.mobilePhoneString;
        NSString *cleanedtelStr = [[contactNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
        
        NSString *chatStr = [NSString stringWithFormat:@"sms://%@",cleanedtelStr];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:chatStr]];
    }
    else {
        NSString *mail  = cContactModel.emailString;
        NSString *mailStr = [NSString stringWithFormat:@"mailto:%@",mail];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailStr]];
        
    }
}

-(void)addLabelPhoneNumber
{
    CGFloat gap = 15;
    
    phoneTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(gap
                                                                , contactNameLabel.frame.origin.y+contactNameLabel.frame.size.height + 15, contactNameLabel.frame.size.width, contactNameLabel.frame.size.height)];
    phoneTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_phone];
    [phoneTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [phoneTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [phoneTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [cBGScrollView addSubview:phoneTitleLabel];
    

    
    phoneNumberLabel = [[SMXLable alloc] initWithFrame:CGRectMake(gap
                                                                 , phoneTitleLabel.frame.origin.y+phoneTitleLabel.frame.size.height, SMXLableWidth, phoneTitleLabel.frame.size.height)];
    [phoneNumberLabel setText:([cContactModel.phoneString length]>0 ? cContactModel.phoneString : @"--")];
    [phoneNumberLabel setTextColor:LABEL_VALUE_COLOR];
    [phoneNumberLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [phoneNumberLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:phoneNumberLabel];
    phoneNumberLabel.headerText=phoneTitleLabel.text;
    [phoneNumberLabel checkString];
    
}

-(void)addLabelPriority
{
    CGFloat gap = 15;
    
    priorityTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(gap
                                                                   , phoneNumberLabel.frame.origin.y+phoneNumberLabel.frame.size.height + 15, phoneNumberLabel.frame.size.width, phoneNumberLabel.frame.size.height)];
    priorityTitleLabel.backgroundColor = [UIColor clearColor];
    priorityTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_priority];
    [priorityTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [priorityTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [priorityTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [cBGScrollView addSubview:priorityTitleLabel];
    
    priorityLevelLabel = [[SMXLable alloc] initWithFrame:CGRectMake(gap
                                                                   , priorityTitleLabel.frame.origin.y+priorityTitleLabel.frame.size.height, SMXLableWidth, priorityTitleLabel.frame.size.height)];
    
    [priorityLevelLabel setText:event.cWorkOrderSummaryModel.priorityString];
    [priorityLevelLabel setTextColor:LABEL_VALUE_COLOR];
    [priorityLevelLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [priorityLevelLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:priorityLevelLabel];
    priorityLevelLabel.headerText=priorityTitleLabel.text;
    [priorityLevelLabel checkString];
    
}

-(void)addLabelBillingType
{
    CGFloat gap = 15;
    
    billingTypeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(gap
                                                                      , priorityLevelLabel.frame.origin.y+priorityLevelLabel.frame.size.height + 15, priorityLevelLabel.frame.size.width, priorityLevelLabel.frame.size.height)];
    billingTypeTitleLabel.backgroundColor = [UIColor clearColor];
    billingTypeTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_billing_type];
    [billingTypeTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [billingTypeTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [billingTypeTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [cBGScrollView addSubview:billingTypeTitleLabel];
    
    
    
    billingTypeLabel = [[SMXLable alloc] initWithFrame:CGRectMake(gap
                                                                 , billingTypeTitleLabel.frame.origin.y+billingTypeTitleLabel.frame.size.height, SMXLableWidth, billingTypeTitleLabel.frame.size.height)];
    [billingTypeLabel setText:([event.cWorkOrderSummaryModel.billingType length] > 0 ? event.cWorkOrderSummaryModel.billingType: @"--")];
    [billingTypeLabel setTextColor:LABEL_VALUE_COLOR];
    [billingTypeLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [billingTypeLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:billingTypeLabel];
    billingTypeLabel.headerText=billingTypeTitleLabel.text;
    [billingTypeLabel checkString];
}

-(void)addLabelServiceLocation
{
    
    serviceLocationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonChat.frame.origin.x + buttonChat.frame.size.width +30
                                                                          , contactTitleLabel.frame.origin.y, 200, billingTypeLabel.frame.size.height)];
    serviceLocationTitleLabel.backgroundColor = [UIColor clearColor];
    serviceLocationTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_service_location];
    [serviceLocationTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [serviceLocationTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [serviceLocationTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:serviceLocationTitleLabel];
    
    
    
    serviceLocationTextView = [[UILabel alloc] initWithFrame:CGRectMake(serviceLocationTitleLabel.frame.origin.x
                                                                           , serviceLocationTitleLabel.frame.origin.y+serviceLocationTitleLabel.frame.size.height, serviceLocationTitleLabel.frame.size.width, serviceLocationTitleLabel.frame.size.height*4)];
    serviceLocationTextView.numberOfLines = 0;
    serviceLocationTextView.text = cServiceLocationAddress;

    CGSize lServiceLocationSize = [self dynamicHeightOfLabel:serviceLocationTextView withWidth:serviceLocationTitleLabel.frame.size.width];

    CGRect frame = serviceLocationTextView.frame;
    frame.size = lServiceLocationSize;
    serviceLocationTextView.frame = frame;
    
    [serviceLocationTextView setTextColor:LABEL_VALUE_COLOR];
    [serviceLocationTextView setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    serviceLocationTextView.backgroundColor = [UIColor clearColor];
    serviceLocationTextView.textAlignment = NSTextAlignmentLeft;
    [serviceLocationTextView sizeToFit];
    [serviceLocationTextView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [cBGScrollView addSubview:serviceLocationTextView];

}

-(void)addMapButton
{
    UIImage *lImage = [UIImage imageNamed:@"iOSMap-Retina-Orange.png"];
    
//    buttonMap = [[UIButton alloc] initWithFrame:CGRectMake(serviceLocationTextView.frame.size.width + serviceLocationTextView.frame.origin.x + 130, serviceLocationTextView.frame.origin.y , lImage.size.width, lImage.size.height)];
    
    buttonMap = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width  - 2 * lImage.size.width, serviceLocationTextView.frame.origin.y , lImage.size.width, lImage.size.height)];

    [buttonMap setBackgroundImage:lImage forState:UIControlStateNormal];
    [buttonMap addTarget:self action:@selector(buttonMapAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMap setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [cBGScrollView addSubview:buttonMap];
}


-(void)buttonMapAction:(id)sender
{
//    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Warning!!!" message:@"Implemention pending" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    
//    [lAlert show];
//    lAlert = nil;
    
    //TODO: PASS ADDRESS.
    
    NSString *lServiceLocationDestinationAddress = [NSString stringWithFormat:@"%@", cServiceLocationAddress];
    
    cServiceLocationAddress = [cServiceLocationAddress stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    cServiceLocationAddress = [cServiceLocationAddress stringByReplacingOccurrencesOfString:@"++" withString:@"+"];

    NSString *path = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@&saddr=%lf,%lf", lServiceLocationDestinationAddress, cCurrentLocation.coordinate.latitude, cCurrentLocation.coordinate.longitude];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
    
    /*
     
     
    {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(<#CLLocationDegrees latitude#>, <#CLLocationDegrees longitude#>)
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:self.serviceLocationModel.serviceLocation];
        
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }
     
     */
    
}


-(void)addLabelOrderStatus
{
    
    orderStatusTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(serviceLocationTitleLabel.frame.origin.x
                                                                      , serviceLocationTextView.frame.origin.y+serviceLocationTextView.frame.size.height + 15, serviceLocationTitleLabel.frame.size.width, serviceLocationTitleLabel.frame.size.height)];
    orderStatusTitleLabel.backgroundColor = [UIColor clearColor];
    orderStatusTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_orderstatus];
    [orderStatusTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [orderStatusTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [orderStatusTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:orderStatusTitleLabel];
    
    
    
    orderStatusLabel = [[SMXLable alloc] initWithFrame:CGRectMake(orderStatusTitleLabel.frame.origin.x
                                                                 , orderStatusTitleLabel.frame.origin.y+orderStatusTitleLabel.frame.size.height, SMXLableWidth, orderStatusTitleLabel.frame.size.height)];
    [orderStatusLabel setText:([event.cWorkOrderSummaryModel.orderStatus length] > 0 ? event.cWorkOrderSummaryModel.orderStatus: @"--")];
    [orderStatusLabel setTextColor:LABEL_VALUE_COLOR];
    [orderStatusLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [orderStatusLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:orderStatusLabel];
    orderStatusLabel.headerText=orderStatusTitleLabel.text;
    [orderStatusLabel checkString];
    
}

-(void)addLabelPurposeOfVisit
{
    
    purposeOfVisitTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(orderStatusLabel.frame.origin.x
                                                                      , orderStatusLabel.frame.origin.y+orderStatusLabel.frame.size.height + 15, orderStatusLabel.frame.size.width, orderStatusLabel.frame.size.height)];
    purposeOfVisitTitleLabel.backgroundColor = [UIColor clearColor];
    purposeOfVisitTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_purposeofvisit];
    [purposeOfVisitTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [purposeOfVisitTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [purposeOfVisitTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:purposeOfVisitTitleLabel];
    
    
    
    purposeOfVisitLabel = [[SMXLable alloc] initWithFrame:CGRectMake(purposeOfVisitTitleLabel.frame.origin.x
                                                                 , purposeOfVisitTitleLabel.frame.origin.y+purposeOfVisitTitleLabel.frame.size.height, SMXLableWidth, purposeOfVisitTitleLabel.frame.size.height)];    
    [purposeOfVisitLabel setText:([event.cWorkOrderSummaryModel.purposeOfVisit length] > 0 ? event.cWorkOrderSummaryModel.purposeOfVisit: @"--")];
    [purposeOfVisitLabel setTextColor:LABEL_VALUE_COLOR];
    [purposeOfVisitLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [purposeOfVisitLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:purposeOfVisitLabel];
    purposeOfVisitLabel.headerText=purposeOfVisitTitleLabel.text;
    [purposeOfVisitLabel checkString];
    
}

-(void)addProblemDescription
{
    float gap = 15.0;
    
    float y =   ( purposeOfVisitLabel.frame.origin.y > billingTypeLabel.frame.origin.y ? purposeOfVisitLabel.frame.origin.y + purposeOfVisitLabel.frame.size.height : billingTypeLabel.frame.origin.y + billingTypeLabel.frame.size.height );
    
    problemDescriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(gap
                                                                         , y + 15, self.frame.size.width - 30, purposeOfVisitLabel.frame.size.height)];
    problemDescriptionTitleLabel.backgroundColor = [UIColor clearColor];
    problemDescriptionTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_problemdescription];
    [problemDescriptionTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [problemDescriptionTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    
    [cBGScrollView addSubview:problemDescriptionTitleLabel];
    
       
    problemDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(problemDescriptionTitleLabel.frame.origin.x
                                                                    , problemDescriptionTitleLabel.frame.origin.y+problemDescriptionTitleLabel.frame.size.height, self.frame.size.width - 30, problemDescriptionTitleLabel.frame.size.height)];
    problemDescriptionLabel.backgroundColor = [UIColor clearColor];
    
    
    [problemDescriptionLabel setText:([event.cWorkOrderSummaryModel.problemDescription length] ? event.cWorkOrderSummaryModel.problemDescription : @"--")];
    problemDescriptionLabel.numberOfLines = 0;

    [problemDescriptionLabel setTextColor:LABEL_VALUE_COLOR];
    [problemDescriptionLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    problemDescriptionLabel.textAlignment = NSTextAlignmentJustified;
    [problemDescriptionLabel sizeToFit];

    [problemDescriptionLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    [cBGScrollView addSubview:problemDescriptionLabel];
    
}

-(void)addProductsAtLocation
{
    
    
    productsAtThisLocationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(problemDescriptionLabel.frame.origin.x
                                                                             , problemDescriptionLabel.frame.origin.y+problemDescriptionLabel.frame.size.height + 15, self.frame.size.width - 30, problemDescriptionTitleLabel.frame.size.height)];
    productsAtThisLocationTitleLabel.backgroundColor = [UIColor clearColor];
    productsAtThisLocationTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_products_at_thislocation];
    [productsAtThisLocationTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [productsAtThisLocationTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    
    [cBGScrollView addSubview:productsAtThisLocationTitleLabel];
    
    
    NSString *lProductsAtLocation = @"";
    for (NSString *lString in event.cWorkOrderSummaryModel.IPAtLocation) {
        lProductsAtLocation = [lProductsAtLocation stringByAppendingString:lString];
        lProductsAtLocation = [lProductsAtLocation stringByAppendingString:@"\n"];
    }
    
    if (![lProductsAtLocation length]) {
        lProductsAtLocation = @"--";
    }
    
//    NSString *lProductsAtLocation = @"UX9600 Laser Milling Machine\nRhino-Grip Can Opener and Food Processor\nT-850 Series 1 Terminator";
    
    
    productsAtThisLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(productsAtThisLocationTitleLabel.frame.origin.x
                                                                        , productsAtThisLocationTitleLabel.frame.origin.y+productsAtThisLocationTitleLabel.frame.size.height, self.frame.size.width - 30, productsAtThisLocationTitleLabel.frame.size.height)];
    productsAtThisLocationLabel.backgroundColor = [UIColor clearColor];
    [productsAtThisLocationLabel setText:lProductsAtLocation];
    productsAtThisLocationLabel.numberOfLines = 0;
    
    [productsAtThisLocationLabel setTextColor:LABEL_VALUE_COLOR];
    [productsAtThisLocationLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    
    [productsAtThisLocationLabel sizeToFit];

    /*
   CGSize theSize = [self dynamicHeightOfLabel:productsAtThisLocationLabel];
    
    CGRect newFrame = productsAtThisLocationLabel.frame;
    newFrame.size.height = theSize.height;
    productsAtThisLocationLabel.frame = newFrame;
    */
    
    [cBGScrollView addSubview:productsAtThisLocationLabel];
    
    [cBGScrollView setContentSize:CGSizeMake(cBGScrollView.frame.size.width, productsAtThisLocationLabel.frame.origin.y + productsAtThisLocationLabel.frame.size.height)];
}

#pragma mark NON-WORK ORDER EVENT

-(void)setUpNonWorkOrderDetailsView
{
    UIView *lNon_WOBGView = [[UIView alloc] initWithFrame:CGRectMake(10, labelDate.frame.origin.y + labelDate.frame.size.height +10, self.frame.size.width - 20, 150)];

    lNon_WOBGView.layer.borderColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0].CGColor;
    lNon_WOBGView.layer.borderWidth = 1.0;
    lNon_WOBGView.layer.cornerRadius = 5.0;
    lNon_WOBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth; // In Portrait mode the view was becoming small. This resolves the issue.
    [self addSubview:lNon_WOBGView];
    
    UILabel *lEventLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    
    lEventLabel.text = kCalDetailEvent;
    lEventLabel.font = [UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:20.0];
    lEventLabel.layer.borderColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0].CGColor;

    [lNon_WOBGView addSubview:lEventLabel];
    
    UILabel *lEventNameTitleLabel= [[UILabel alloc] initWithFrame:CGRectMake(lEventLabel.frame.origin.x, lEventLabel.frame.origin.y + lEventLabel.frame.size.height + 10, 150, 15)];
    lEventNameTitleLabel.text = kCalDetailEventName;
    lEventNameTitleLabel.font = [UIFont fontWithName:FONT_HELVETICANUE size:14.0];
    lEventNameTitleLabel.textColor = LABEL_TITLE_COLOR;
    
    [lNon_WOBGView addSubview:lEventNameTitleLabel];
    
    SMXLable *lEventNameValueLabel= [[SMXLable alloc] initWithFrame:CGRectMake(lEventLabel.frame.origin.x, lEventNameTitleLabel.frame.origin.y + lEventNameTitleLabel.frame.size.height, lNon_WOBGView.frame.size.width - 20, 20)];
    lEventNameValueLabel.text = event.stringCustomerName;

    lEventNameValueLabel.font = [UIFont fontWithName:FONT_HELVETICANUE size:16.0];
    lEventNameValueLabel.textColor = LABEL_VALUE_COLOR;
    [lNon_WOBGView addSubview:lEventNameValueLabel];
    [lEventNameValueLabel checkString];

    
    UILabel *lEventDescriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(lEventNameValueLabel.frame.origin.x, lEventNameValueLabel.frame.origin.y + lEventNameValueLabel.frame.size.height + 10, 150, 15)];
    lEventDescriptionTitleLabel.text = kTextDescription;
    lEventDescriptionTitleLabel.font = [UIFont fontWithName:FONT_HELVETICANUE size:14.0];
    lEventDescriptionTitleLabel.textColor = LABEL_TITLE_COLOR;
    
    [lNon_WOBGView addSubview:lEventDescriptionTitleLabel];
    
    UILabel *lEventDescriptionValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(lEventDescriptionTitleLabel.frame.origin.x, lEventDescriptionTitleLabel.frame.origin.y + lEventDescriptionTitleLabel.frame.size.height, lNon_WOBGView.frame.size.width - 2*lEventDescriptionTitleLabel.frame.origin.x, 20)];
    lEventDescriptionValueLabel.numberOfLines = 0;
    lEventDescriptionValueLabel.lineBreakMode = NSLineBreakByWordWrapping;

    
    NSString *lDescription = event.description;

    if (lDescription.length ==0) {
        lDescription = @"--";
    }
    lEventDescriptionValueLabel.text = lDescription;
    
    CGSize lDescriptionSize = [self dynamicHeightOfLabel:lEventDescriptionValueLabel withWidth:lEventDescriptionValueLabel.frame.size.width];
    if (lDescriptionSize.height<25) {
        lDescriptionSize.height = 20;
    }
    
    CGRect lframe = [lEventDescriptionValueLabel frame];
    lframe.size.height = (lDescriptionSize.height == 20 ? lDescriptionSize.height :  lDescriptionSize.height);
    lEventDescriptionValueLabel.frame = lframe;
    
    lEventDescriptionValueLabel.text = lDescription;
    lEventDescriptionValueLabel.font = [UIFont fontWithName:FONT_HELVETICANUE size:16.0];
    lEventDescriptionValueLabel.textColor = LABEL_VALUE_COLOR;
    [lNon_WOBGView addSubview:lEventDescriptionValueLabel];
    
    
    if ((lEventDescriptionValueLabel.frame.origin.y + lEventDescriptionValueLabel.frame.size.height) > lNon_WOBGView.frame.size.height - 10) {
        
        lframe = lNon_WOBGView.frame;
        lframe.size.height = lEventDescriptionValueLabel.frame.origin.y + lEventDescriptionValueLabel.frame.size.height + 10;
        
        lNon_WOBGView.frame = lframe;
    }

}

-(CGSize )dynamicHeightOfLabel:(UILabel *)label withWidth:(float)width
{
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGRect expectedLabelRect = [label.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@
                                {NSFontAttributeName: label.font} context:nil];

    return expectedLabelRect.size;

}

-(SFObjectModel *)getObjectNameForSelectedEvent:(SMXEvent *)levent
{
    if ([levent.cWorkOrderSummaryModel.contactId length] != 18) {
        return nil;
    }
    
    NSString *keyPrefix = [levent.cWorkOrderSummaryModel.contactId substringToIndex:3];
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"keyPrefix" operatorType:SQLOperatorEqual andFieldValue:keyPrefix];
    
    id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    
    SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:@[@"objectName"]];
    return model;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
