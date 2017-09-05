#import <Foundation/Foundation.h>
#import "XMPPMessage.h"


@interface XMPPMessage(XEP0045)

@property (NS_NONATOMIC_IOSONLY, getter=isGroupChatMessage, readonly) BOOL groupChatMessage;
@property (NS_NONATOMIC_IOSONLY, getter=isGroupChatMessageWithBody, readonly) BOOL groupChatMessageWithBody;
@property (NS_NONATOMIC_IOSONLY, getter=isGroupChatMessageWithSubject, readonly) BOOL groupChatMessageWithSubject;

@end
