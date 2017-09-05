#import "XMPPIQ.h"

@interface XMPPIQ (XEP_0066)

+ (XMPPIQ *)outOfBandDataRequestTo:(XMPPJID *)jid
						 elementID:(NSString *)eid
							   URL:(NSURL *)URL
							  desc:(NSString *)dec;

+ (XMPPIQ *)outOfBandDataRequestTo:(XMPPJID *)jid
						 elementID:(NSString *)eid
							   URI:(NSString *)URI
							  desc:(NSString *)dec;


- (instancetype)initOutOfBandDataRequestTo:(XMPPJID *)jid
					   elementID:(NSString *)eid
							 URL:(NSURL *)URL
							desc:(NSString *)dec;

- (instancetype)initOutOfBandDataRequestTo:(XMPPJID *)jid
					   elementID:(NSString *)eid
							 URI:(NSString *)URI
							desc:(NSString *)dec;

- (void)addOutOfBandURL:(NSURL *)URL desc:(NSString *)desc;
- (void)addOutOfBandURI:(NSString *)URI desc:(NSString *)desc;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) XMPPIQ *generateOutOfBandDataSuccessResponse;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) XMPPIQ *generateOutOfBandDataFailureResponse;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) XMPPIQ *generateOutOfBandDataRejectResponse;

@property (NS_NONATOMIC_IOSONLY, getter=isOutOfBandDataRequest, readonly) BOOL outOfBandDataRequest;
@property (NS_NONATOMIC_IOSONLY, getter=isOutOfBandDataFailureResponse, readonly) BOOL outOfBandDataFailureResponse;
@property (NS_NONATOMIC_IOSONLY, getter=isOutOfBandDataRejectResponse, readonly) BOOL outOfBandDataRejectResponse;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasOutOfBandData;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *outOfBandURL;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *outOfBandURI;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *outOfBandDesc;

@end
