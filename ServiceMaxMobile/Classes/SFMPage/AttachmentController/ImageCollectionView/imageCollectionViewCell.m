//
//  imageCollectionViewCell.m
//  ServiceMaxMobile
//
//  Created by Sahana on 07/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "imageCollectionViewCell.h"
#import "AttachmentUtility.h"
@implementation imageCollectionViewCell
@synthesize imageCellType, backgroundImage, pieChart, lastModifiedDate, fileName, fileSize, localId, vedioImage,errorMsg,downloadMsg ;
@synthesize fileType , DocumentName, Attachmentsf_id;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)fillCollectionviewcell:(IMAGE_CELL_TYPE)cellType
{
    self.imageCellType = cellType;
    [self addImageView];
    switch (cellType)
    {
        case IMAGE_EXISTS:
        {
            [self addLabel:LAST_MOD_DATE];
            if( [[AttachmentUtility getFileType:[DocumentName pathExtension]] isEqualToString:VEDIO]){
            [self addLabel:VEDIO_IMG];
            }

        }
        break;
        case DOWNLOAD_IMAGE:
        {
            [self addLabel:DOWNLOADMSG];
            [self addLabel:ATTACHMENT_FILE_NAME];
            [self addLabel:FILE_SIZE];
        }
        break;
        case DOWNLOAD_INQUEUE:
        {
            [self addLabel:DOWNLOADMSG];
            [self addLabel:ATTACHMENT_FILE_NAME];
            [self addLabel:FILE_SIZE];
        }
        break;
        case ERROR_IN_DOWNLOAD:
        {
            [self addLabel:FILE_ERROR_MSG];
            [self addLabel:ATTACHMENT_FILE_NAME];
            [self addLabel:FILE_SIZE];
            
        }
        break;
        default:
            break;
    }
    
}

-(CGRect)getrectFor:(NSString *)type
{
    CGRect rect;
    if([type isEqualToString:FILE_ERROR_MSG])
    {
        rect = CGRectMake(0, 82, self.frame.size.width, 83);
    }
    else if([type isEqualToString:ATTACHMENT_FILE_NAME])
    {
        rect = CGRectMake(0, 165, self.frame.size.width, 20);
    }
    else if([type isEqualToString:FILE_SIZE])
    {
        rect = CGRectMake(0, 184, self.frame.size.width, 20);
    }
    else if([type isEqualToString:DOWNLOADMSG])
    {
        rect = CGRectMake(0, 142, self.frame.size.width, 28);
    }
    else if([type isEqualToString:LAST_MOD_DATE])
    {
        rect = CGRectMake(0, 178, self.frame.size.width, 25);
    }
    else if([type isEqualToString:VEDIO_IMG])
    {
        rect = CGRectMake(0, 145,52, 30);
    }
    else if([type isEqualToString:CLOUD_IMG])
    {
        rect = CGRectMake(180, 178,40, 24);
    }
    else if ([type isEqualToString:DATE_DOWNLOADED])
    {
        rect = CGRectMake(4, 178, self.frame.size.width, 25);
    }
    return rect;
}

-(void)addLabel:(NSString *)type
{
    if([type isEqualToString:FILE_ERROR_MSG])
    {
        self.errorMsg = [[UILabel alloc] initWithFrame:[self getrectFor:FILE_ERROR_MSG]];
        self.errorMsg.alpha = 1.0;
        self.errorMsg.backgroundColor = [UIColor clearColor];
        [self addSubview:errorMsg];
        self.errorMsg.textColor  = [UIColor whiteColor];
        errorMsg.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        errorMsg.numberOfLines = 0;
        errorMsg.textAlignment = NSTextAlignmentCenter;//9212
    }
    else if([type isEqualToString:ATTACHMENT_FILE_NAME])
    {
        self.fileName = [[UILabel alloc] initWithFrame:[self getrectFor:ATTACHMENT_FILE_NAME]];
        self.fileName.textColor = [UIColor whiteColor];
        self.fileName.backgroundColor = [UIColor clearColor];
        self.fileName.textAlignment = NSTextAlignmentCenter;
        [self addSubview:fileName];
    }
    else if([type isEqualToString:FILE_SIZE])
    {
        UIView * BackgroudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
        BackgroudView.frame = [self getrectFor:FILE_SIZE];
        [self addSubview:BackgroudView];
        [BackgroudView release];
        
        self.fileSize = [[UILabel alloc] initWithFrame:[self getrectFor:FILE_SIZE]];
        self.fileSize.textColor = [UIColor blackColor];
        self.fileSize.backgroundColor = [UIColor clearColor];
        self.fileSize.textAlignment = NSTextAlignmentCenter;
        [self addSubview:fileSize];
    }
    else if([type isEqualToString:DOWNLOADMSG])
    {
        self.downloadMsg = [[UILabel alloc] initWithFrame:[self getrectFor:DOWNLOADMSG]];
        //downloadMsg.backgroundColor=[UIColor redColor];
        self.downloadMsg.backgroundColor = [UIColor clearColor];
        self.downloadMsg.text = [appDelegate.wsInterface.tagsDictionary objectForKey:TAP_TO_DOWNLOAD];
;
        self.downloadMsg.textColor = [UIColor whiteColor];
        self.downloadMsg.textAlignment = NSTextAlignmentCenter;
        [self addSubview:downloadMsg];
    }
    else if([type isEqualToString:LAST_MOD_DATE])
    {
        UIView * BackgroudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
        BackgroudView.frame = [self getrectFor:LAST_MOD_DATE];
        [self addSubview:BackgroudView];
        [BackgroudView release];
        if([Attachmentsf_id length] > 0)
        {
            //add cloud image
            UIView * cloudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud.png"]];
            cloudView.frame = [self getrectFor:CLOUD_IMG];
            [self addSubview:cloudView];
            [cloudView release];
        }
        self.lastModifiedDate = [[UILabel alloc] initWithFrame:[self getrectFor:DATE_DOWNLOADED]];
        self.lastModifiedDate.backgroundColor = [UIColor clearColor];
        [self addSubview:lastModifiedDate];
    }
    else if([type isEqualToString:VEDIO_IMG])
    {
        self.vedioImage = [[UIImageView alloc] initWithFrame:[self getrectFor:VEDIO_IMG]];
        self.vedioImage.image  = [UIImage imageNamed:@"video.png"];
        [self addSubview:vedioImage];
    }
}
-(void)addImageView
{
    CGRect ImageFrame = CGRectMake(0, 0, 225, 203);
    
    self.backgroundImage = [[UIImageView alloc] initWithFrame:ImageFrame];
    // for showing thumbnail
 
    if(self.imageCellType == IMAGE_EXISTS)
    {
        NSString * imagePath = [AttachmentUtility getFullPath:DocumentName];
        
        if([[AttachmentUtility getFileType:[DocumentName pathExtension]] isEqualToString:VEDIO])
        {
            UIImage *img = [AttachmentUtility getThumbnailImageForFile:imagePath];
            self.backgroundImage.image=img;
        }
        else
        {
            UIImage *img=[AttachmentUtility scaleImage:imagePath toSize:CGSizeMake(200, 200)];
            self.backgroundImage.image = img;//[UIImage imageWithContentsOfFile:imagePath];
            
        }
    }
    else if(self.imageCellType == DOWNLOAD_IMAGE)
    {
        if([appDelegate isInternetConnectionAvailable])
        {
            self.backgroundImage.image = [UIImage imageNamed:@"onlineTapToDownload.png"];
        }
        else
        {
            self.backgroundImage.image = [UIImage imageNamed:@"offlineTapToDownload.png"];
        }
    }
    else if(self.imageCellType == DOWNLOAD_INQUEUE)
    {
         self.backgroundImage.image = [UIImage imageNamed:@"onlineTapToDownload.png"];
    }
    else if(self.imageCellType == ERROR_IN_DOWNLOAD)
    {
         self.backgroundImage.image = [UIImage imageNamed:@"errorInDownload.png"];
    }
   // self.backgroundColor = [UIColor blueColor];

    [self addSubview:backgroundImage];    
}

-(void)highlightcellForDeletion
{
    UIImage * selectionImage = [UIImage imageNamed:@"iOS-Check-Filled.png"];
    CGRect rect =  CGRectMake(0, 0, 48, 48);;
    UIImageView * selectionImg = [[UIImageView alloc]initWithImage:selectionImage];
    selectionImg.frame = rect;
    selectionImg.tag = 9999;
    [self addSubview:selectionImg];
    [selectionImg release];
}
-(void)UnhighlightcellFromDeletion
{
    NSArray * subviews = [self subviews];
    for (UIView * view in subviews) {
        if(view.tag ==  8888){
            return;
        }
    }
    UIImage * selectionImage = [UIImage imageNamed:@"iOS-Check-Empty.png"];
    CGRect rect =  CGRectMake(0, 0, 48, 48);;
    UIImageView * selectionImg = [[UIImageView alloc]initWithImage:selectionImage];
    selectionImg.frame = rect;
    selectionImg.tag = 8888;
    [self addSubview:selectionImg];
    [selectionImg release];
}

-(BOOL)select
{
    NSArray * cellSubviews = [self subviews];
    BOOL deleted= FALSE;
    for(UIView * cellSubView in cellSubviews)
    {
        if(cellSubView.tag == 9999)
        {
            deleted = TRUE;
            [cellSubView removeFromSuperview];
        }
    }
    
    if(!deleted)
    {
        [self highlightcellForDeletion];
    }
    
    return !deleted;
}

-(void) dealloc
{
    [super dealloc];
    [backgroundImage release];
    [lastModifiedDate release];
    [fileName release];
    [pieChart release];
    [localId release];
    [fileSize release];
    [DocumentName release];
    
}
@end
