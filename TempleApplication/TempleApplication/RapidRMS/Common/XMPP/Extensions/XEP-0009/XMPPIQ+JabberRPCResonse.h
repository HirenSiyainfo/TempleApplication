//
//  XMPPIQ+JabberRPCResonse.h
//  XEP-0009
//
//  Created by Eric Chamberlain on 5/25/10.
//

#import "XMPPIQ.h"

typedef NS_ENUM(unsigned int, JabberRPCElementType) {
    JabberRPCElementTypeArray,
    JabberRPCElementTypeDictionary,
    JabberRPCElementTypeMember,
    JabberRPCElementTypeName,
    JabberRPCElementTypeInteger,
    JabberRPCElementTypeDouble,
    JabberRPCElementTypeBoolean,
    JabberRPCElementTypeString,
    JabberRPCElementTypeDate,
    JabberRPCElementTypeData
};


@interface XMPPIQ(JabberRPCResonse)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) DDXMLElement *methodResponseElement;

// is this a Jabber RPC method response
@property (NS_NONATOMIC_IOSONLY, getter=isMethodResponse, readonly) BOOL methodResponse;

@property (NS_NONATOMIC_IOSONLY, getter=isFault, readonly) BOOL fault;

@property (NS_NONATOMIC_IOSONLY, getter=isJabberRPC, readonly) BOOL jabberRPC;

-(id)methodResponse:(NSError **)error;

-(id)objectFromElement:(NSXMLElement *)param;


#pragma mark -

-(NSArray *)parseArray:(NSXMLElement *)arrayElement;

-(NSDictionary *)parseStruct:(NSXMLElement *)structElement;

-(NSDictionary *)parseMember:(NSXMLElement *)memberElement;

#pragma mark -

- (NSDate *)parseDateString: (NSString *)dateString withFormat: (NSString *)format;

#pragma mark -

- (NSNumber *)parseInteger: (NSString *)value;

- (NSNumber *)parseDouble: (NSString *)value;

- (NSNumber *)parseBoolean: (NSString *)value;

- (NSString *)parseString: (NSString *)value;

- (NSDate *)parseDate: (NSString *)value;

- (NSData *)parseData: (NSString *)value;

@end
