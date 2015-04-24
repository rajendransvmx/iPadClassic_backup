//
//  MPickContent.h
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol setTextfield;
@protocol releasePopOver;

//Radha 9th August
NSInteger pickListcount;

@interface MPickContent : UIViewController <UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate> 
{
    NSString   * lookUp;  
    NSMutableArray    * pickListContent;//5878
    NSIndexPath	* lastIndexPath;
    NSMutableArray * index;
    id <setTextfield>  MPickerDelegate;  
    id <releasePopOver> releasPODelegate;
    NSMutableDictionary *dict;
    NSMutableArray *dictArray;
    BOOL flag;
    NSString  * initialString;
}
@property (nonatomic , retain) NSString  * initialString; 
@property (nonatomic) BOOL flag;
@property (nonatomic , retain ) NSMutableDictionary *dict;
@property (nonatomic , retain)  NSMutableArray *dictArray;
@property (nonatomic , retain) NSString * lookUp;
@property (nonatomic ,retain) NSMutableArray * index;
@property (nonatomic ,retain)  NSMutableArray * pickListContent;//5878
@property (nonatomic, retain) NSIndexPath * lastIndexPath;
@property (nonatomic, assign)  id <setTextfield>  MPickerDelegate;
@property (nonatomic ,assign) id <releasePopOver> releasPODelegate;

- (void) showEmptyList;

@end

@protocol setTextfield <NSObject>

@optional

-(void)setTextfield: ( NSMutableArray *) values;

@end

@protocol releasePopOver <NSObject>

@optional

-(void) releasPopover;

@end
