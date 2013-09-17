//
//  LoggingController.h
//  iService
//
//  Created by Keerti Bhatnagar on 02/03/12.
//  Copyright (c) 2012 keerti.bhatnagar@servicemax.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
void NSLog(NSString *format, ...);

void NSLog(NSString * format,...){
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL enabled_logging = [defaults boolForKey:@"enabled_logging"];
    
    if(enabled_logging)
    {
        if (format == nil)
        {
            NSLog(@"nil\n");
            return;
        }
        va_list args;
        va_start(args, format);
        NSString *s = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(@"%@",s);
        [s release];
        va_end(args);
    }
}
*/