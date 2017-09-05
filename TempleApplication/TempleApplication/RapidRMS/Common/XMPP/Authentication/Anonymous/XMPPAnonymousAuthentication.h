#import <Foundation/Foundation.h>
#import "XMPPSASLAuthentication.h"
#import "XMPP.h"


@interface XMPPAnonymousAuthentication : NSObject <XMPPSASLAuthentication>

- (instancetype)initWithStream:(XMPPStream *)stream NS_DESIGNATED_INITIALIZER;

// This class implements the XMPPSASLAuthentication protocol.
// 
// See XMPPSASLAuthentication.h for more information.

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPStream (XMPPAnonymousAuthentication)

/**
 * Returns whether or not the server support anonymous authentication.
 * 
 * This information is available after the stream is connected.
 * In other words, after the delegate has received xmppStreamDidConnect: notification.
**/
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL supportsAnonymousAuthentication;

/**
 * This method attempts to start the anonymous authentication process.
 * 
 * This method is asynchronous.
 * 
 * If there is something immediately wrong,
 * such as the stream is not connected or doesn't support anonymous authentication,
 * the method will return NO and set the error.
 * Otherwise the delegate callbacks are used to communicate auth success or failure.
 * 
 * @see xmppStreamDidAuthenticate:
 * @see xmppStream:didNotAuthenticate:
**/
- (BOOL)authenticateAnonymously:(NSError **)errPtr;

@end
