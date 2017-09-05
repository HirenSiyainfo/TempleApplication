#import <Foundation/Foundation.h>
#import "XMPPSASLAuthentication.h"
#import "XMPPStream.h"


@interface XMPPDeprecatedPlainAuthentication : NSObject <XMPPSASLAuthentication>

// This class implements the XMPPSASLAuthentication protocol.
// 
// See XMPPSASLAuthentication.h for more information.

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPStream (XMPPDeprecatedPlainAuthentication)

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL supportsDeprecatedPlainAuthentication;

@end
