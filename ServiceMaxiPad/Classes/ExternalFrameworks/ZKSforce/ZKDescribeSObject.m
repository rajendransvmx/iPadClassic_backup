// Copyright (c) 2006-2007 Simon Fell
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.
//


#import "ZKDescribeSObject.h"
#import "ZKDescribeField.h"
#import "ZKChildRelationship.h"
#import "ZKRecordTypeInfo.h"
#import "ZKParser.h"
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@implementation ZKDescribeSObject

-(void)dealloc 
{
	fields = nil;
	fieldsByName = nil;
	childRelationships = nil;
	recordTypeInfos = nil;
}


-(NSString *)urlDetail 
{
	return [self string:@"urlDetail"];
}

-(NSString *)urlEdit 
{
	return [self string:@"urlEdit"];
}

-(NSString *)urlNew 
{
	return [self string:@"urlNew"];
}

-(NSArray *)fields {
	if (fields == nil) 
    {
		NSArray * fn = [node childElements:@"fields"];
		NSMutableDictionary *byName = [NSMutableDictionary dictionary];
		NSMutableArray * fs = [NSMutableArray arrayWithCapacity:[fn count]];
		for (ZKElement *fieldNode in fn) 
        {
			ZKDescribeField * df = [[ZKDescribeField alloc] initWithXmlElement:fieldNode];
			[df setSobject:self];
			[fs addObject:df];
			[byName setObject:df forKey:[[df name] lowercaseString]];
		}
		fields = fs;
		fieldsByName = byName;
	}
	return fields;
}

-(ZKDescribeField *)fieldWithName:(NSString *)name {
	if (fieldsByName == nil) 
		[self fields];
	return [fieldsByName objectForKey:[name lowercaseString]];
}

-(NSArray *)childRelationships 
{
	if (childRelationships == nil) 
    {
		NSArray *crn = [node childElements:@"childRelationships"];
		NSMutableArray *crs = [NSMutableArray arrayWithCapacity:[crn count]];
		for (ZKElement *crNode in crn) 
        {
			ZKChildRelationship * cr = [[ZKChildRelationship alloc] initWithXmlElement:crNode];
			[crs addObject:cr];
		}
		childRelationships = crs;
	}
	return childRelationships;
}

- (NSString *)description 
{
	return [NSString stringWithFormat:@"SObject %@ (%@)", [self name], [self label]];
}

-(NSArray *)recordTypeInfos 
{
	if (recordTypeInfos == nil) 
    {
		NSArray *rti = [node childElements:@"recordTypeInfos"];
		NSMutableArray *res = [NSMutableArray arrayWithCapacity:[rti count]];
		for (ZKElement *rnode in rti) 
        {
			ZKRecordTypeInfo *r = [[ZKRecordTypeInfo alloc] initWithXmlElement:rnode];
			[res addObject:r];
		}
		recordTypeInfos = res;
	}
	return recordTypeInfos;
}

#pragma mark -
#pragma mark Utility methods

// list all the fields, return string with comma seperator
- (NSString *) getComaSepFieldList 
{
	NSString *ret = @"";for (ZKDescribeField *fieldNode in [self fields] ) {
		ret = [ret stringByAppendingFormat:@" %@,",[fieldNode name] ];
    }

	// and related name fields ( note: must have a Name)
	for (ZKDescribeField  *fieldNode in [self fields] ) {
		if ( [[fieldNode referenceTo] count] > 0 ) {
//			SMLog(kLogLevelVerbose,@"%@",[fieldNode description]);
//			SMLog(kLogLevelVerbose,@"%@",[fieldNode relationshipName]);
			NSString *fn = [fieldNode relationshipName];
			fn = [fn stringByAppendingFormat:@".Name"];
			ret = [ret stringByAppendingFormat:@" %@,", fn];
		}
	}
	
	NSRange myRange = {[ret length]-1,1};	// remove last comma
	return [ret stringByReplacingOccurrencesOfString:@"," withString:@"" options:0 range:myRange ];
}

// basic soql query for this object, returns all fields
- (NSString *) getSimpleSoqlQuery 
{
	NSString *ret = @"Select ";	
	ret = [ret stringByAppendingString: [self getComaSepFieldList]];
	return  [ret stringByAppendingFormat:@" from %@", [self name] ];	
}


@end
