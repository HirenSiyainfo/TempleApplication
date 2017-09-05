#import <Foundation/Foundation.h>
#import "XMPP.h"


@protocol XMPPResource <NSObject>
@required

@property (NS_NONATOMIC_IOSONLY, readonly, copy) XMPPJID *jid;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) XMPPPresence *presence;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate *presenceDate;

- (NSComparisonResult)compare:(id <XMPPResource>)another;

@end
