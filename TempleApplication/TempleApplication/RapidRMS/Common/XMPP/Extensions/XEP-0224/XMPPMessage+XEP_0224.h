#import "XMPPMessage.h"
#define XMLNS_ATTENTION  @"urn:xmpp:attention:0"

@interface XMPPMessage (XEP_0224) 
@property (NS_NONATOMIC_IOSONLY, getter=isHeadLineMessage, readonly) BOOL headLineMessage;
@property (NS_NONATOMIC_IOSONLY, getter=isAttentionMessage, readonly) BOOL attentionMessage;
@property (NS_NONATOMIC_IOSONLY, getter=isAttentionMessageWithBody, readonly) BOOL attentionMessageWithBody;
@end
