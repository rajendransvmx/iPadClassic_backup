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
#import "StyleManager.h"
#import "ServiceLocationModel.h"
#import "CalenderHelper.h"
#import "NonTagConstant.h"
#import "TagManager.h"
#import "SFMPageViewManager.h"
#import "SFObjectModel.h"
#import "SFObjectDAO.h"
#import "FactoryDAO.h"
#import "SMXCalendarViewController.h"
#import "SVMXSystemConstant.h"
#import "SFMPageHelper.h"
#import "SFPicklistModel.h"
#import "SMXProductListModel.h"
#import "MorePopOverViewController.h"
#import "EditMenuLabel.h"

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
#define stringLimitInProduct 80

@implementation CustomMoreButton

@synthesize headerText;
@synthesize valueText;

@end

@interface SMXEventDetailView ()
@property (nonatomic, strong) SMXEvent *event;

@property (nonatomic, strong) EditMenuLabel *labelCustomerName;
@property (nonatomic, strong) EditMenuLabel *appointmentLabel;
@property (nonatomic, strong) EditMenuLabel *labelDate;
@property (nonatomic, strong) EditMenuLabel *labelHours;

@property (nonatomic, strong) UIScrollView *cBGScrollView;


@property (nonatomic, strong) EditMenuLabel *contactTitleLabel;
@property (nonatomic, strong) EditMenuLabel *contactNameLabel;
@property (nonatomic, strong) EditMenuLabel *phoneTitleLabel;
@property (nonatomic, strong) EditMenuLabel *phoneNumberLabel;
@property (nonatomic, strong) EditMenuLabel *priorityTitleLabel;
@property (nonatomic, strong) EditMenuLabel *priorityLevelLabel;
@property (nonatomic, strong) EditMenuLabel *billingTypeTitleLabel;
@property (nonatomic, strong) EditMenuLabel *billingTypeLabel;
@property (nonatomic, strong) EditMenuLabel *serviceLocationTitleLabel;
@property (nonatomic, strong) EditMenuLabel *serviceLocationTextView;
@property (nonatomic, strong) EditMenuLabel *orderStatusTitleLabel;
@property (nonatomic, strong) EditMenuLabel *orderStatusLabel;
@property (nonatomic, strong) EditMenuLabel *purposeOfVisitTitleLabel;
@property (nonatomic, strong) EditMenuLabel *purposeOfVisitLabel;

@property (nonatomic, strong) EditMenuLabel *problemDescriptionTitleLabel;
@property (nonatomic, strong) EditMenuLabel *problemDescriptionLabel;

@property (nonatomic, strong) EditMenuLabel *productsAtThisLocationTitleLabel;
@property (nonatomic, strong) EditMenuLabel *productsAtThisLocationLabel;
@property (nonatomic, strong) CLLocationManager *cLocationManager;
@property (nonatomic, strong) CLLocation *cCurrentLocation;
@property (nonatomic, strong) NSString *cServiceLocationAddress;
@property (nonatomic, strong) ContactImageModel *cContactModel;
@property (nonatomic, strong) WorkOrderSummaryModel *cWOModel;
@property (nonatomic, strong) NSMutableDictionary *pickListData;
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
@synthesize moreButton;
@synthesize fadeOutImageView;
@synthesize popOver;

@synthesize cLocationManager;
@synthesize cCurrentLocation;
@synthesize cServiceLocationAddress;
@synthesize cContactModel;
@synthesize cWOModel;
@synthesize pickListData;

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
        //Add device orientation notification to default center.
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRotate:)
                                                    name:@"UIDeviceOrientationDidChangeNotification"
                                                  object:nil];

        event = _event;
        
        
        [self.layer setBorderColor:[UIColor lightGrayCustom].CGColor];
        [self.layer setBorderWidth:1.];
        
        [self addButtonDetailPopoverWithViewSize:frame.size];
        [self addLabelCustomerNameWithViewSize:frame.size];
        [self addLine:50];
       // [self addButtonReschedulePopoverWithViewSize:frame.size]; //HS 27Jan commented to fix issue:12843

        [self addLabelDateWithViewSize:frame.size];
        
        if (event.isWorkOrder) {
            
            
            // If Event is a work order, then display work order details in the detail event.
            
            cWOModel = [[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:event.whatId];
            
            [self getPickListLocalData];
            
            
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
            buttonDetailPopover.hidden = NO;
            [self setUpNonWorkOrderDetailsView];
        }
    }
    return self;
}


-(void)getPickListLocalData
{
    NSArray * picklistArray = [SFMPageHelper getPicklistValuesForObject:kWorkOrderTableName pickListFields:@[kWorkOrderPriority,kWorkOrderPurposeOfVisit,kWorkOrderBillingType,kWorkOrderOrderStatus]];
    
    if ([picklistArray count] > 0) {
        if (self.pickListData == nil) {
            self.pickListData = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        for (SFPicklistModel * model in picklistArray) {
            if (model != nil) {
                NSMutableDictionary *picklistDict = [self.pickListData objectForKey:model.fieldName];
                if (picklistDict == nil) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    [dict setObject:model forKey:model.value];
                    [self.pickListData setObject:dict forKey:model.fieldName];
                }
                else {
                    [picklistDict setObject:model forKey:model.value];
                }
            }
        }
    }

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
       // [self addButtonReschedulePopoverWithViewSize:size]; //27 Jan commented to fix Issue:012843
        
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

#pragma mark - Notification methods
- (void) didRotate:(NSNotification *)notification {
    
    if (self.popOver != nil && [self.popOver isPopoverVisible]) {
        [self.popOver dismissPopoverAnimated:YES];
    }
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
    cContactModel = [MapHelper getContactObjectForId: cWOModel.contactId];
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
- (void)moreButtonClicked:(id)sender
{
    if (self.popOver != nil && [self.popOver isPopoverVisible]) {
        [self.popOver dismissPopoverAnimated:YES];
    }
    CustomMoreButton *tempButton = (CustomMoreButton*)sender;
    MorePopOverViewController *morePopoverController = [[MorePopOverViewController alloc]init];
    self.popOver = [[UIPopoverController alloc] initWithContentViewController:morePopoverController];
    [self.popOver presentPopoverFromRect:tempButton.frame inView:tempButton.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    morePopoverController.fieldNameLabel.text = tempButton.headerText;
    morePopoverController.fieldValueTextView.text = tempButton.valueText;
}

#pragma mark - Add Subviews
- (void)addButtonDetailPopoverWithViewSize:(CGSize)sizeView {
    
//    CGFloat width = 130;
    CGFloat width = self.frame.size.width; //

    CGFloat height = BUTTON_HEIGHT;
    CGFloat gap = 15.0;

//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

//TODO:Working on this
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        width = self.frame.size.width - 2*gap - 5;
    }
    else{
        width = 768 - 2*gap;
    }
    
    buttonDetailPopover = [[UIButton alloc] initWithFrame:CGRectMake(gap, 5, width, height)];
    [buttonDetailPopover setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [buttonDetailPopover setTitleColor:[UIColor getUIColorFromHexValue:kOrangeColor] forState:UIControlStateNormal];
    [buttonDetailPopover setTitle:[[TagManager sharedInstance]tagByName:kTag_Open] forState:UIControlStateNormal];
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
    [buttonReschedulePopover setTitleColor:[UIColor getUIColorFromHexValue:kOrangeColor] forState:UIControlStateNormal];
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
    
    labelCustomerName = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap , 0, sizeView.width-3*gap - 150, BUTTON_HEIGHT)];
    labelCustomerName.backgroundColor = [UIColor clearColor];
    
    NSString *eventSubject = nil;
    if (event.isWorkOrder) {
        WorkOrderSummaryModel *model = [[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:event.whatId];
        
        eventSubject = (model.companyName.length ? model.companyName : (event.subject?event.subject:@""));
    }
    else{
        eventSubject = (event.subject?event.subject:@"");
        
    }

    
    [labelCustomerName setText:eventSubject];
    [labelCustomerName setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:20]];
    labelCustomerName.textColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
    [self addSubview:labelCustomerName];
    [labelCustomerName setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    


}

- (void)addLabelDateWithViewSize:(CGSize)sizeView {
    
    CGFloat gap = 15;
    
    appointmentLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap, labelCustomerName.frame.origin.y+labelCustomerName.frame.size.height + 5, 150, labelCustomerName.frame.size.height - 20 )];
    appointmentLabel.backgroundColor = [UIColor clearColor];
    appointmentLabel.text = [[TagManager sharedInstance]tagByName:kTag_appointment];
    [appointmentLabel setTextColor:LABEL_TITLE_COLOR];
    [appointmentLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [appointmentLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [self addSubview:appointmentLabel];

    
    labelDate = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap, appointmentLabel.frame.origin.y+appointmentLabel.frame.size.height -10, 500., labelCustomerName.frame.size.height - 10 )];
    labelDate.backgroundColor = [UIColor clearColor];

//    NSString *beginDate = [NSDate stringDayOfDate:event.dateTimeBegin WithTime:event.dateTimeBegin];
//    NSString *endDate = [NSDate stringDayOfDate:event.dateTimeEnd WithTime:event.dateTimeEnd];
    NSString *beginDate = [NSDate stringEventDetailDayOfDate:event.dateTimeBegin_multi];
    NSString *endDate = [NSDate stringEventDetailDayOfDate:event.dateTimeEnd_multi];
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

    contactTitleLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap, 15, 150, appointmentLabel.frame.size.height)];
    contactTitleLabel.backgroundColor = [UIColor clearColor];
    contactTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_contact];
    [contactTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [contactTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [contactTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [cBGScrollView addSubview:contactTitleLabel];

    
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:cWOModel.contactId];
    
    SFMPageViewManager *sfmViewPageManager = [[SFMPageViewManager alloc] init];
    
    BOOL isViewProcess = [sfmViewPageManager isViewProcessExistsForObject:objectModel.objectName recordId:cContactModel.contactId];
    
    if (contactNameLabel) {
        [contactNameLabel removeFromSuperview];
        contactNameLabel = nil;
    }
    
    contactNameLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap , contactTitleLabel.frame.origin.y+contactTitleLabel.frame.size.height, SMXLableWidth-50, contactTitleLabel.frame.size.height)];
    contactNameLabel.backgroundColor = [UIColor clearColor];//HS 12 Jan
    
    [contactNameLabel setText:(cContactModel.contactName.length > 0 ? cContactModel.contactName : @"--")];
    [contactNameLabel setTextColor:LABEL_VALUE_COLOR];
    [contactNameLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [contactNameLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];


    if (isViewProcess) {
        
        [contactNameLabel setTextColor:[UIColor getUIColorFromHexValue:kOrangeColor]];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openViewProcessForContact:)];
        tapGesture.numberOfTapsRequired = 1;
        contactNameLabel.userInteractionEnabled = YES;

        [contactNameLabel addGestureRecognizer:tapGesture];
        if ([self verifyStringSizeForLabel:contactNameLabel]) {
           [cBGScrollView addSubview:[self showMoreButtonForValueLabel:contactNameLabel withHeaderText:contactTitleLabel.text]];
            [self reloadContactNameLabelFrame];
        }
    }
    else
    {
        if([self verifyStringSizeForLabel:contactNameLabel]) {
            [cBGScrollView addSubview:[self showMoreButtonForValueLabel:contactNameLabel withHeaderText:contactTitleLabel.text]];
            [self reloadContactNameLabelFrame];
        }

    }
    [cBGScrollView addSubview:contactNameLabel];


}

-(void)openViewProcessForContact:(id)sender
{
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:cWOModel.contactId];
    /*Here we are removing notification "EVENT_CLICKED_WEEK"*/
    //[[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLICKED_WEEK object:event userInfo:@{@"contactID":cContactModel.localId, @"objectName":objectModel.objectName}];
    [[SMXCalendarViewController sharedInstance] eventSelectedShare:event userInfor:@{@"contactID":cContactModel.localId?cContactModel.localId:kEmptyString,
                                                                                     @"objectName":objectModel.objectName?objectModel.objectName:kEmptyString}];
}

-(void)addEmailAndChatButtons
{
    UIImage *lImage = [UIImage imageNamed:@"Email-new.png"];
    
    buttonEmail = [[UIButton alloc] initWithFrame:CGRectMake(contactNameLabel.frame.origin.x + SMXLableWidth-50 +15, contactNameLabel.frame.origin.y, 30, 20)]; //SMXLableWidth-50
    buttonEmail.tag = 77777;
    [buttonEmail setBackgroundImage:lImage forState:UIControlStateNormal];
    [buttonEmail addTarget:self action:@selector(buttonEmailAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonEmail setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    
    [cBGScrollView addSubview:buttonEmail];
    
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mailto://"]])
    {
        buttonEmail.enabled = NO;
    }
    
    lImage = [UIImage imageNamed:@"Chat-new.png"];
    
    buttonChat = [[UIButton alloc] initWithFrame:CGRectMake(buttonEmail.frame.origin.x + buttonEmail.frame.size.width +15, buttonEmail.frame.origin.y - 5, 30, 27)];
    [buttonChat setBackgroundImage:lImage forState:UIControlStateNormal];
    buttonChat.tag = 88888;
    [buttonChat addTarget:self action:@selector(buttonChatAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonChat setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    
    [cBGScrollView addSubview:buttonChat];
    
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]])
    {
        buttonChat.enabled = NO;
    }
}

-(void)buttonEmailAction:(id)sender
{
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mailto://"]])
    {
        //Just in case.
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"You currently cannot send email." delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
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
        //Just in case.
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your device does not support sending sms." delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
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
    
    phoneTitleLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap
                                                                , contactNameLabel.frame.origin.y+contactNameLabel.frame.size.height + 15, contactNameLabel.frame.size.width, contactNameLabel.frame.size.height)];
    phoneTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_phone];
    [phoneTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [phoneTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [phoneTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [cBGScrollView addSubview:phoneTitleLabel];
    

    
    phoneNumberLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap
                                                                 , phoneTitleLabel.frame.origin.y+phoneTitleLabel.frame.size.height, SMXLableWidth, phoneTitleLabel.frame.size.height)];
    [phoneNumberLabel setText:([cContactModel.phoneString length]>0 ? cContactModel.phoneString : @"--")];
    [phoneNumberLabel setTextColor:LABEL_VALUE_COLOR];
    [phoneNumberLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [phoneNumberLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:phoneNumberLabel];
    if([self verifyStringSizeForLabel:phoneNumberLabel]) {
        [cBGScrollView addSubview:[self showMoreButtonForValueLabel:phoneNumberLabel withHeaderText:phoneTitleLabel.text]];
    }
    
}

-(void)addLabelPriority
{
    CGFloat gap = 15;
    
    priorityTitleLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap
                                                                   , phoneNumberLabel.frame.origin.y+phoneNumberLabel.frame.size.height + 15, phoneNumberLabel.frame.size.width, phoneNumberLabel.frame.size.height)];
    priorityTitleLabel.backgroundColor = [UIColor clearColor];
    priorityTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_priority];
    [priorityTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [priorityTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [priorityTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [cBGScrollView addSubview:priorityTitleLabel];
    
    priorityLevelLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap
                                                                   , priorityTitleLabel.frame.origin.y+priorityTitleLabel.frame.size.height, SMXLableWidth, priorityTitleLabel.frame.size.height)];
    NSDictionary *lDict = [self.pickListData objectForKey:kWorkOrderPriority];

    SFPicklistModel *model = [lDict objectForKey:cWOModel.priorityString];
    [priorityLevelLabel setText:([model.label length] > 0 ? model.label: @"--")];
    [priorityLevelLabel setTextColor:LABEL_VALUE_COLOR];
    [priorityLevelLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [priorityLevelLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:priorityLevelLabel];
    if([self verifyStringSizeForLabel:priorityLevelLabel]) {
       [cBGScrollView addSubview:[self showMoreButtonForValueLabel:priorityLevelLabel withHeaderText:priorityTitleLabel.text]];
    }
    
}

-(void)addLabelBillingType
{
    CGFloat gap = 15;
    
    billingTypeTitleLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap
                                                                      , priorityLevelLabel.frame.origin.y+priorityLevelLabel.frame.size.height + 15, priorityLevelLabel.frame.size.width, priorityLevelLabel.frame.size.height)];
    billingTypeTitleLabel.backgroundColor = [UIColor clearColor];
    billingTypeTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_billing_type];
    [billingTypeTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [billingTypeTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [billingTypeTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

    [cBGScrollView addSubview:billingTypeTitleLabel];
    
    
    
    billingTypeLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap
                                                                 , billingTypeTitleLabel.frame.origin.y+billingTypeTitleLabel.frame.size.height, SMXLableWidth, billingTypeTitleLabel.frame.size.height)];
    
    NSDictionary *lDict = [self.pickListData objectForKey:kWorkOrderBillingType];
    
    SFPicklistModel *model = [lDict objectForKey:cWOModel.billingType];
    
    [billingTypeLabel setText:([model.label length] > 0 ? model.label: @"--")];
    [billingTypeLabel setTextColor:LABEL_VALUE_COLOR];
    [billingTypeLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [billingTypeLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:billingTypeLabel];
    if([self verifyStringSizeForLabel:billingTypeLabel]) {
        [cBGScrollView addSubview:[self showMoreButtonForValueLabel:billingTypeLabel withHeaderText:billingTypeTitleLabel.text]];
    }
}

-(void)addLabelServiceLocation
{
    
    serviceLocationTitleLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(buttonChat.frame.origin.x + buttonChat.frame.size.width +30
                                                                          , contactTitleLabel.frame.origin.y, 200, billingTypeLabel.frame.size.height)];
    serviceLocationTitleLabel.backgroundColor = [UIColor clearColor];
    serviceLocationTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_service_location];
    [serviceLocationTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [serviceLocationTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [serviceLocationTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:serviceLocationTitleLabel];
    
    
    
    serviceLocationTextView = [[EditMenuLabel alloc] initWithFrame:CGRectMake(serviceLocationTitleLabel.frame.origin.x
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
    
    orderStatusTitleLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(serviceLocationTitleLabel.frame.origin.x
                                                                      , serviceLocationTextView.frame.origin.y+serviceLocationTextView.frame.size.height + 15, serviceLocationTitleLabel.frame.size.width, serviceLocationTitleLabel.frame.size.height)];
    orderStatusTitleLabel.backgroundColor = [UIColor clearColor];
    orderStatusTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_orderstatus];
    [orderStatusTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [orderStatusTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [orderStatusTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:orderStatusTitleLabel];
    
    
    
    orderStatusLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(orderStatusTitleLabel.frame.origin.x
                                                                 , orderStatusTitleLabel.frame.origin.y+orderStatusTitleLabel.frame.size.height, SMXLableWidth, orderStatusTitleLabel.frame.size.height)];
    
    NSDictionary *lDict = [self.pickListData objectForKey:kWorkOrderOrderStatus];
    
    SFPicklistModel *model = [lDict objectForKey:cWOModel.orderStatus];

    [orderStatusLabel setText:([model.label length] > 0 ? model.label: @"--")];
    [orderStatusLabel setTextColor:LABEL_VALUE_COLOR];
    [orderStatusLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [orderStatusLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:orderStatusLabel];
    if([self verifyStringSizeForLabel:orderStatusLabel]) {
        [cBGScrollView addSubview:[self showMoreButtonForValueLabel:orderStatusLabel withHeaderText:orderStatusTitleLabel.text]];
    }
    
}

-(void)addLabelPurposeOfVisit
{
    
    purposeOfVisitTitleLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(orderStatusLabel.frame.origin.x
                                                                      , orderStatusLabel.frame.origin.y+orderStatusLabel.frame.size.height + 15, orderStatusLabel.frame.size.width, orderStatusLabel.frame.size.height)];
    purposeOfVisitTitleLabel.backgroundColor = [UIColor clearColor];
    purposeOfVisitTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_purposeofvisit];
    [purposeOfVisitTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [purposeOfVisitTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    [purposeOfVisitTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:purposeOfVisitTitleLabel];
    
    
    
    purposeOfVisitLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(purposeOfVisitTitleLabel.frame.origin.x
                                                                 , purposeOfVisitTitleLabel.frame.origin.y+purposeOfVisitTitleLabel.frame.size.height, SMXLableWidth, purposeOfVisitTitleLabel.frame.size.height)];
    
    NSDictionary *lDict = [self.pickListData objectForKey:kWorkOrderPurposeOfVisit];
    
    SFPicklistModel *model = [lDict objectForKey:cWOModel.purposeOfVisit];
    
    [purposeOfVisitLabel setText:([model.label length] > 0 ? model.label: @"--")];
    [purposeOfVisitLabel setTextColor:LABEL_VALUE_COLOR];
    [purposeOfVisitLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_VALUE_FONT_SIZE]];
    [purposeOfVisitLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [cBGScrollView addSubview:purposeOfVisitLabel];
    if([self verifyStringSizeForLabel:purposeOfVisitLabel]) {
        [cBGScrollView addSubview:[self showMoreButtonForValueLabel:purposeOfVisitLabel withHeaderText:purposeOfVisitTitleLabel.text]];
    }
    
}

-(void)addProblemDescription
{
    float gap = 15.0;
    
    float y =   ( purposeOfVisitLabel.frame.origin.y > billingTypeLabel.frame.origin.y ? purposeOfVisitLabel.frame.origin.y + purposeOfVisitLabel.frame.size.height : billingTypeLabel.frame.origin.y + billingTypeLabel.frame.size.height );
    
    problemDescriptionTitleLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(gap
                                                                         , y + 15, self.frame.size.width - 30, purposeOfVisitLabel.frame.size.height)];
    problemDescriptionTitleLabel.backgroundColor = [UIColor clearColor];
    problemDescriptionTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_problemdescription];
    [problemDescriptionTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [problemDescriptionTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    
    [cBGScrollView addSubview:problemDescriptionTitleLabel];
    
       
    problemDescriptionLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(problemDescriptionTitleLabel.frame.origin.x
                                                                    , problemDescriptionTitleLabel.frame.origin.y+problemDescriptionTitleLabel.frame.size.height, self.frame.size.width - 30, problemDescriptionTitleLabel.frame.size.height)];
    problemDescriptionLabel.backgroundColor = [UIColor clearColor];
    
    
    [problemDescriptionLabel setText:([cWOModel.problemDescription length] ? cWOModel.problemDescription : @"--")];
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
    
    productsAtThisLocationTitleLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(problemDescriptionLabel.frame.origin.x
                                                                             , problemDescriptionLabel.frame.origin.y+problemDescriptionLabel.frame.size.height + 15, self.frame.size.width - 30, problemDescriptionTitleLabel.frame.size.height)];
    productsAtThisLocationTitleLabel.backgroundColor = [UIColor clearColor];
    productsAtThisLocationTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_products_at_thislocation];
    [productsAtThisLocationTitleLabel setTextColor:LABEL_TITLE_COLOR];
    [productsAtThisLocationTitleLabel setFont:[UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:LABEL_TITLE_FONT_SIZE]];
    
    [cBGScrollView addSubview:productsAtThisLocationTitleLabel];
    
    NSArray *productLocation = [NSArray new];
    
    if ([cWOModel.IPAtLocation count] > 0)
    {
        productLocation =  cWOModel.IPAtLocation; //[self getTheModifiedProductLocationArray];
    }

    NSString *lProductsAtLocation = @"";
    for (SMXProductListModel *productModel in productLocation) {
        lProductsAtLocation = [lProductsAtLocation stringByAppendingString:[self productName_withCount:productModel]];
        lProductsAtLocation = [lProductsAtLocation stringByAppendingString:@"\n"];
    }
    
    if (![lProductsAtLocation length]) {
        lProductsAtLocation = @"--";
    }
    
//    NSString *lProductsAtLocation = @"UX9600 Laser Milling Machine\nRhino-Grip Can Opener and Food Processor\nT-850 Series 1 Terminator";
    
    /* we are giving fram for parts order*/
    productsAtThisLocationLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(productsAtThisLocationTitleLabel.frame.origin.x
                                                                        , productsAtThisLocationTitleLabel.frame.origin.y+productsAtThisLocationTitleLabel.frame.size.height,self.frame.size.width - 10, productsAtThisLocationTitleLabel.frame.size.height)];
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
-(NSString *)productName_withCount:(SMXProductListModel *)productModel{
    if (productModel.count>1) {
        return [NSString stringWithFormat:@"%@ (%d)",[self trimStringWithGivenLength:productModel.displayValue],productModel.count];
    }else{
        return [NSString stringWithFormat:@"%@",[self trimStringWithGivenLength:productModel.displayValue]];
    }
}
-(CustomMoreButton*)showMoreButtonForValueLabel:(UILabel*)label withHeaderText:(NSString*)headerString{
    CGFloat buttonWidth = 40.0;
    UIImage *fadeoutImage = [UIImage imageNamed:@"fadeout.png"];

    CGRect fadeOutImageViewFrame = CGRectMake(label.frame.size.width - fadeoutImage.size.width,0 ,fadeoutImage.size.width,fadeoutImage.size.height);

    fadeOutImageView = [[UIImageView alloc] initWithFrame:fadeOutImageViewFrame];
    fadeOutImageView.backgroundColor = [UIColor clearColor];
    fadeOutImageView.image = fadeoutImage;
    [label addSubview:fadeOutImageView];
    
    moreButton = [[CustomMoreButton alloc]initWithFrame:CGRectZero];
    moreButton.headerText = headerString;
    moreButton.valueText = label.text;
    moreButton.frame = CGRectMake(label.frame.origin.x + label.frame.size.width + 10,label.frame.origin.y - 2,buttonWidth,30);
    moreButton.backgroundColor=[UIColor clearColor];
    [moreButton setTitle:[[TagManager sharedInstance]tagByName:kTagmore] forState:UIControlStateNormal];
    [moreButton setTitle:[[TagManager sharedInstance]tagByName:kTagmore] forState:UIControlStateSelected];
    [moreButton setTitleColor:[UIColor getUIColorFromHexValue:kOrangeColor] forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor getUIColorFromHexValue:kOrangeColor] forState:UIControlStateSelected];
    moreButton.titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
    [moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return moreButton;
}

- (void) reloadContactNameLabelFrame {
    contactNameLabel.frame = CGRectMake(contactNameLabel.frame.origin.x, contactNameLabel.frame.origin.y, 170 , contactNameLabel.frame.size.height);
    fadeOutImageView.frame = CGRectMake(contactNameLabel.frame.size.width - fadeOutImageView.frame.size.width,fadeOutImageView.frame.origin.y ,fadeOutImageView.frame.size.width,fadeOutImageView.frame.size.height);
    moreButton.frame = CGRectMake(contactNameLabel.frame.origin.x + contactNameLabel.frame.size.width  + 10, moreButton.frame.origin.y, moreButton.frame.size.width, moreButton.frame.size.height);
}

- (BOOL)verifyStringSizeForLabel:(UILabel*)label {
    BOOL isTextSizeExceeded = NO;
    CGSize size = [label.text sizeWithAttributes:
                   @{NSFontAttributeName:label.font}];
    
    if (size.width > label.bounds.size.width) {
        isTextSizeExceeded = YES;
    }
    return isTextSizeExceeded;
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
    
    EditMenuLabel *lEventLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    
    lEventLabel.text = kCalDetailEvent;
    lEventLabel.font = [UIFont fontWithName:FONT_HELVETICANUE_MEDIUM size:20.0];
    lEventLabel.layer.borderColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0].CGColor;

    [lNon_WOBGView addSubview:lEventLabel];
    
    EditMenuLabel *lEventNameTitleLabel= [[EditMenuLabel alloc] initWithFrame:CGRectMake(lEventLabel.frame.origin.x, lEventLabel.frame.origin.y + lEventLabel.frame.size.height + 10, 150, 15)];
    lEventNameTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_eventName];
    lEventNameTitleLabel.font = [UIFont fontWithName:FONT_HELVETICANUE size:14.0];
    lEventNameTitleLabel.textColor = LABEL_TITLE_COLOR;
    
    [lNon_WOBGView addSubview:lEventNameTitleLabel];
    
    EditMenuLabel *lEventNameValueLabel= [[EditMenuLabel alloc] initWithFrame:CGRectMake(lEventLabel.frame.origin.x, lEventNameTitleLabel.frame.origin.y + lEventNameTitleLabel.frame.size.height, lNon_WOBGView.frame.size.width - 65, 20)];
    lEventNameValueLabel.text = (event.subject?event.subject:@"");

    lEventNameValueLabel.font = [UIFont fontWithName:FONT_HELVETICANUE size:16.0];
    lEventNameValueLabel.textColor = LABEL_VALUE_COLOR;
    [lNon_WOBGView addSubview:lEventNameValueLabel];
    if([self verifyStringSizeForLabel:lEventNameValueLabel]) {
        [lNon_WOBGView addSubview:[self showMoreButtonForValueLabel:lEventNameValueLabel withHeaderText:lEventNameTitleLabel.text]];
    }

    
    EditMenuLabel *lEventDescriptionTitleLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(lEventNameValueLabel.frame.origin.x, lEventNameValueLabel.frame.origin.y + lEventNameValueLabel.frame.size.height + 10, 150, 15)];
    lEventDescriptionTitleLabel.text = kTextDescription;
    lEventDescriptionTitleLabel.font = [UIFont fontWithName:FONT_HELVETICANUE size:14.0];
    lEventDescriptionTitleLabel.textColor = LABEL_TITLE_COLOR;
    
    [lNon_WOBGView addSubview:lEventDescriptionTitleLabel];
    
    EditMenuLabel *lEventDescriptionValueLabel = [[EditMenuLabel alloc] initWithFrame:CGRectMake(lEventDescriptionTitleLabel.frame.origin.x, lEventDescriptionTitleLabel.frame.origin.y + lEventDescriptionTitleLabel.frame.size.height, lNon_WOBGView.frame.size.width - 2*lEventDescriptionTitleLabel.frame.origin.x, 20)];
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

-(SFObjectModel *)getObjectNameForSelectedEvent:(NSString *)lContactID
{
    if ([lContactID length] != 18) {
        return nil;
    }
    
    NSString *keyPrefix = [lContactID substringToIndex:3];
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"keyPrefix" operatorType:SQLOperatorEqual andFieldValue:keyPrefix];
    
    id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    
    SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:@[@"objectName"]];
    return model;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (NSArray *)getTheModifiedProductLocationArray
{
    NSArray *unsortedArray = cWOModel.IPAtLocation;
    NSArray *sortedArray = [unsortedArray sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *comparedArray = [NSMutableArray new];
    NSMutableArray *resultArray = [NSMutableArray new];
    int count=0;
    
    for(NSString *mString in sortedArray)
    {
        //triming string with some length, so string should not go to other line
        NSString *string=[self trimStringWithGivenLength:mString];
        if(![comparedArray containsObject:string])
        {
            [comparedArray addObject:string];
            [resultArray addObject:string];
            count=0;
        }else
        {
            count++;
            if(count == 1)
            {
                [resultArray removeObject:string];
                [resultArray addObject:[NSString stringWithFormat:@"%@ (%d)",string,count+1]];
                
            }else
            {
                [resultArray removeObject:[NSString stringWithFormat:@"%@ (%d)",string,count ]];
                [resultArray addObject:[NSString stringWithFormat:@"%@ (%d)",string,count +1]];
            } 
        }
    }
        return resultArray;
}

/* just truncate with the ellipsis */
-(NSString *)trimStringWithGivenLength:(NSString *)string{
    if (string.length>stringLimitInProduct) {
        string =[NSString stringWithFormat:@"%@... ",[string substringToIndex:stringLimitInProduct]];
        return string;
    }
    return string;
}
@end
