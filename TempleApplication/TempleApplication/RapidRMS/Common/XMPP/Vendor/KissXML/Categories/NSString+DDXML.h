#import <Foundation/Foundation.h>
#import <libxml/tree.h>


@interface NSString (DDXML)

/**
 * xmlChar - A basic replacement for char, a byte in a UTF-8 encoded string.
**/
@property (NS_NONATOMIC_IOSONLY, readonly) const xmlChar *xmlChar;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringByTrimming;

@end
