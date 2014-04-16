//
//  OPDocTemplateSelectorViewController.h
//  iService
//
//  Created by Krishna Shanbhag on 21/05/13.
//
//

#import <UIKit/UIKit.h>

//protocol for get multiple doc templates
@protocol loadDocTemplate <NSObject>
- (void)doctemplateId:(NSString *)docId forProcessId:(NSString *)processId;
@end

@interface OPDocTemplateSelectorViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    

}
@property (nonatomic, assign)     id<loadDocTemplate>delegate;
@property (nonatomic, retain)     NSMutableArray *docTemplatesArray;
@end
