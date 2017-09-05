#import <Foundation/Foundation.h>
#import "GCDMulticastDelegate.h"

@class XMPPStream;

/**
 * XMPPModule is the base class that all extensions/modules inherit.
 * They automatically get:
 * 
 * - A dispatch queue.
 * - A multicast delegate that automatically invokes added delegates.
 * 
 * The module also automatically registers/unregisters itself with the
 * xmpp stream during the activate/deactive methods.
**/
@interface XMPPModule : NSObject
{
	XMPPStream *xmppStream;

	dispatch_queue_t moduleQueue;
	void *moduleQueueTag;
	
	id multicastDelegate;
}

@property (readonly) dispatch_queue_t moduleQueue;
@property (readonly) void *moduleQueueTag;

@property (strong, readonly) XMPPStream *xmppStream;

- (instancetype)init;
- (instancetype)initWithDispatchQueue:(dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

- (BOOL)activate:(XMPPStream *)aXmppStream;
- (void)deactivate;

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *moduleName;

@end
