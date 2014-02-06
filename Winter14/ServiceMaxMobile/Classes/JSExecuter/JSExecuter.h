//
//  JSExecuter.h
//  JavascriptInterface
//
//  Created by Shravya shridhar on 2/15/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import <Foundation/Foundation.h>

/* It is controller class which excecutes the javascript given to it*/
@interface JSExecuter : NSObject  <UIWebViewDelegate>{
    
    UIWebView *jsWebView;
    NSString  *codeSnippet;
    id         delegate;
    UIView    *parentView;
}

@property(nonatomic,retain)UIWebView *jsWebView;
@property(nonatomic,retain)NSString  *codeSnippet;
@property(nonatomic,assign)id         delegate;
@property(nonatomic,retain)UIView    *parentView;

- (id)initWithParentView:(UIView *)parentView andCodeSnippet:(NSString *)codeSnippet andDelegate:(id)delegate;
- (void)executeJavascriptCode:(NSString *)jsCodeSnippet;
- (void)loadHTMLFileFromPath:(NSString *)htmlFilePath;
- (NSString *)response:(NSString *)responseJsonString   forEventName:(NSString *)eventName;
- (id)initWithParentView:(UIView *)newParentView
          andCodeSnippet:(NSString *)newCodeSnippet
             andDelegate:(id)newDelegate
                andFrame:(CGRect)newFrame;
@end


@protocol JSExecuterDelegate <NSObject>

- (void)eventOccured:(NSString *)eventName andParameter:(NSString *)jsonParameterString;

@end