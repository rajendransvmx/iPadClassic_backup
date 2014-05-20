//
//  CustomLibXml.h
//  iService
//
//  Created by Samman on 28/08/12.
//
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>
#import <libxml/xmlstring.h>
#import <malloc/malloc.h>

malloc_zone_t * zonePtr;

// Custom Initialize must be called only once, before any other xmllib methods are called
void custom_initialize();
// Custom create should be called everytime a malloc zone needs to be allocated
void custom_create();
// Custom destroy should be called everytime a malloc zone has to be destroyed
void custom_destroy();

void custom_xmlFreeFunc (void * mem);
void * custom_xmlMallocFunc (size_t size);
void * custom_xmlReallocFunc (void * mem, size_t size);
char * custom_xmlStrdupFunc (const char * str);

@interface CustomLibXml : NSObject

@end
