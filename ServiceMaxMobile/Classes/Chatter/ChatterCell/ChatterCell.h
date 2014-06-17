//
//  ChatterCell.h
//  iService
//
//  Created by Samman Banerjee on 30/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatterCellDelegate

@optional
- (void) postComment:(NSString *)_comment forFeedCommentId:(NSString *)_feedCommentId;

@end


@interface ChatterCell : UITableViewCell
{
    id <ChatterCellDelegate> delegate;

    IBOutlet UIImageView * userImageView;
    IBOutlet UILabel * usernameLabel;
    IBOutlet UILabel * chattextLabel;
    IBOutlet UILabel * datetimeLabel;
    
    IBOutlet UIImageView * commentUserImageView;
    IBOutlet UILabel * commentUsernameLabel;
    IBOutlet UILabel * commentChattextLabel;
    IBOutlet UILabel * commentDatetimeLabel;
    
    IBOutlet UILabel * dayLabel;
    
    NSString * CreatedById;
    NSString * FeedPostId;
    NSString * feedCommentId;
    
    IBOutlet UITextField * postComment;
    
    NSString * email;
    //Radha 22nd April 2011
    //Localization
    IBOutlet UIButton * commentButton;
}

@property (nonatomic, assign) id <ChatterCellDelegate> delegate;

@property (nonatomic, retain) IBOutlet UILabel * dayLabel;
@property (nonatomic, retain) NSString * CreatedById;
@property (nonatomic, retain) NSString * FeedPostId;
@property (nonatomic, retain) NSString * feedCommentId;
@property (nonatomic, retain) UIButton * commentButton;
@property (nonatomic, retain) IBOutlet UITextField * postComment;

@property (nonatomic, retain) NSString * email;

- (void) setPostUserName:(NSString *)userName ChatText:(NSString *)chatText DateTime:(NSString *)dateTime UserImage:(UIImage *)userImage;
- (void) setCommentUserName:(NSString *)userName ChatText:(NSString *)chatText DateTime:(NSString *)dateTime UserImage:(UIImage *)userImage;

//Radha 25th April 2011
//Set the comment button text
-(void) setText:(NSString *)commentName;
-(void) setPlaceholder:(NSString *)placeholder;


- (void) resetImages;

- (IBAction) post;
- (IBAction)facetime_call:(id)sender;//  Unused methods

#define CHATTEREMAIL   @"Email"

@end
