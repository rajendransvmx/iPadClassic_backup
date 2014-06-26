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
//D-00003728
-(void) displayAttachmentSharingView:(NSArray *)dataSource viewName:(NSString *)view;

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
@property (nonatomic,retain)NSString *tapToDownloadString;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *share;  //D-00003728
@property (retain, nonatomic) IBOutlet UIButton *deleteButton;
@property (retain, nonatomic) NSMutableDictionary * sharingAttachmentList;

- (IBAction)shareAttachment:(id)sender; //D-00003728
- (IBAction)updateDocumentList:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
- (void) refreshDocuments;
- (void) deleteAttachment:(NSString *)localId;
-(void)handleErrorForCell:(DocumentViewCell *)cell
           withAttachment:(NSDictionary *)documentDict
                andStatus:(int)status; //9212
@end
