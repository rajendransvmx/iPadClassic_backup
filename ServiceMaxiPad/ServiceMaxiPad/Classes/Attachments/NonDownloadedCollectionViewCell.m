//
//  NonDownloadedCollectionViewCell.m
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/6/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "NonDownloadedCollectionViewCell.h"
#import "StyleManager.h"

@implementation NonDownloadedCollectionViewCell

@synthesize fileNamelbl;
@synthesize fileSizelbl;
@synthesize imageIcon;
@synthesize videoIcon;
@synthesize progressView;
@synthesize errorlbl;
static UIImage *DownloadIcon;

-(void)initialSetUP{
    progressView.hidden=YES;
    [self setBackgroundImage];
    [self setFileName];
    [self setFileSize];
}
-(void)setBackgroundImage{
    [self addSubview:imageIcon];
}

-(void)setFileName{
    [self setFont:fileNamelbl];
}

-(void)setFileSize{
    [self setFont:fileSizelbl];
    [self setErrorFont:errorlbl];
}
-(void)setFont:(UILabel *)label{
    label.font=[UIFont fontWithName:kHelveticaNeueLight size:14.0];
    label.textColor=[UIColor colorWithHexString:@"157DFB"];
    label.textAlignment=NSTextAlignmentCenter;
}
-(void)setErrorFont:(UILabel *)label{
    label.font=[UIFont fontWithName:kHelveticaNeueLight size:14.0];
    label.textColor=[UIColor redColor];
    label.textAlignment=NSTextAlignmentCenter;
}
-(void)errorCell:(BOOL)isError{
    if (isError) {
        imageIcon.image=[UIImage imageNamed:@"Attachment-File-Missing@2x.png"];
        errorlbl.hidden=NO;
    }else{
        errorlbl.hidden=YES;
    }
}
-(void)initialSerup:(NSDictionary *)fileInfo Iserror:(BOOL)isFileError{
    [self errorCell:isFileError];
    progressView.hidden=YES;
    [self setBackgroundImage];
    [self setFileName];
    [self setFileSize];
}
@end
