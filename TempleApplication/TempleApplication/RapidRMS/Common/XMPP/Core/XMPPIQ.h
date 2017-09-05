#import <Foundation/Foundation.h>
#import "XMPPElement.h"

/**
 * The XMPPIQ class represents an <iq> element.
 * It extends XMPPElement, which in turn extends NSXMLElement.
 * All <iq> elements that go in and out of the
 * xmpp stream will automatically be converted to XMPPIQ objects.
 * 
 * This class exists to provide developers an easy way to add functionality to IQ processing.
 * Simply add your own category to XMPPIQ to extend it with your own custom methods.
**/

@interface XMPPIQ : XMPPElement

/**
 * Converts an NSXMLElement to an XMPPIQ element in place (no memory allocations or copying)
**/
+ (XMPPIQ *)iqFromElement:(NSXMLElement *)element;

/**
 * Creates and returns a new autoreleased XMPPIQ element.
 * If the type or elementID parameters are nil, those attributes will not be added.
**/
+ (XMPPIQ *)iq;
+ (XMPPIQ *)iqWithType:(NSString *)type;
+ (XMPPIQ *)iqWithType:(NSString *)type to:(XMPPJID *)jid;
+ (XMPPIQ *)iqWithType:(NSString *)type to:(XMPPJID *)jid elementID:(NSString *)eid;
+ (XMPPIQ *)iqWithType:(NSString *)type to:(XMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement *)childElement;
+ (XMPPIQ *)iqWithType:(NSString *)type elementID:(NSString *)eid;
+ (XMPPIQ *)iqWithType:(NSString *)type elementID:(NSString *)eid child:(NSXMLElement *)childElement;
+ (XMPPIQ *)iqWithType:(NSString *)type child:(NSXMLElement *)childElement;

/**
 * Creates and returns a new XMPPIQ element.
 * If the type or elementID parameters are nil, those attributes will not be added.
**/
- (instancetype)init;
- (instancetype)initWithType:(NSString *)type;
- (instancetype)initWithType:(NSString *)type to:(XMPPJID *)jid;
- (instancetype)initWithType:(NSString *)type to:(XMPPJID *)jid elementID:(NSString *)eid;
- (instancetype)initWithType:(NSString *)type to:(XMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement *)childElement NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithType:(NSString *)type elementID:(NSString *)eid;
- (instancetype)initWithType:(NSString *)type elementID:(NSString *)eid child:(NSXMLElement *)childElement;
- (instancetype)initWithType:(NSString *)type child:(NSXMLElement *)childElement;

/**
 * Returns the type attribute of the IQ.
 * According to the XMPP protocol, the type should be one of 'get', 'set', 'result' or 'error'.
 * 
 * This method converts the attribute to lowercase so
 * case-sensitive string comparisons are safe (regardless of server treatment).
**/
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *type;

/**
 * Convenience methods for determining the IQ type.
**/
@property (NS_NONATOMIC_IOSONLY, getter=isGetIQ, readonly) BOOL getIQ;
@property (NS_NONATOMIC_IOSONLY, getter=isSetIQ, readonly) BOOL setIQ;
@property (NS_NONATOMIC_IOSONLY, getter=isResultIQ, readonly) BOOL resultIQ;
@property (NS_NONATOMIC_IOSONLY, getter=isErrorIQ, readonly) BOOL errorIQ;

/**
 * Convenience method for determining if the IQ is of type 'get' or 'set'.
**/
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL requiresResponse;

/**
 * The XMPP RFC has various rules for the number of child elements an IQ is allowed to have:
 * 
 * - An IQ stanza of type "get" or "set" MUST contain one and only one child element.
 * - An IQ stanza of type "result" MUST include zero or one child elements.
 * - An IQ stanza of type "error" SHOULD include the child element contained in the
 *   associated "get" or "set" and MUST include an <error/> child.
 * 
 * The childElement returns the single non-error element, if one exists, or nil.
 * The childErrorElement returns the error element, if one exists, or nil.
**/
@property (NS_NONATOMIC_IOSONLY, readonly, copy) DDXMLElement *childElement;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) DDXMLElement *childErrorElement;

@end
