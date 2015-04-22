// Copyright (c) 2010 Ron Hess
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

#import "ZKRelatedList.h"
#import "ZKDescribeLayout.h"
#import "ZKRelatedListColumn.h"
#import "ZKDescribeLayoutSection.h"
#import "ZKDescribeLayoutButtonSection.h"
#import "ZKParser.h"
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

/*
 * sample code to dump layouts to debug window
 *
 *
for ( ZKDescribeLayout *layout in layouts ) {
	SMLog(kLogLevelVerbose,@"layout ID %@",[layout Id]);
	
	ZKDescribeLayoutButtonSection *lbs = [layout buttonLayoutSection];
	for (ZKDescribeLayoutButton *bl in [lbs detailButtons]) {
		SMLog(kLogLevelVerbose,@"button  %@ %@ %@",[bl name],[bl label],[bl custom]?@"true":@"false");
	}
	
	for (ZKDescribeLayoutSection *section in [layout detailLayoutSections]) {
		
		SMLog(kLogLevelVerbose,@"detail section %@",[section heading]);
		SMLog(kLogLevelVerbose,@"columns %d, rows %d",[section columns], [section rows]);
		
		for( ZKDescribeLayoutRow *dlr in [section layoutRows]) {
			SMLog(kLogLevelVerbose,@"num items %d",[dlr numItems]);
			for ( ZKDescribeLayoutItem *item in [dlr layoutItems] ) {
				
				BOOL ph = [item placeholder];
				SMLog(kLogLevelVerbose,@"placeholder %@", ph?@"true":@"false");
				
				if ( !ph ) { // no label on placeholders
					SMLog(kLogLevelVerbose,@"label %@",[item label]);
				}
				// may have a list of layout components
				for (ZKDescribeLayoutComponent *comp in [item layoutComponents]) {
					if ( [[comp type] isEqualToString:@"Field"] ){
						SMLog(kLogLevelVerbose,@"field : ",[comp value]);
					}
				}	
			}
		}
	}
	
	for (ZKDescribeLayoutSection *edit in [layout editLayoutSections]) {
		SMLog(kLogLevelVerbose,@"edit layout section %@",[edit heading]);
	}
	
}*/



@implementation ZKDescribeLayout

-(void)dealloc {
	buttonLayoutSection = nil;
	detailLayoutSections = nil;
	editLayoutSections = nil;
    relatedLists = nil;
}

-(NSString *) Id {
	return [self string:@"id"];
}

// this is a single section, not a list, it holds a list of buttons
- (ZKDescribeLayoutButtonSection *) buttonLayoutSection 
{
	if (buttonLayoutSection == nil) {
		ZKElement *bNode = [node childElement:@"buttonLayout"];
		buttonLayoutSection = [[ZKDescribeLayoutButtonSection alloc] initWithXmlElement:bNode];
	}
	return buttonLayoutSection;
}

- (NSArray *) detailLayoutSections  {
	if (detailLayoutSections == nil)
		detailLayoutSections = [self complexTypeArrayFromElements:@"detailLayoutSections" cls:[ZKDescribeLayoutSection class]];
	return detailLayoutSections;	
}

- (NSArray *) editLayoutSections {
	if (editLayoutSections == nil) 
		editLayoutSections = [self complexTypeArrayFromElements:@"editLayoutSections" cls:[ZKDescribeLayoutSection class]];
	return editLayoutSections;	
}

- (NSArray *) relatedLists {
	if (relatedLists == nil) 
		relatedLists = [self complexTypeArrayFromElements:@"relatedLists" cls:[ZKRelatedList class]];
	return relatedLists;	
}

@end
