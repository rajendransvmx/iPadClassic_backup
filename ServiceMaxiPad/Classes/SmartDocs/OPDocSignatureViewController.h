//
//  OPDocSignatureViewController.h
//  iService
//
//  Created by Krishna Shanbhag on 30/05/13.
//
//

#import <UIKit/UIKit.h>

@class OPDocViewController;

@protocol OPDocSignatureDelegate;
@protocol OPDocSignatureDataSource;

#define TIMEFORMAT          @"EEE,dd MMM yyyy hh:mm:ss a"
#define MAX_WIDTH           539
#define MAX_HEIGHT          258

/**
 *  @file   OPDocSignatureViewController.h
 *  @class  OPDocSignatureViewController
 *
 *  @brief A controller to capture user signature using its view and watermarks
 *
 *   Responsible for capturing, recapturing and erasing the drawn signature
 *
 *   -- Extract the signature along with watermark
 *   -- Hand draw signatures
 *   -- Attach watermark
 *
 *  @author Damodar Shenoy
 *  @bug No bugs
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@interface OPDocSignatureViewController : UIViewController
    
@property (nonatomic, assign) BOOL                              isSigned; /*!< Flag to check whether anything is drawn on the canvas */
@property (nonatomic, assign) BOOL                              mouseSwiped; /*!< Flag to check the validity of the signature : dots are ignored */

@property (nonatomic, strong) NSData                            *imageData; /*!< Raw signature data */
@property (nonatomic, strong) NSData                            *encryptedImageData; /*!< Encrypted signature data */

@property (nonatomic, strong) NSString                          *signatureName; /*!< Name of the signature used for storing locally */
@property (strong, nonatomic) NSMutableArray                    *signatureDataArray; /*!< list of signatures */

@property (strong, nonatomic) IBOutlet UIView                   *titleBG; /*!< Title view */
@property (strong, nonatomic) IBOutlet UIButton                 *doneButton; /*!< Done button outlet */
@property (strong, nonatomic) IBOutlet UIButton                 *cancelButton; /*!< Cancel button outlet */
@property (strong, nonatomic) IBOutlet UIView                   *watermarkedSignature; /*!< Watermark + signature container view */
@property (strong, nonatomic) IBOutlet UITextView               *watermark; /*!< Watermark text view */
@property (strong, nonatomic) IBOutlet UIImageView              *drawImage; /*!< Image view to display the signature after watermarking */
@property (strong, nonatomic) IBOutlet UIView                   *drawView; /*!< Canvas view to draw the signature */
@property (strong, nonatomic) IBOutlet UILabel                  *titleLabel; /*!< Title of signature panel */

@property (nonatomic, weak) OPDocViewController               *parent; /*!< Parent view controller of the Signature view controller */

@property (nonatomic, weak) id <OPDocSignatureDelegate>       delegate; /*!< Delegate to signature vc */
@property (nonatomic, weak) id <OPDocSignatureDataSource>     dataSource; /*!< Data source for signature vc */

/**
 * @name cancel:
 *
 * @author Damodar Shenoy
 *
 * @brief Cancels button action : The drawn signature clears the canvas and removes the signature view from superview
 *
 * \par
 *
 * @param  Button sender
 * @return IBAction
 *
 */

- (IBAction)cancel:(id)sender;

/**
 * @name done:
 *
 * @author Damodar Shenoy
 *
 * @brief Button Action : Initiates teh signature save process
 *
 * \par
 *
 * @param  Button sender
 * @return IBAction
 *
 */

- (IBAction)done:(id)sender;

/**
 * @name erase
 *
 * @author Damodar Shenoy
 *
 * @brief Button action : Clears the canvas
 *
 * \par
 *
 * @param  Button sender
 * @return IBAction
 *
 */

- (IBAction)erase:(id)sender;

/**
 * @name setImage
 *
 * @author Damodar Shenoy
 *
 * @brief Sets the signature to imageview after watermarking
 *
 * \par
 *
 * @param  nil
 * @return void
 *
 */

- (void)setImage;

@end

/**
 *  @protocol OPDocSignatureDelegate
 *
 *  @brief Delegate protocol to send the captured signature
 *
 *
 *   -- Send the watermarked signature along with the sign Id against which the sign has to be saved using the given name
 *
 *  @author Damodar Shenoy
 *  @bug No bugs
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@protocol OPDocSignatureDelegate <NSObject>

@optional

/**
 * @name setSignImageData: withSignId: andSignName:
 *
 * @author Damodar Shenoy
 *
 * @brief Send the watermarked signature along with the sign Id against which the sign has to be saved using the given name
 *
 * \par
 *
 * @param  imageData : Raw signature data
 * @param  signId : Unique signature identifier
 * @param  signName : Unique signature name
 * @return void
 *
 */

- (void)setSignImageData:(NSData *)imageData withSignId:(NSString *)signId andSignName:(NSString *)signName;

@end

/**
 *  @protocol OPDocSignatureDataSource
 *
 *  @brief Datasource protocol to get the watermark text for signature
 *
 *
 *   -- Get the watermark for signature
 *
 *  @author Damodar Shenoy
 *  @bug No bugs
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@protocol OPDocSignatureDataSource <NSObject>

@optional

@required


/**
 * @name getWaterMarktext
 *
 * @author Damodar Shenoy
 *
 * @brief Get the watermark string for signature. A required method
 *
 * \par
 *
 * @param  nil
 * @return NSString object containing the text
 *
 */

- (NSString*)getWaterMarktext;

@end

