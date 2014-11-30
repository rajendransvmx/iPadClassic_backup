//
//  OPDocViewController.h
//  iService
//
//  Created by Damodar on 4/29/13.
//
//

#import <UIKit/UIKit.h>
#import "JSExecuter.h"
#import "OPDocSignatureViewController.h"

/**
 *  @file   OPDocViewController.h
 *  @class  OPDocViewController
 *
 *  @brief This is the entry class to initiate the SMart Doc process
 *
 *   This class adds the webview to the view and provides with
 *   path of core library and loads the process id and record id
 *
 *   -- initiates Smart doc generation
 *   -- On finalize stores the signatures and html document to local
 *   -- Adds entries to the corresponding table in DB
 *
 *  @author Damodar Shenoy
 *  @bug No bugs
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@interface OPDocViewController : UIViewController <UINavigationControllerDelegate,JSExecuterDelegate, OPDocSignatureDelegate, OPDocSignatureDataSource>
{
    OPDocSignatureViewController *sign;
    
    NSData *signimagedata;
    
    BOOL isShowingSignatureCapture;
    BOOL ifFileAvailable;
    
    NSString *existingFilePath;
}

@property (nonatomic, copy) NSString                    *opdocTitleString; /*!< Parent name field value to be set to back bar button */

@property (nonatomic, copy) NSString                    *objectName; /*!< Parent object name */

@property (nonatomic, copy) NSString                    *recordIdentifier; /*!< Parent local Id */

@property (nonatomic, copy) NSString                    *processIdentifier; /*!< OPDoc process ID */

@property (nonatomic, copy) NSString                    *processSFID; /*!< OPDoc process SFID */

@property (nonatomic, copy) NSString                    *localIdentifier; /*!< Parent record's local Id */

@property (nonatomic, strong) NSArray                   *signatureArray; /*!< List f non-finalized signatures */

@property (nonatomic, strong) NSString                  *signEventName; /*!< Current signature's event name with sign Id */

@property (nonatomic, strong) NSString                  *signEventParameterString; /*!< Signature event parameter string containing the name format to store the signature locally */

@property (nonatomic, strong) NSMutableDictionary       *signatureInfoDict; /*!< Map of signatures before finalize signEventParameterString -> Actual name stored */

@property (nonatomic, strong) JSExecuter                *jsExecuter; /*!< JSExecuter object to load web view with core library imports */

/**
 * @name addJsExecuterToView
 *
 * @author Damodar Shenoy
 *
 * @brief Adds the webview to the controllers view using JSExecuter class and loads the core library
 *
 * \par
 *
 * @param  nil
 * @return void
 *
 */

- (void)addJsExecuterToView;

/**
 * @name setTitleForOutputDocs
 *
 * @author Damodar Shenoy
 *
 * @brief Sets the back button with the title name field value of parent record
 *
 * \par
 *
 * @param  nil
 * @return void
 *
 */

- (void)setTitleForOutputDocs;

/**
 * @name captureSignature
 *
 * @author Damodar Shenoy
 *
 * @brief Loads the signature capture view using OPDocSignatureViewController class
 *
 * \par
 *
 * @param  nil
 * @return void
 *
 */

- (void)captureSignature;

/**
 * @name finalizeAndStoreHTML:
 *
 * @author Damodar Shenoy
 *
 * @brief Stores the HTML file doc to local directory along with its corresponding signatures and starts the data sync
 *
 * \par
 *
 * @param  Dictionary containing the details : process id, record id and current date for naming the html file
 * @return void
 *
 */

- (void)finalizeAndStoreHTML:(NSDictionary *)finalizeDict;

/**
 * @name initWithNibName: bundle: forObject: forRecordId: andLocalId: andProcessId: andProcessSFId:
 *
 * @author Damodar Shenoy
 *
 * @brief Initializes OPDocViewController with given input parameters. Unexpecte behavior if any of the input params are nil.
 *
 * \par
 *
 * @param  nibNameOrNil : Nib from which the view has to be loaded
 * @param  nibBundleOrNil : bundle from which the nib has to be taken from
 * @param  objectName : Name of the parent object
 * @param  recordId : Id of the parent record
 * @param  localId : local id of parent record
 * @param  processId : local Id of the OPDoc process
 * @param  pSFId : SFId of the OPDoc process
 * @return An object of OPDocViewController
 *
 */

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forObject:(NSString*)objectName forRecordId:(NSString *)recordId andLocalId:(NSString *)localid andProcessId:(NSString *)processId andProcessSFId:(NSString *)pSFId;

@end
