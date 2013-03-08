//
//  DetailViewController.m
//  SVMXiPadMobileLogger
//
//  Created by Siva Manne on 07/11/12.
//  Copyright (c) 2012 Siva Manne. All rights reserved.
//

#import "DetailViewController.h"
#import <asl.h>

#undef kEnableLogs
@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSString  *fileName;
- (void)configureView;
- (NSArray *) getLogMessage;
@end

enum logLocation
{
  FetchFromFileSystem = 0,
  FetchFromDevice = 1  
};
@implementation DetailViewController

- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    [_masterPopoverController release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}
//detailData
- (void)setDetailData:(id)newDetailData
{
    if (_detailData != newDetailData) {
        [_detailData release];
        _detailData = [newDetailData retain];
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        //self.detailDescriptionLabel.text = [self.detailItem description];
        self.detailDescriptionLabel.text = nil;
        if(_isLogFromFileSystem == FetchFromDevice)
        {
            NSArray *logData = nil;
            logData = [self getLogMessage];
            self.detailDescriptionLabel.text = [logData description];
        }
        else if(_isLogFromFileSystem == FetchFromFileSystem)
        {
            self.detailDescriptionLabel.text = self.detailData;
        }

        self.title = self.detailItem;
    }
    [self populateNavigationBarButtons];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.isLogFromFileSystem = -1;
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Device Log - (ServiceMax Inernal Usage Only)", @"Device Log- (ServiceMax Inernal Usage Only)");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
#pragma mark - Navigation Bar Buttons
- (void) populateNavigationBarButtons
{
    NSMutableArray *rightBarButtons = [[NSMutableArray alloc] init];;
    if(_isLogFromFileSystem == FetchFromFileSystem)
    {
        
        //UIImage *emailImage = [UIImage imageNamed:@"email"];
        
        //UIBarButtonItem *emailBarButton = [[UIBarButtonItem alloc] initWithImage:emailImage style:UIBarButtonItemStyleBordered target:self action:@selector(sendEmail)];
        UIBarButtonItem *emailBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonSystemItemAction target:self action:@selector(sendEmail)];
        [rightBarButtons addObject:emailBarButton];
        NSLog(@"Add Email Button to Navigation Bar Button");
    }
    else
    if(_isLogFromFileSystem == FetchFromDevice)
    {
        UIBarButtonItem *emailBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonSystemItemAction target:self action:@selector(sendEmail)];
        [rightBarButtons addObject:emailBarButton];
        [emailBarButton release];

        UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonSystemItemAction target:self action:@selector(refreshLogs)];
        [rightBarButtons addObject:refreshBarButton];
        [refreshBarButton release];

        UIBarButtonItem *saveBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonSystemItemAction target:self action:@selector(saveData)];
        [rightBarButtons addObject:saveBarButton];
        [saveBarButton release];

        UIBarButtonItem *clearBarButton = [[UIBarButtonItem alloc] initWithTitle:@"ClearLogs" style:UIBarButtonSystemItemAction target:self action:@selector(clearData)];
        [rightBarButtons addObject:clearBarButton];
        [clearBarButton release];
        
        NSLog(@"Add Refresh, Save and Email Buttons to Navigation Bar Button");
    }
    [self.navigationItem setRightBarButtonItems:rightBarButtons];
    [rightBarButtons release];
}

- (void) sendEmail
{
    _fileName = nil;
    NSLog(@"Send Email");
    [self saveData];
    NSLog(@"Send Email with Attachment = %@",_fileName);
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"ServiceMax Mobile App Log"];
        NSArray *toRecipients = [NSArray arrayWithObjects:nil];
        [mailer setToRecipients:toRecipients];
        NSString *fileData = [self.detailDescriptionLabel text];
        NSData * data = [fileData dataUsingEncoding:NSUTF8StringEncoding];
        [mailer addAttachmentData:data mimeType:@"text/rtf" fileName:_fileName];
        NSString *emailBody = @"Look into the log file and do the needful";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
        //[self presentModalViewController:mailer animated:YES];
        [mailer release];

    }
    else
    {
        NSString *message = @"Your device doesn't support the composer sheet";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}

- (void) refreshLogs
{
    NSLog(@"Refresh Log Messages");
    self.detailDescriptionLabel.text = @"";
    [self configureView];
}

- (void) saveData
{
    NSLog(@"Save Data");
    _fileName = [[NSDate date] description];
    _fileName = [_fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    _fileName = [_fileName stringByReplacingOccurrencesOfString:@"+" withString:@""];
    _fileName = [_fileName stringByAppendingString:@".txt"];
    NSLog(@"File Name to be Saved = %@",_fileName);

    NSString *fileData = [self.detailDescriptionLabel text];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];
    NSString *newFilePath = [saveDirectory stringByAppendingPathComponent:_fileName];
    
    NSData * data = [fileData dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:newFilePath atomically:YES];
}

- (void) clearData
{
    self.detailDescriptionLabel.text = @"";
}
#pragma mark - Logger
- (NSArray *) getLogMessage
{
    NSMutableArray *consoleLog = [NSMutableArray array];
    
    aslclient client = asl_open(NULL, NULL, ASL_OPT_STDERR);
    
    aslmsg query = asl_new(ASL_TYPE_QUERY);
    asl_set_query(query, ASL_KEY_MSG, NULL, ASL_QUERY_OP_NOT_EQUAL);
    asl_set_query(query, ASL_KEY_SENDER, "ServiceMax Mobile", ASL_QUERY_OP_EQUAL);
    aslresponse response = asl_search(client, query);
    //asl_free(query);
    
    aslmsg message;
    int linesToRead = 2000; // Total Number Of Lines to Read From Console
    int totalLinesCount = 0;
    while((message = aslresponse_next(response)))
    {
        const char *msg = asl_get(message, ASL_KEY_MSG);
        if(msg)
        {
            totalLinesCount++;
        }
    }
    aslresponse_free(response);
    NSLog(@"Log Count  = %d",totalLinesCount);
    response = asl_search(client, query);
    asl_free(query);
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSS"];
    while((message = aslresponse_next(response)))
    {
        const char *msg = asl_get(message, ASL_KEY_MSG);
        if(msg)
        {
            totalLinesCount--;
            if(totalLinesCount <= linesToRead)
            {
                NSDate *time = [NSDate dateWithTimeIntervalSince1970:(strtod(asl_get(message, ASL_KEY_TIME), NULL))];
                NSString *message = [NSString stringWithCString:msg encoding:NSUTF8StringEncoding];
                NSString *messageWithTime = [NSString stringWithFormat:@"[%@] %@",[dateFormatter stringFromDate:time],message];
                [consoleLog addObject:messageWithTime];
            }
        }
    }
    aslresponse_free(response);
    
    asl_close(client);
    [dateFormatter release];
#ifdef kEnableLogs
    NSLog(@"Log = %@",consoleLog);
#endif
    return consoleLog;
}
#pragma mark - Mail Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
