//
//  cameraAttachmentViewController.h
//  ServiceMaxMobile
//
//  Created by Kirti on 08/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cameraAttachmentViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationBarDelegate>
{
    UIImagePickerController *cameraViewController;             /**<  Instance of UIImagePickerController which provides interface for camera and photo library with your application */

    BOOL isImageFromCamera;                                    /**< Check the image captured from camera or gallery */

}
@property (retain, nonatomic) UIImagePickerController *cameraViewController;

/**< Button actions for capturing image from camera or gallery*/

- (IBAction)CaptureCameraImageBtnAction:(id)sender;
- (IBAction)CaptureGalleryImageBtnAction:(id)sender;

@end
