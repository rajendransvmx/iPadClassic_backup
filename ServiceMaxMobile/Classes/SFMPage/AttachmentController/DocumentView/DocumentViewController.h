//
//  DocumentViewController.h
//  ServiceMaxMobile
//
//  Created by Kirti on 07/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentViewCell.h"
#import "AttachmentViewController.h"

@protocol DocumentViewControllerDelegate <NSObject>

-(void) displayAttachment:(NSString *)attachmentId fielName:(NSString *)fileName category:(NSString *)categoty;

@end


@interface DocumentViewController : AttachmentViewController<UITableViewDataSource,UITableViewDelegate> {
    IBOutlet UITableView *mainTableView;
    BOOL   isInEditMode;
    NSMutableDictionary *selectedIdDictionary;
    BOOL   isViewProcess;
    NSString *tapToDownloadString;
}
@property (nonatomic,retain)UITableView *mainTableView;
@property (nonatomic,assign)BOOL   isInEditMode;
@property (nonatomic, retain) NSMutableArray *documentsArray;
@property (nonatomic,retain)NSMutableDictionary *selectedIdDictionary;
@property (nonatomic,assign) BOOL   isViewProcess;
@property (nonatomic,retain)IBOutlet UIButton *editButton;
@property (nonatomic, retain)IBOutlet UIButton *cancelButton;
@property (nonatomic, assign) id<DocumentViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIImageView *pencilIcon;
@property (nonatomic,retain)NSString *tapToDownloadString;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

- (IBAction)updateDocumentList:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
- (void) refreshDocuments;
- (void) deleteAttachment:(NSString *)localId;

@end
