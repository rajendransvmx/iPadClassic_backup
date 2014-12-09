//
//  OPDocSignatureDAO.h
//  ServiceMaxiPad
//
//  Created by Damodar on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

/**
 *  @file   OPDocSignatureDAO.h
 *  @class  OPDocSignatureDAO.h
 *
 *  @brief
 *
 *   This is a protocol class
 *
 *  @author Damodar
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "OPDocSignature.h"

@protocol OPDocSignatureDAO <CommonServiceDAO>

/* Add signatures and HTML file to tables */
- (void)addSignature:(OPDocSignature*)model;

/* Update SFID of signatures and HTML file to tables */
- (void)updateSignature:(OPDocSignature*)model;

/* Get the model object for file name */
- (OPDocSignature*)getSignatureObjectFor:(NSString*)signatureName;

/* DAO methods to access the process, header-object and other details to pre-load the smart doc */

/* DAO methods for SVMXDatabaseMaster */

-(BOOL)updateFileNameInTableForModel:(OPDocSignature*)model withNewFileName:(NSString *)lNewFileName;

/*Retrieve all signature records for a given html file name*/
- (NSArray*)getSignaturesForHTMLFile:(NSString*)htmlFilename;

/* Update signature records with new htmlfilename */
- (void)updateHTMLFilenameInSignature:(OPDocSignature*)model;

/*Reverts with the list for which sfid is nil*/
-(NSMutableArray *)getSignatureModelListForFileUpload;

/* Reverts with the list of SFID's required to be submitted to the Server*/
-(NSMutableArray *)getSignatureListToSubmit;

-(BOOL)deleteRecordsSignatureTableForList:(NSArray *)listArray;

//To retrieve the list of files to be deleted from folder.
-(NSArray *)getAllFilesPresentInTableForWhichNeedsToBeDeleted;

@end
