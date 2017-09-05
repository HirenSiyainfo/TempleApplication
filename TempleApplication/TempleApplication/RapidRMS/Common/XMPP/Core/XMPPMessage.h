#import <Foundation/Foundation.h>
#import "XMPPElement.h"

/**
 * The XMPPMessage class represents a <message> element.
 * It extends XMPPElement, which in turn extends NSXMLElement.
 * All <message> elements that go in and out of the
 * xmpp stream will automatically be converted to XMPPMessage objects.
 * 
 * This class exists to provide developers an easy way to add functionality to message processing.
 * Simply add your own category to XMPPMessage to extend it with your own custom methods.
**/

@interface XMPPMessage : XMPPElement

// Converts an NSXMLElement to an XMPPMessage element in place (no memory allocations or copying)
+ (XMPPMessage *)messageFromElement:(NSXMLElement *)element;

+ (XMPPMessage *)message;
+ (XMPPMessage *)messageWithType:(NSString *)type;
+ (XMPPMessage *)messageWithType:(NSString *)type to:(XMPPJID *)to;
+ (XMPPMessage *)messageWithType:(NSString *)type to:(XMPPJID *)jid elementID:(NSString *)eid;
+ (XMPPMessage *)messageWithType:(NSString *)type to:(XMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement *)childElement;
+ (XMPPMessage *)messageWithType:(NSString *)type elementID:(NSString *)eid;
+ (XMPPMessage *)messageWithType:(NSString *)type elementID:(NSString *)eid child:(NSXMLElement *)childElement;
+ (XMPPMessage *)messageWithType:(NSString *)type child:(NSXMLElement *)childElement;

- (instancetype)init;
- (instancetype)initWithType:(NSString *)type;
- (instancetype)initWithType:(NSString *)type to:(XMPPJID *)to;
- (instancetype)initWithType:(NSString *)type to:(XMPPJID *)jid elementID:(NSString *)eid;
- (instancetype)initWithType:(NSString *)type to:(XMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement *)childElement NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithType:(NSString *)type elementID:(NSString *)eid;
- (instancetype)initWithType:(NSString *)type elementID:(NSString *)eid child:(NSXMLElement *)childElement;
- (instancetype)initWithType:(NSString *)type child:(NSXMLElement *)childElement;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *type;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *subject;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *body;
- (NSString *)bodyForLanguage:(NSString *)language;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *thread;

- (void)addSubject:(NSString *)subject;
- (void)addBody:(NSString *)body;
- (void)addBody:(NSString *)body withLanguage:(NSString *)language;
- (void)addThread:(NSString *)thread;

@property (NS_NONATOMIC_IOSONLY, getter=isChatMessage, readonly) BOOL chatMessage;
@property (NS_NONATOMIC_IOSONLY, getter=isChatMessageWithBody, readonly) BOOL chatMessageWithBody;
@property (NS_NONATOMIC_IOSONLY, getter=isErrorMessage, readonly) BOOL isErrorMessage;
@property (NS_NONATOMIC_IOSONLY, getter=isMessageWithBody, readonly) BOOL messageWithBody;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSError *errorMessage;

@end
