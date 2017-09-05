#import <Foundation/Foundation.h>

@interface NSString (XEP_0106)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *jidEscapedString;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *jidUnescapedString;

@end
