#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
@class SMAX_Debug_SMAX_Debug;
@interface SMAX_Debug_SMAX_Debug : NSObject {
	
/* elements */
	NSString * className;
	NSString * logMsg;
	NSString * logType;
	NSString * methodName;
	NSString * timeStamp;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (SMAX_Debug_SMAX_Debug *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * className;
@property (retain) NSString * logMsg;
@property (retain) NSString * logType;
@property (retain) NSString * methodName;
@property (retain) NSString * timeStamp;
/* attributes */
- (NSDictionary *)attributes;
@end
