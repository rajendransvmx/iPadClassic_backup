//
//  OPDocDAO.h
//  ServiceMaxiPad
//
//  Created by Damodar on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

/**
 *  @file   OPDocDAO.h
 *  @class  OPDocDAO.h
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
#import "OPDocHTML.h"
@protocol OPDocDAO <CommonServiceDAO>

/* Add signatures and HTML file to tables */
- (void)addHTMLfile:(OPDocHTML*)html;

/* Update SFID of signatures and HTML file to tables */
- (void)updateHTML:(OPDocHTML*)html;

/* Get the model object for file name */
- (OPDocHTML*)getHTML:(NSString*)htmlName;



/* DAO methods to access the process, header-object and other details to pre-load the smart doc */

/* DAO methods for SVMXDatabaseMaster */


-(BOOL)updateFileNameInTableForModel:(OPDocHTML*)model withNewFileName:(NSString *)lNewFileName;

/* Reverts with the OPDocHTML model list for which sfid is nil*/

-(NSMutableArray *)getHTMLModelListForFileUpload;
-(NSMutableArray *)getLocalHTMLModelList;

-(NSArray *)getLocallySavedHTMLListForId:(NSString*)recordId;

/* Reverts with the list of SFID's to be submitted to the server*/
-(NSArray *)getHTMLListToSubmit;
-(NSArray *)getHTMLListToSubmitForHtmlFile:(NSString *)htmlFile;

-(BOOL)deleteRecordsHTMLTableForList:(NSArray *)listArray;
-(NSString*)deleteRecordFromTableOnConflict:(NSString*)recordId;

//Retreive the names of the files which needs to be deleted from the folder.

-(NSArray *)getAllFilesPresentInTableForWhichNeedsToBeDeleted:(NSString *)theHTMLSFIDOrHTMLFileName; //This is needed to delete the record from tables of HTML as well as SIGNATURE cause if a DELETE_ID is received from Server, we have to delete the associated ID's from both tables


//To Delete the SFID's from those records whose doc-Submission API has failed. This is done, so that when these files are submitted again for uploading, it gets the SFID's again. Its a FAIL-Safe mechanism.
-(BOOL)updateTableToRemovetheSFIDForList:(NSArray *)listArray;

-(NSMutableArray*)getDistinctTableNamesFromOpDocHTMLWithFields:(NSArray*)fieldNames withDistinctFlag:(BOOL)isDistinct;
//To get the workorder name with OpDocHTML table's recordID.
- (NSMutableArray*)getWorkOrderNameWithTableName:(NSString*)tableName withRecordIdArray:(NSMutableArray*)recordIdArray;

// 028365
-(NSString *)getParentRecordSfId:(NSString*)objectName withRecordId:(NSString *)recordId;

@end
