//
//  imageCollectionViewCell.h
//  ServiceMaxMobile
//
//  Created by Sahana on 07/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef enum IMAGE_CELL_TYPE
{
    IMAGE_EXISTS = 0,
    DOWNLOAD_IMAGE = 1,
    DOWNLOAD_INQUEUE = 2,
    ERROR_IN_DOWNLOAD = 3,
    DEFAULT = 4
    
}IMAGE_CELL_TYPE;

@interface imageCollectionViewCell : UICollectionViewCell
@property (nonatomic ) IMAGE_CELL_TYPE imageCellType;
@property (nonatomic , retain) NSString * DocumentName;
@property (nonatomic, retain) NSString * localId;
@property (nonatomic, retain) NSString * Attachmentsf_id;
@property (nonatomic, retain) UIImageView * backgroundImage;
@property (nonatomic, retain) UIImageView * vedioImage;
@property (nonatomic, retain) UILabel * errorMsg;
@property (nonatomic, retain) UILabel * fileName;
@property (nonatomic, retain) UILabel * fileSize;
@property (nonatomic, retain) UILabel * lastModifiedDate;
@property (nonatomic, retain) UIView * pieChart;
@property (nonatomic, retain) UILabel * downloadMsg;
@property (nonatomic, retain) NSString * fileType;

-(void)fillCollectionviewcell:(IMAGE_CELL_TYPE)cellType;
-(void)addImageView;
-(void)addLabel:(NSString *)type;
-(CGRect)getrectFor:(NSString *)type;
-(void)highlightcellForDeletion;
-(void)UnhighlightcellFromDeletion;
-(BOOL)select;
@end

#define FILE_SIZE               @"FILE_SIZE"
#define ATTACHMENT_FILE_NAME    @"FILE_NAME"
#define FILE_ERROR_MSG          @"FILE_ERROR_MSG"
#define LAST_MOD_DATE           @"LAST_MOD_DATE"
#define DATE_DOWNLOADED         @"DATE_DOWNLOADED"
#define DOWNLOADMSG             @"DOWNLOADMSG"
#define VEDIO_IMG               @"VEDIO_IMG"
#define CLOUD_IMG               @"CLOUD_IMG"

#define VEDIO                   @"VEDIO"
#define IMAGES                   @"Image"
#define PRESENTATION            @"Presentation"
#define PDF                     @"Pdf"
#define SPREADSHEET             @"Spreadsheet"
#define DOCUMENT                @"Document"
#define OPDOC                   @"OPDoc"
#define UNKNOWNTYPE             @"UnknownType"