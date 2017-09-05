#import <Foundation/Foundation.h>
#import "XMPPMessage.h"

@interface XMPPMessage (XEP_0172)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *nick;

@end
