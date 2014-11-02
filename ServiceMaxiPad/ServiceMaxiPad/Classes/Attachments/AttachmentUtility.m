//
//  AttachmentUtility.m
//  ServiceMaxiPad
//
//  Created by Anoop on 10/29/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "AttachmentUtility.h"

@implementation AttachmentUtility

+(NSDictionary*)imageTypesDict {
    
    NSMutableDictionary *imagesDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [imagesDict setObject:@"jpg" forKey:@"jpg"];
    [imagesDict setObject:@"jpeg" forKey:@"jpeg"];
    [imagesDict setObject:@"bmp" forKey:@"bmp"];
    [imagesDict setObject:@"png" forKey:@"png"];
    [imagesDict setObject:@"tiff" forKey:@"tiff"];
    [imagesDict setObject:@"gif" forKey:@"gif"];
    [imagesDict setObject:@"dib" forKey:@"dib"];
    [imagesDict setObject:@"ico" forKey:@"ico"];
    [imagesDict setObject:@"cur" forKey:@"cur"];
    [imagesDict setObject:@"xbm" forKey:@"xbm"];
    [imagesDict setObject:@"tif" forKey:@"tif"];
    return imagesDict;
    
}

+(NSDictionary*)videoTypesDict {

    NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [videoDict setObject:@"mov" forKey:@"mov"];
    [videoDict setObject:@"m4v" forKey:@"m4v"];
    [videoDict setObject:@"mp4" forKey:@"mp4"];
    [videoDict setObject:@"3gp" forKey:@"3gp"];
    [videoDict setObject:@"3gpp" forKey:@"3gpp"];
    [videoDict setObject:@"3gp2" forKey:@"3gp2"];
    [videoDict setObject:@"3g2" forKey:@"3g2"];
    [videoDict setObject:@"qt" forKey:@"qt"];
    return videoDict;
    
}

+(NSDictionary*)documentTypesDict {
    
    //values with imagename for loading tableviewcell
    NSMutableDictionary *imagesDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [imagesDict setObject:@"Attachment-Powerpoint" forKey:@"ppt"];
    [imagesDict setObject:@"Attachment-PDF" forKey:@"pdf"];
    [imagesDict setObject:@"Attachment-Word" forKey:@"doc"];
    [imagesDict setObject:@"Attachment-Word" forKey:@"docx"];
    [imagesDict setObject:@"Attachment-Excel" forKey:@"xls"];
    [imagesDict setObject:@"Attachment-Excel" forKey:@"xlsx"];
    [imagesDict setObject:@"Attachment-SmartDoc" forKey:@"html"];
    return imagesDict;
    
}

@end
