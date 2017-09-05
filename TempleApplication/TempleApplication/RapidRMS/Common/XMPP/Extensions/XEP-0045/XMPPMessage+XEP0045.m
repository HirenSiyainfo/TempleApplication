#import "XMPPMessage+XEP0045.h"
#import "NSXMLElement+XMPP.h"


@implementation XMPPMessage(XEP0045)

- (BOOL)isGroupChatMessage
{
	return [[self attributeForName:@"type"].stringValue isEqualToString:@"groupchat"];
}

- (BOOL)isGroupChatMessageWithBody
{
	if (self.groupChatMessage)
	{
		NSString *body = [self elementForName:@"body"].stringValue;
		
		return (body.length > 0);
	}
	
	return NO;
}

- (BOOL)isGroupChatMessageWithSubject
{
    if (self.groupChatMessage)
	{
        NSString *subject = [self elementForName:@"subject"].stringValue;

		return (subject.length > 0);
    }

    return NO;
}

@end
