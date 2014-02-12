//
//  ChatterCell.m
//  iService
//
//  Created by Samman Banerjee on 30/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChatterCell.h"
#import "Base64.h"
//Radha 22nd April 2011
#import "LocalizationGlobals.h"

@implementation ChatterCell

@synthesize delegate;
@synthesize dayLabel;
@synthesize CreatedById, FeedPostId, feedCommentId;
@synthesize postComment;
@synthesize email;
//@synthesize commentButton;
- (void) setPostUserName:(NSString *)userName ChatText:(NSString *)chatText DateTime:(NSString *)dateTime UserImage:(UIImage *)userImage
{
    usernameLabel.text = userName;
    chattextLabel.text = chatText;
    if (userImage != nil)
        userImageView.image = userImage;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date = [dateFormatter dateFromString:dateTime];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    
    datetimeLabel.text = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
  }

- (void) setCommentUserName:(NSString *)userName ChatText:(NSString *)chatText DateTime:(NSString *)dateTime UserImage:(UIImage *)userImage
{
    commentUsernameLabel.text = userName;
    commentChattextLabel.text = chatText;
    if (userImage != nil)
        commentUserImageView.image = userImage;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date = [dateFormatter dateFromString:dateTime];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    
    commentDatetimeLabel.text = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    
}

//Radha 25th April 2011
- (void)setText:(NSString *)commentName
{
    [commentButton setTitle:commentName forState:UIControlStateNormal];
    
}
//Radha 25th April 2011
-(void) setPlaceholder:(NSString *)placeholder
{
    postComment.placeholder = placeholder;
}


- (void) resetImages
{
    userImageView.image = [UIImage imageNamed:@"user.png"];
    commentUserImageView.image = [UIImage imageNamed:@"user.png"];
}

- (IBAction) post;
{
    [delegate postComment:postComment.text forFeedCommentId:feedCommentId];
    self.postComment.text = @"";
    self.postComment.enabled = NO;
}

//  Unused methods
- (IBAction)facetime_call:(id)sender
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"facetime://%@", email]];
    // NSURL *url = [NSURL URLWithString:@"facetime:+919980063682"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)dealloc
{
    [feedCommentId release];
    [userImageView release];
    [usernameLabel release];
    [chattextLabel release];
    [datetimeLabel release];
    
    [commentUserImageView release];
    [commentUsernameLabel release];
    [commentChattextLabel release];
    [commentDatetimeLabel release];
    
    [dayLabel release];
    
    [CreatedById release];
    [FeedPostId release];
    [postComment release];    
    [commentButton release];
    [super dealloc];
}

@end
