//
//  DocumentViewController.m
//  ServiceMaxMobile
//
//  Created by Kirti on 07/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "DocumentViewController.h"
#import "AttachmentUtility.h"
#import "Globals.h"
#import "Utility.h"

/*Accessibility Changes*/
#import "AccessibilityAttachmentConstants.h"

#define CHECK_IMAGE                             @"iOS-Check-Filled.png"
#define UNCHECK_IMAGE                           @"iOS-Check-Empty.png"
#define ISOPDOC                                 @"isOpdoc"
#define CELL_DOWNLOAD_ALPHA                     0.2

@interface DocumentViewController ()

//11429
@property (retain, nonatomic) IBOutlet UILabel *selectItemsCount;
@property (retain, nonatomic)IBOutlet UILabel *itemLabel;

@end

@implementation DocumentViewController

@synthesize mainTableView;
@synthesize isInEditMode;
@synthesize documentsArray;
@synthesize selectedIdDictionary;
@synthesize isViewProcess;
@synthesize editButton;
@synthesize cancelButton;
@synthesize delegate;
@synthesize tapToDownloadString;
@synthesize titleLabel;

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInternetConnectionChanged object:nil];
    [self removeDataSyncObserver];
    [mainTableView release];
    [selectedIdDictionary release];
    [editButton release];
    [cancelButton release];
    delegate = nil;
    [tapToDownloadString release];
    [titleLabel release];
    [_share dealloc];
    [_deleteButton dealloc];
    [_sharingAttachmentList release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
         [self addAttachmentDownloadObserver];
        [self addDataSyncObserver];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Accessibility Changes*/
    if (self.isViewProcess)
    {
        [self setAccessibilityIdentifierForInstanceVariable:NO];
    }
    else
    {
        [self setAccessibilityIdentifierForInstanceVariable:YES];
    }
    
    if ([self.documentsArray count] <= 0) {
           [self loadDocuments];
        
    }

    [self.cancelButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE] forState:UIControlStateNormal];
    [self.editButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EDIT_LIST] forState:UIControlStateNormal];
    self.editButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    self.editButton.highlighted = NO;
    [self.editButton setTitleColor:[appDelegate colorForHex:@"157DFB"] forState:UIControlStateNormal];
    //TAP_TO_DOWNLOAD
    self.tapToDownloadString = [appDelegate.wsInterface.tagsDictionary objectForKey:TAP_TO_DOWNLOAD];
 
    CGRect viewFrame = self.mainTableView.frame;
    viewFrame.size.height = self.view.frame.size.height - 150;
    self.mainTableView.frame = viewFrame;
    
    if ([self.documentsArray count]<=0) {
        self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    self.titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:TAG_DOCUMENTS];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [appDelegate colorForHex:@"2d5d83"];// [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];

    self.isInEditMode = NO;
    // Do any additional setup after loading the view from its nib.
    
  //  [self.editButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];//009101
    self.editButton.enabled = YES;
  
    //D-00003728
    NSString *deleteButtonLabel = [appDelegate.wsInterface.tagsDictionary objectForKey:DELETE_BUTTON_TITLE];
    [self.deleteButton setTitle:deleteButtonLabel forState:UIControlStateNormal];
    self.deleteButton.titleLabel.hidden = YES;
    [self clearSelectedData]; //Defect 11352
    [self hideEditbuttons:YES];
    //011411
    [self handleEditButtonDisplay];
    [self handleCancelButtonDisplay];
  
}

/*Accessibility Changes*/
- (void) setAccessibilityIdentifierForInstanceVariable:(BOOL)element
{
    if (!element)
    {
        [editButton setAccessibilityIdentifier:nil];
        [cancelButton setAccessibilityIdentifier:nil];
    }
    else
    {        
        cancelButton.isAccessibilityElement = element;
        [cancelButton setAccessibilityIdentifier:kAccCancelAttachment];
        
        editButton.isAccessibilityElement = YES;
        [editButton setAccessibilityIdentifier:kAccEditAttachment];
    }
    
}


- (void)viewDidAppear:(BOOL)animated {
    [self handleEditButtonDisplay];
    [self handleCancelButtonDisplay];
    //Defect 11352
    self.isInEditMode = NO;
    self.editButton.enabled = YES;
    self.deleteButton.titleLabel.hidden = YES;
    [self hideEditbuttons:YES];
    [self clearSelectedData];
    [self hideSelectItemLabel:YES]; //11429
    if ([self.documentsArray count] > 0) {
        [self.mainTableView reloadData];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Data Loading Methods

- (void)loadDocuments {
    
    @synchronized(self){
    NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
    NSMutableArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:DOCUMENT_DICT dictionaryType:OBJECT_LIST];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:itemsArray];
    self.documentsArray = tempArray;
    [tempArray release];
    tempArray = nil;
    
    [self loadProgressbars];
    [self loadOutputDocuments];
    [aPool drain];
    aPool = nil;
        
    }
}

- (void)loadOutputDocuments {
    NSArray *documents =  [appDelegate.databaseInterface getAllOPDocsHtmlFiles];
    NSMutableArray *opDocs = [[NSMutableArray alloc] init];
    if ([documents count] > 0) {
        for (int counter = [documents count] - 1; counter >= 0; counter--) {
            
            NSDictionary *someDictionary = [documents objectAtIndex:counter];
            NSString *name = [someDictionary objectForKey:@"doc_name"];
            if (name != nil) {
                NSMutableDictionary *docDictionary = [[NSMutableDictionary alloc] init];
                NSString *lastMd =  [self getDateFromOpDocName:name];
                if (lastMd != nil) {
                    [docDictionary setObject:lastMd forKey:K_LASTMODIFIEDDATE];
                }
                [docDictionary setObject:name forKey:@"Name"];
                [docDictionary setObject:@"html" forKey:@"Type"];
                [docDictionary setObject:@"true" forKey:@"isOpdoc"];
                [opDocs addObject:docDictionary];
                [docDictionary release];
                docDictionary = nil;
            }
        }
    }
    
    
    
    [opDocs addObjectsFromArray:self.documentsArray];
    
    self.documentsArray = opDocs;
    [opDocs release];
    opDocs = nil;
}
- (void)sortDocuments:(NSMutableArray *)opDocArray {
    
    
}

- (UIImage *) imageForDocument:(NSDictionary *)documentDict andStatus:(ATTACHMENT_STATUS)status
{
    UIImage *image = nil;
    ATTACHMENT_STATUS cellType = status;//[AttachmentUtility getAttachmentStaus:documentDict];
    
    if ([documentDict valueForKey:ISOPDOC])
    {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[AttachmentUtility getFileType:[documentDict valueForKey:K_TYPE]]]];

    }
    else if (cellType == ATTACHMENT_STATUS_EXISTS)
    {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[AttachmentUtility getFileType:[documentDict valueForKey:K_TYPE]]]];
    }
    else if (cellType == ATTACHMENT_STATUS_YET_TO_DOWNLOAD || cellType == ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS || cellType == ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE)
    {
        
        if ([appDelegate isInternetConnectionAvailable]) {
            image = [UIImage imageNamed:[NSString stringWithFormat:@"onlineTapToDownload.png"]];
        }
        else{
            image = [UIImage imageNamed:[NSString stringWithFormat:@"offlineTapToDownload.png"]];
        }
        
    }
    else if (cellType == ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD)
    {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"errorInDownloadSmaller.png"]];//9212
    }
    return image;
    
}


- (void)loadProgressbars {
    for (int counter = 0;counter < [self.documentsArray count] ; counter++) {
        NSDictionary *documentDict = [self.documentsArray objectAtIndex:counter];
        NSString *attachmmentId = [documentDict objectForKey:K_ATTACHMENT_ID];
        if (attachmmentId != nil) {
            ATTACHMENT_STATUS attachmentStatus = [AttachmentUtility getAttachmentStaus:documentDict];
            if (attachmentStatus == ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS || attachmentStatus == ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE) {
                UIProgressView *progressView = [self.attachmentProgressBarsDictionary objectForKey:attachmmentId];
                if (progressView == nil) {
                    UIProgressView *progressView = [self createProgressBar];
                    [self addProgressBar:progressView ForId:attachmmentId];
                }
            }
            else{
                UIProgressView *progressView = [self.attachmentProgressBarsDictionary objectForKey:attachmmentId];
                if (progressView != nil) {
                    [self removeProgressbarForId:attachmmentId];
                }
            }
        }
    }
}
#pragma mark -
#pragma mark Table view delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [documentsArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"identifier";
    DocumentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[DocumentViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        //D-00003728
        /*Romove sub view added to the cell*/
        [self removeTransperentSubviewFromCell:cell];
          /*Remove progress view and text cell*/
        [self removeProgressViewsIfAnyFromCell:cell];
        cell.imageTitleLabel.text = nil;
    }
    
  
    
    NSDictionary *documentDict = [documentsArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = [[documentDict valueForKey:K_NAME]stringByDeletingPathExtension];
    
    NSString *lastModifiedDate = [documentDict valueForKey:K_LASTMODIFIEDDATE];
    if (lastModifiedDate != nil) {
        cell.subTitleLabel.text = [AttachmentUtility getDate:lastModifiedDate withFormat:ATTACHMENT_DATE_FORMAT];

    }
    
    
    NSString *docSize = [documentDict valueForKey:K_SIZE];
    if (docSize != nil)
    {
        cell.leftLabel.text = [Utility formattedFileSizeForAttachment:[docSize longLongValue]];//9196
        //[NSString stringWithFormat:@"%@MB",[self getFormattedSize:docSize]];
    }
    else
    {
        cell.leftLabel.text = @"";

    }
    
    ATTACHMENT_STATUS docStatus = [AttachmentUtility getAttachmentStaus:documentDict];
    cell.cellTypeImageView.image = [self imageForDocument:documentDict andStatus:docStatus];
    if (docStatus != ATTACHMENT_STATUS_EXISTS  && docStatus != ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD) {  //9212
        cell.imageTitleLabel.text = self.tapToDownloadString;
    }
    cell.cellTypeImageView.alpha = 1.0;
    if (self.isInEditMode) {
        
        NSString *isOpDoc = [documentDict objectForKey:ISOPDOC];
        if ([isOpDoc isEqualToString:@"true"]) {
            cell.editIconImageView.hidden = YES;
        }
        else{
            if (docStatus != ATTACHMENT_STATUS_EXISTS)  {
                 cell.editIconImageView.hidden = YES;
                [self hideAttachemtForCell:cell]; //D-00003728
            }
            else{
                NSString *attachmentid = [documentDict objectForKey:K_ATTACHMENT_ID];
                if ([self.selectedIdDictionary objectForKey:attachmentid] != nil) {
                    cell.editIconImageView.image = [UIImage imageNamed:CHECK_IMAGE];
                    cell.editIconImageView.hidden = NO;
                }
                //D-00003728
                else if ([self.sharingAttachmentList objectForKey:attachmentid] != nil) {
                    cell.editIconImageView.image = [UIImage imageNamed:CHECK_IMAGE];
                    cell.editIconImageView.hidden = NO;
                }
                else{
                    cell.editIconImageView.image = [UIImage imageNamed:UNCHECK_IMAGE];
                    cell.editIconImageView.hidden = NO;
                    [self updateItemLabelText:[appDelegate.wsInterface.tagsDictionary objectForKey:SELECTITEMS]]; //11429
                }
            }
        }
    }
    else {
        cell.editIconImageView.hidden = YES;
    }
    [self handleProgressbarForCell:cell withAttachment:documentDict andStatus:docStatus];
     [self handleErrorForCell:cell withAttachment:documentDict andStatus:docStatus];//9212
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isViewProcess) {
        return NO;
    }
    else{
        if ([self.documentsArray count] > indexPath.row) {
            NSDictionary *documentDict = [documentsArray objectAtIndex:indexPath.row];
            NSString *isOpDoc = [documentDict objectForKey:ISOPDOC];
            if ([isOpDoc isEqualToString:@"true"]) {
                return NO;
            }
            else{
                ATTACHMENT_STATUS docStatus = [AttachmentUtility getAttachmentStaus:documentDict];
               if (docStatus != ATTACHMENT_STATUS_EXISTS) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
            NSDictionary *selectedDictionary = [documentsArray objectAtIndex:indexPath.row];
                    NSString *attachmentId = [selectedDictionary objectForKey:K_ATTACHMENT_ID];
                    if (attachmentId.length > 0) {
                        
                    if ([selectedIdDictionary objectForKey:attachmentId] != nil) {
                        [self.selectedIdDictionary removeObjectForKey:attachmentId];
                    }
                    else {
                        
                        if (selectedIdDictionary == nil) {
                            NSMutableDictionary *tempDictionary  = [[NSMutableDictionary alloc] init];
                            self.selectedIdDictionary  = tempDictionary;
                            [tempDictionary release];
                            tempDictionary = nil;
                        }
                        [self.selectedIdDictionary setObject:attachmentId forKey:attachmentId];
                    }
            }
        [AttachmentUtility conformationforDelete:self];

    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 94.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.documentsArray count] > indexPath.row) {
        if(!isInEditMode)
        {
            NSDictionary *documentDict = [self.documentsArray objectAtIndex:indexPath.row];
            NSString * attachmentId = [documentDict objectForKey:K_ATTACHMENT_ID];
            NSString * fileName = [documentDict objectForKey:K_NAME];
            BOOL isOPDoc = [[documentDict objectForKey:ISOPDOC]boolValue];
            ATTACHMENT_STATUS attachmentStatus = [AttachmentUtility getAttachmentStaus:documentDict];
            if (isOPDoc)
            {
                //Load the OP doc from different Path
                [self.delegate displayAttachment:attachmentId fielName:fileName category:DOCUMENT_CATEGORY];

            }
            else if(attachmentStatus ==  ATTACHMENT_STATUS_EXISTS)
            {
                if ([self.delegate respondsToSelector:@selector(displayAttachment:fielName:category:)])
                {
                    [self.delegate displayAttachment:attachmentId fielName:fileName category:DOCUMENT_CATEGORY];
                }
            }
            else if(attachmentStatus ==  ATTACHMENT_STATUS_YET_TO_DOWNLOAD)//9212 & 9216
            {
                //start download the document
                [self  downloadAttachment:documentDict];
                DocumentViewCell *cellView = (DocumentViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                [self handleProgressbarForCell:cellView withAttachment:documentDict andStatus:ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS];
             }
            else if (attachmentStatus ==  ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS || attachmentStatus ==  ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE){
                //Download is in que. Cannot take any action as of now
                self.selectAttachmentForCancel = documentDict;
                NSString *confirmationMessage = @"Are you sure you want to cancel the download?";
                //Download is in que.
                [self showAlertForCancelConfirmationAlert:fileName andMessage:confirmationMessage];
            }

            
        }
        else
        {
            NSDictionary *selectedDictionary = [documentsArray objectAtIndex:indexPath.row];
            NSString * fileName = [selectedDictionary objectForKey:K_NAME]; //D-00003728
            if (self.isInEditMode) {
                DocumentViewCell *cellView = (DocumentViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                
                NSString *attachmentId = [selectedDictionary objectForKey:K_ATTACHMENT_ID];
                ATTACHMENT_STATUS attachmentStatus = [AttachmentUtility getAttachmentStaus:selectedDictionary];
                if (attachmentStatus != ATTACHMENT_STATUS_EXISTS) {
                    return;
                }

                if (attachmentId.length > 0) {
                    
                    if ([selectedIdDictionary objectForKey:attachmentId] != nil) {
                        [self.selectedIdDictionary removeObjectForKey:attachmentId];
                        cellView.editIconImageView.image = [UIImage imageNamed:UNCHECK_IMAGE];
//                        cellView.editIconImageView.hidden = YES; //D-00003728
                    }
                    else {
                        
                        if (selectedIdDictionary == nil) {
                            NSMutableDictionary *tempDictionary  = [[NSMutableDictionary alloc] init];
                            self.selectedIdDictionary  = tempDictionary;
                            [tempDictionary release];
                            tempDictionary = nil;
                        }
                        [self.selectedIdDictionary setObject:attachmentId forKey:attachmentId];
                        cellView.editIconImageView.image = [UIImage imageNamed:CHECK_IMAGE];
                        cellView.editIconImageView.hidden = NO;
                        [self enableEditButtons:YES];
                    }
                    if ([self.sharingAttachmentList objectForKey:attachmentId] != nil) {
                        [self.sharingAttachmentList removeObjectForKey:attachmentId];
                    }
                    //D-00003728
                    else {
                        
                        if (self.sharingAttachmentList == nil) {
                            NSMutableDictionary *tempDictionary  = [[NSMutableDictionary alloc] init];
                            self.sharingAttachmentList  = tempDictionary;
                            [tempDictionary release];
                            tempDictionary = nil;
                        }
                        if (fileName != nil && [fileName length] > 0)
                        {
                           [self.sharingAttachmentList setObject:fileName forKey:attachmentId]; //Defect 11338
                           [self enableEditButtons:YES];
                        }
                    }
                }
                
                //009101  //D-00003728
                if ([selectedIdDictionary count] > 0 || [self.sharingAttachmentList count] > 0) {
                    [self setShareImage:@"iOS-Share-Blue.png"];
                     [self setDeleteImage:@"iOS-Trash-Can-Blue.png"];
                    self.editButton.enabled = YES;
                    [self enableEditButtons:YES];
                    [self updateItemLabelText:[appDelegate.wsInterface.tagsDictionary objectForKey:ITEMSELECTED]]; //11429
                    [self updateSelectItemCount:[self.selectedIdDictionary count]];
                }
                else{
                    [self setShareImage:@"iOS-Share-Gray.png"];
                    [self setDeleteImage:@"iOS-Trash-Can-Gray.png"];
                    self.editButton.enabled = NO;
                    [self enableEditButtons:NO]; //D-00003728
                    [self updateEmptyTextToSelectItemCount]; //11429
                    [self updateItemLabelText:[appDelegate.wsInterface.tagsDictionary objectForKey:SELECTITEMS]];
                    
                }
            }
            
        }
        
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark -
#pragma mark Edit/Delete detail button action

- (void) handleCancelButtonDisplay
{
    if (isInEditMode && !isViewProcess)
    {
        self.cancelButton.hidden = NO;
    }
    else
    {
        self.cancelButton.hidden = YES;
    }
}

- (void) handleEditButtonDisplay
{
    //D-00003728
    if ([self.documentsArray count]<=0) {
        
        editButton.hidden = YES;
        [self hideEditbuttons:YES];
    }
    else
    {
        editButton.hidden = NO;
        [self hideEditbuttons:YES];
    }
}


- (IBAction)updateDocumentList:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    NSString *buttonTitle = button.titleLabel.text;
    NSString *editButtonLabel = [appDelegate.wsInterface.tagsDictionary objectForKey:EDIT_LIST];

    NSString *deleteButtonLabel = [appDelegate.wsInterface.tagsDictionary objectForKey:DELETE_BUTTON_TITLE];//9211
    if([buttonTitle isEqualToString:editButtonLabel])
    {
        self.isInEditMode = YES;
        [self setShareImage:@"iOS-Share-Gray.png"];
        [self setDeleteImage:@"iOS-Trash-Can-Gray.png"];
//        [button setTitle:deleteButtonLabel forState:UIControlStateNormal];
        //        self.cancelButton.hidden = NO;
        [self.mainTableView reloadData];
        button.enabled = NO;//009101
        /*Accessibilty Changes*/
        button.isAccessibilityElement = YES;
        [button setAccessibilityIdentifier:kAccDeleteAttachment];
        [self hideSelectItemLabel:NO]; //11429
        [self updateEmptyTextToSelectItemCount];
        if (isViewProcess) //D-00003728
        {
            [self enableViewEditButtons:YES];
            self.cancelButton.hidden = NO;
            self.cancelButton.enabled = YES;
        }
        else
        {
            [self hideEditbuttons:NO];
            [self enableEditButtons:NO];
            [self hideSelectButton:YES];
            [self handleCancelButtonDisplay];
        }
        
    }
    else if ([buttonTitle isEqualToString:deleteButtonLabel])
    {
        button.enabled = YES;//009101
        self.isInEditMode = NO;
        [self hideSelectButton:NO]; //D-00003728
        
        [self hideEditbuttons:YES];
        [self enableEditButtons:YES];

//        [button setTitle:editButtonLabel forState:UIControlStateNormal];
        //        self.cancelButton.hidden = YES;
        
        if ( [self.selectedIdDictionary count] > 0) {
            [AttachmentUtility conformationforDelete:self];
            
        }
        else{
            [self.mainTableView reloadData];
        }
        [self handleCancelButtonDisplay];
    }
    
}

//D-00003728
#pragma mark - Attachemnt Sharing
- (IBAction)shareAttachment:(id)sender
{
    self.isInEditMode = NO;
    [self hideSelectButton:NO];
    
    [self hideEditbuttons:YES];
    [self enableEditButtons:YES];
    
    [self handleCancelButtonDisplay];
    
    if ([self.sharingAttachmentList count] > 0)
    {
        //Defect 11338
        [self createDuplicateAttachmentFile:self.sharingAttachmentList];
        NSArray * urls = [[self getAttachemntUrlsForSharing:[self.sharingAttachmentList allValues]] retain];
        if ([self.delegate respondsToSelector:@selector(displayAttachment:fielName:category:)])
        {
            [self.delegate displayAttachmentSharingView:urls viewName:DOCUMENTVIEW];
        }
        [urls release];
    }
    
    [self.selectedIdDictionary removeAllObjects];

}

//D-00003728
-(void)hideEditbuttons:(BOOL)hide
{
    self.share.hidden = hide;
    self.deleteButton.hidden = hide;
}

-(void)hideSelectButton:(BOOL)hide
{
    self.editButton.hidden = hide;
}


-(void)enableEditButtons:(BOOL)enable
{
//    self.share.enabled = enable;
//    self.deleteButton.enabled = enable;
    self.share.userInteractionEnabled = enable;
    self.deleteButton.userInteractionEnabled = enable;
}

#pragma mark - Attachment sharing
//D-00003728
- (void)hideAttachemtForCell:(DocumentViewCell *)cellView
{
    CGPoint viewOrigin = cellView.bounds.origin;
    CGSize viewSize = cellView.bounds.size;
    
    if (viewSize.width < 680 || viewSize.height < 94)
    {
        viewSize.height = 94;
        viewSize.width = 680;
    }

    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(viewOrigin.x+15, viewOrigin.x, viewSize.width, viewSize.height)];
    view.backgroundColor = [appDelegate colorForHex:@"A1A1A1"];
    view.alpha = 0.5;
    [cellView  addSubview:view];
    view.tag = 9999;
    [cellView.contentView addSubview:view];
    [cellView  bringSubviewToFront:view];
    [view release];
}

-(void)removeTransperentSubviewFromCell:(DocumentViewCell *)cell
{
    if(cell != nil)
    {
        NSArray *subViews = [cell.contentView subviews];
        for(UIView *subView in subViews)
        {
            if (subView.tag == 9999)
            {
                [subView removeFromSuperview];
            }
        }
    }
}

-(void)enableViewEditButtons:(BOOL)enable
{
    self.share.hidden = !enable;
//    self.share.enabled = !enable;
    self.share.userInteractionEnabled = !enable;
    self.deleteButton.hidden = enable;
    self.editButton.hidden = enable;
}

//D-00003728
- (void)setShareImage:(NSString *)imageName
{
    [self.share setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)setDeleteImage:(NSString *)imageName
{
    [self.deleteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

//Defect 11352
- (void)clearSelectedData
{
    if((self.selectedIdDictionary != nil) && ([self.selectedIdDictionary count] > 0))
    {
        [self.selectedIdDictionary removeAllObjects];
    }
  
    //D-00003728
    if ((self.sharingAttachmentList != nil) && ([self.sharingAttachmentList count] > 0))
    {
        [self.sharingAttachmentList removeAllObjects];
    }
}

//Defect 11338
- (void)deleteAttachmetFiles
{
    if ([self.sharingAttachmentList count] > 0)
    {
        SMLog(kLogLevelVerbose,@"Documents Slected to share = %@", [self.sharingAttachmentList allValues]);
        NSArray * array = [self.sharingAttachmentList allValues];
        [self deleteDuplicateAttachmentsCreated:array];
    }
    [self.sharingAttachmentList removeAllObjects];
}
//11429
- (void)hideSelectItemLabel:(BOOL)hide
{
    self.selectItemsCount.hidden = hide;
    self.itemLabel.hidden = hide;
}

- (void)updateSelectItemCount:(NSInteger)count
{
    self.selectItemsCount.text = [NSString stringWithFormat:@"%d", count];
    if (count > 1)
    {
        [self updateItemLabelText:[appDelegate.wsInterface.tagsDictionary objectForKey:ITEMSSELECTED]];
    }
}

- (void)updateEmptyTextToSelectItemCount
{
    self.selectItemsCount.text = @"";
}

- (void)hideSelectItemCount
{
    self.selectItemsCount.text = @"";
    self.selectItemsCount.hidden = YES;
}

- (void)updateItemLabelText:(NSString *)text
{
    if (![text isEqualToString:self.itemLabel.text])
    {
        self.itemLabel.text = text;
    }
}

- (void)refreshSelectitems
{
    [self updateEmptyTextToSelectItemCount];
    [self updateItemLabelText:@""];
}


#pragma mark -END

#pragma mark -
#pragma mark Show alert view delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == DOWNLOAD_CANCEL_ALERT) {
        if(buttonIndex == 0){
            [self  cancelDownloadForAttachment:self.selectAttachmentForCancel];
        }
        self.selectAttachmentForCancel = nil;
    }
    else {
        
        
        // Vipin - 009088
        if(buttonIndex == 1)
        {   // Delete Records from Server
            [self deleteTheSelectedIds];
            [self handleEditButtonDisplay];
             [self refreshSelectitems]; //11429
        }
   /*     else if(buttonIndex == 2)
        {
            NSArray *allDeletedIds = [self.selectedIdDictionary allKeys];
            [AttachmentUtility removeSelectedAttachmentFiles:allDeletedIds];
            
            [self handleEditButtonDisplay];
            [self.selectedIdDictionary removeAllObjects];
            [self.sharingAttachmentList removeAllObjects];
            [self.mainTableView reloadData];
        }*/
        else //Handling Cancel funtionality
        {
            [self hideSelectButton:YES];
            [self hideEditbuttons:NO];
            self.isInEditMode = YES;
            self.cancelButton.hidden = NO;
        }
    }
}

#pragma mark Deleting selected ids
- (void)deleteTheSelectedIds {
    
    NSArray *allDeletedIds = [self.selectedIdDictionary allKeys];
    [AttachmentUtility deleteIdsFromAttachmentlist:allDeletedIds forType:DOCUMENT_DICT];
    
    [self removeDeletedIdsFromArray];
    
    /*Remove from the array*/
    [self.selectedIdDictionary removeAllObjects];
    [self.sharingAttachmentList removeAllObjects];
    
    if ([self.documentsArray count]<=0) {
        self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    }

    [self.mainTableView reloadData];
    
}

-(void)removeDeletedIdsFromArray {
    
    NSMutableArray *tempArray = [self.documentsArray mutableCopy];
    for (NSDictionary *attachmentDict in self.documentsArray)
    {
        NSString *attachmentId = [attachmentDict objectForKey:K_ATTACHMENT_ID];
        if (attachmentId.length > 0) {
            if ([selectedIdDictionary objectForKey:attachmentId] != nil) {
                [tempArray removeObject:attachmentDict];
            }
        }
    }
    self.documentsArray = tempArray;
    [tempArray release];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    NSString *editButtonLabel = [appDelegate.wsInterface.tagsDictionary objectForKey:EDIT_LIST];
    self.isInEditMode = NO;
    [self handleCancelButtonDisplay];
    [self.selectedIdDictionary removeAllObjects];
    [self.sharingAttachmentList removeAllObjects];
    [self.mainTableView reloadData];
    [self.editButton setTitle:editButtonLabel forState:UIControlStateNormal];
    self.editButton.enabled = YES;//009101
    [self hideEditbuttons:YES];
    [self hideSelectButton:NO];
    [self refreshSelectitems]; //11429

}

- (void) refreshDocuments
{
    @synchronized(self)
    {
        [self loadDocuments];
        [self.mainTableView reloadData];
    }
}

- (void) deleteAttachment:(NSString *)localId
{
//    [updateTrailerTableWithDeletedIds:(NSArray*)deletedIds

}


#pragma mark -
#pragma mark Internet Connectivity Handler

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    [self.mainTableView reloadData];
}


#pragma mark -
#pragma mark Data sync notification handler

- (void)handleIncrementalDataSyncNotification:(NSNotification *)notification{
    
    [self refreshDocuments];
};



#pragma mark- Handle progress bar
- (void)handleProgressbarForCell:(DocumentViewCell *)cellView withAttachment:(NSDictionary *)documentDict andStatus:(ATTACHMENT_STATUS)status{
    if (status == ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS || status == ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE) {
        NSString * attachmentId = [documentDict objectForKey:K_ATTACHMENT_ID];
        UIProgressView *pgView = [self.attachmentProgressBarsDictionary objectForKey:attachmentId];
        if (pgView != nil) {
            [pgView removeFromSuperview];
            [cellView.contentView addSubview:pgView];
            cellView.cellTypeImageView.alpha = CELL_DOWNLOAD_ALPHA;
            [cellView.contentView bringSubviewToFront:pgView];
            cellView.progessLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:DOWNLOADING];;
            cellView.progessLabel.textColor = [UIColor blueColor];//9212
            
        }
    }
}

- (void)removeProgressViewsIfAnyFromCell:(DocumentViewCell *)cellView {
    
    NSArray *subviews = [cellView.contentView subviews];
    for (int counter = 0; counter < [subviews count]; counter++) {
        UIView *aPgView = [subviews objectAtIndex:counter];
        if ([aPgView isKindOfClass:[UIProgressView class]]) {
            [aPgView removeFromSuperview];
        }
    }
    cellView.progessLabel.text = nil;
     cellView.progessLabel.textColor = [UIColor blueColor];//9212
}

- (NSString *)getFormattedSize:(NSString *)sizeString {
    
    NSString *finalString = sizeString;
    NSArray *subStrings = [sizeString componentsSeparatedByString:@"."];
    if ([subStrings count] > 1) {
        NSString *firstString = [subStrings objectAtIndex:0];
        NSString *secondString = [subStrings objectAtIndex:1];
        if ([secondString length] > 2) {
            secondString = [secondString substringToIndex:2];
        }
        if (![Utility isStringEmpty:secondString]) {
            finalString = [NSString stringWithFormat:@"%@.%@",firstString,secondString];
        }
    }
    return finalString;
}

- (NSString *)getDateFromOpDocName:(NSString *)name {
    NSString *result = nil;
    name = [name stringByDeletingPathExtension];
    NSArray *components =  [name componentsSeparatedByString:@"_"];
    if ([components count] > 2 ){
        NSString *timeComp = [components objectAtIndex:[components count] - 1];
        timeComp = [timeComp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([timeComp length] == 14) {
            
            NSString *year = [timeComp substringToIndex:4];
            
            NSRange someRange =  NSMakeRange(4, 2);
            NSString *month = [timeComp substringWithRange:someRange];
            
            someRange =  NSMakeRange(6, 2);
            NSString *day = [timeComp substringWithRange:someRange];
            
            someRange =  NSMakeRange(8, 2);
            NSString *hour = [timeComp substringWithRange:someRange];
            
            someRange =  NSMakeRange(10, 2);
            NSString *min = [timeComp substringWithRange:someRange];
            
            someRange =  NSMakeRange(12, 2);
            NSString *sec = [timeComp substringWithRange:someRange];
            result = [NSString stringWithFormat:@"%@-%@-%@T%@:%@:%@.000+0000",year,month,day,hour,min,sec];
            
            
        }
    }
    return result;
}

#pragma mark - Attachment Downlaod status hanlders - overidden methods
- (void)downloadCompleteForId:(NSString *)attachmentId {
    [super downloadCompleteForId:attachmentId];
    [self removeProgressbarForId:attachmentId];
    [AttachmentUtility deleteFromAttachmentTrailerForDownload:attachmentId];
    [self reloadTableViewData];
    
    //9182
    //Commenting below lines of code as per 9182. User will explicitely tap to open the attachment
    //009077
    //If multiple documets are tapped to download, then the last downloaded document will be presented to the user
//    if(self.view.window && (attachmentProgressBarsDictionary !=nil) && ([attachmentProgressBarsDictionary count]== 0))
//    {
//        NSString *fileName = nil;
//        for (NSDictionary *docDict in self.documentsArray) {
//            if ([docDict valueForKey:K_ATTACHMENT_ID] == attachmentId)
//            {
//                fileName = [docDict valueForKey:K_NAME];
//                break;
//            }
//        }
//        [self.delegate displayAttachment:attachmentId fielName:fileName category:DOCUMENT_CATEGORY];
//    }

}

- (void)downloadFailedForId:(NSString *)attachmentId withError:(NSError *)error {
   [self removeProgressbarForId:attachmentId];
    [super downloadFailedForId:attachmentId withError:error];
   [AttachmentUtility deleteFromAttachmentTrailerForDownload:attachmentId];
    [self reloadTableViewData];
}

#pragma mark -reload table view
- (void)reloadTableViewData {
    [self.mainTableView reloadData];
}
- (void)reloadViewData {
    [self reloadTableViewData];
}
#pragma mark- 9212
-(void)handleErrorForCell:(DocumentViewCell *)cell
           withAttachment:(NSDictionary *)documentDict
                andStatus:(ATTACHMENT_STATUS)status {
    if (status == ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD) {
        NSString *attachmentId = [documentDict objectForKey:K_ATTACHMENT_ID];
        SMAttachmentRequestErrorCode errorCode = (SMAttachmentRequestErrorCode)[appDelegate.attachmentDataBase getErrorCodeForAttachmentId:attachmentId];
        NSString *message = [AttachmentUtility getAttachmentAPIErrorMessage:errorCode];
        cell.progessLabel.text = message;
        cell.progessLabel.textColor  = [UIColor redColor];
        //Get the text and set the color to red or else blue
    }
}
@end
