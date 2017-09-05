#import <Foundation/Foundation.h>
#import "XMPPPresence.h"

@interface XMPPPresence (XEP_0172)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *nick;

@end
