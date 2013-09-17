//
//  SMGPCodeSnippetResponseParser.m
//  iService
//
//  Created by Siva Manne on 30/01/13.
//
//

#import "SMGPCodeSnippetResponseParser.h"
#import "INTF_WebServicesDefServiceSvc.h"

#undef kEnableLog
@implementation SMGPCodeSnippetResponseParser
- (BOOL) parseResponse:(NSArray *)result
{
    for(int i=0; i<[result count]; i++)
    {
        NSAutoreleasePool *iPool = [[NSAutoreleasePool alloc] init];
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapObject = [result objectAtIndex:i];
#ifdef kEnableLog
        NSLog(@"Code Snippet Response = %@",svmxMapObject);
#endif
        NSString *jsonRecord = [svmxMapObject value];
#ifdef kEnableLog
        NSLog(@"JSON Response  = %@",jsonRecord);
#endif
        SBJsonParser * jsonParser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary * json_dict = [jsonParser objectWithString:jsonRecord];
        
        NSString *codeSnippet = nil;
        NSString *referencedCodeSnippet = nil;
        NSString *data = nil;
        NSString *name = nil;
        NSString *type = nil;
        NSString *snippetId = nil;
        NSString *snippetName = nil;
        NSString *ID = nil;
        NSString *localId = nil;
        codeSnippet = [json_dict objectForKey:@"SVMXC__Code_Snippet__c"];
        referencedCodeSnippet = [json_dict objectForKey:@"SVMXC__Referenced_Code_Snippet__c"];

        if(codeSnippet != nil)
        {
            if(referencedCodeSnippet != nil)
            {
                data = [json_dict objectForKey:@"SVMXC__Data__c"];
                ID = [json_dict objectForKey:@"Id"];
                snippetName = [json_dict objectForKey:@"Name"];
                localId = [self getUUID];

                if(snippetName == nil) snippetName = @"";
                if(ID == nil) ID = @"";

                NSString *values = [NSString stringWithFormat:@"'%@','%@','%@','%@','%@'",localId,ID,codeSnippet,snippetName,referencedCodeSnippet];
                NSArray *keys = [NSArray arrayWithObjects:@"local_id",@"Id",@"SVMXC__Code_Snippet__c",@"Name",@"SVMXC__Referenced_Code_Snippet__c", nil];
                
                NSString  *queryStatement = [NSString stringWithFormat:@"INSERT INTO SVMXC__Code_Snippet_Manifest__c (%@) VALUES (%@)",[keys componentsJoinedByString:@","],values];
                [self execStatementOnDataBase:queryStatement];
            }
        }
        else
        {
            data = [json_dict objectForKey:@"SVMXC__Data__c"];
            name = [json_dict objectForKey:@"SVMXC__Name__c"];
            type = [json_dict objectForKey:@"SVMXC__Type__c"];
            snippetId = [json_dict objectForKey:@"SVMXC__SnippetId__c"];
            ID = [json_dict objectForKey:@"Id"];
            snippetName = [json_dict objectForKey:@"Name"];
            localId = [self getUUID];
            
            if(data == nil) data = @"";
            if(name == nil) name = @"";
            if(type == nil) type = @"";
            if(snippetId == nil) snippetId = @"";
            if(ID == nil) ID = @"";
            
            data = [data stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;" ];
            
            NSString *values = [NSString stringWithFormat:@"\"%@\",'%@','%@','%@','%@','%@','%@'",data,name,type,snippetId,localId,ID,snippetName];
            NSArray *keys = [NSArray arrayWithObjects:@"SVMXC__Data__c",@"SVMXC__Name__c",@"SVMXC__Type__c",@"SVMXC__SnippetId__c",@"local_id",@"id",@"Name", nil];
            
            NSString  *queryStatement = [NSString stringWithFormat:@"INSERT INTO SVMXC__Code_Snippet__c (%@) VALUES (%@)",[keys componentsJoinedByString:@","],values];
            [self execStatementOnDataBase:queryStatement];
        }
        [iPool drain];
    }
    return FALSE;
}
@end
