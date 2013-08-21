//
//  YouTubeView.m
//  iService
//
//  Created by Samman Banerjee on 01/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YouTubeView.h"


@implementation YouTubeView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark Initialization
//  Unused methods
//- (YouTubeView *)initWithStringAsURL:(NSString *)urlString frame:(CGRect)frame;
//{
//    self = [super init];
//    if (self) 
//    {
//        // Create webview with requested frame size
//        self = [[UIWebView alloc] initWithFrame:frame];
//        
//        // HTML to embed YouTube video
//        NSString *youTubeVideoHTML = @"<html><head>\
//        <body style=\"margin:0\">\
//        <embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
//        width=\"%0.0f\" height=\"%0.0f\"></embed>\
//        </body></html>";
//        
//        // Populate HTML with the URL and requested frame size
//        NSString *html = [NSString stringWithFormat:youTubeVideoHTML, urlString, frame.size.width, frame.size.height];
//        
//        // Load the html into the webview
//        [self loadHTMLString:html baseURL:nil];
//    }
//    return self;  
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
