#import <Foundation/Foundation.h>
#import "XMPPSASLAuthentication.h"
#import "XMPPStream.h"


@interface XMPPDigestMD5Authentication : NSObject <XMPPSASLAuthentication>

// This class implements the XMPPSASLAuthentication protocol.
// 
// See XMPPSASLAuthentication.h for more information.

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPStream (XMPPDigestMD5Authentication)

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL supportsDigestMD5Authentication;

@end
