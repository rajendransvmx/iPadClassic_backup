//
//  RouteControllerCell.m
//  iService
//
//  Created by Samman Banerjee on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RouteControllerCell.h"


@implementation RouteControllerCell

- (void) setCellText:(NSString *)cellText;
{
    //Krishna Map 7005
    // [textView setContentToHTMLString:cellText];
    [textView setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    [textView setText:[self flattenHTML:cellText]];
}

- (NSString *)flattenHTML:(NSString *)html
{
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
        
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@>", text]
                                               withString:@" "];
        
    } // while //
    
    return html;
    
}


- (void)dealloc
{
    [textView release];
    [super dealloc];
}


@end
