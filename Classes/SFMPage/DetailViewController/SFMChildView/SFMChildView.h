//
//  SFMChildView.h
//  iService
//
//  Created by Radha S on 6/3/13.
//
//

#import <UIKit/UIKit.h>

@protocol SFMChildViewDelegate;


@interface SFMChildView : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (retain, nonatomic) IBOutlet UITableView *childTableview;
@property (retain, nonatomic) NSArray * linkedProcess;
@property (retain, nonatomic) NSString * detailObjectname;
@property (retain, nonatomic) NSString * headerObjectName;
@property (retain, nonatomic) NSString * record_id;
@property (retain, nonatomic) id <SFMChildViewDelegate> childViewDelegate;

-(CGFloat) getHeightForChildLinkedProcess;

#define ITEMCOUNT	3

@end

@protocol SFMChildViewDelegate <NSObject>

@optional
//Methods to be called
- (void) showSFMPageForChildLinkedProcessWithProcessId:(NSString *)processId record_id:(NSString *)recordId  detailObjectName:(NSString *)detailObjectName;
@end
