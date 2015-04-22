//
//  SalesForceRestApi.h
//  iService
//
//  Created by Sahana on 05/11/13.
//
//

#import <Foundation/Foundation.h>
#import "SFRestAPI.h"
#import "SFRestRequest.h"
#import "RKClient.h"
#import "SFOAuthCoordinator.h"

//@interface SalesForceRestApi : NSObject <SFRestDelegate,SFOAuthCoordinatorDelegate,RKRequestDelegate>
@interface SalesForceRestApi : NSObject <SFRestDelegate,RKRequestDelegate, UIWebViewDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, assign) UIView *view;

@property (nonatomic, assign) UIViewController *pController;
@property (nonatomic, assign) BOOL completeTest;

-(void)makeRequest;
@end
