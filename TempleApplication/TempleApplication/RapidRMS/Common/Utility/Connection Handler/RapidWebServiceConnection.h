
#import <Foundation/Foundation.h>
#import "AppDelegate.h"

typedef void (^CompletionHandler)(id response, NSError *error);
typedef void (^AsyncCompletionHandler)(id response, NSError *error);
typedef void (^ProgressHandler)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

@interface RapidWebServiceConnection : NSObject
{

}
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;

- (instancetype)initWithRequest:(NSString*)strURL actionName:(NSString *)aName params:(NSDictionary*)params completionHandler:(CompletionHandler)completionHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithAsyncRequest:(NSString*)strURL actionName:(NSString *)aName params:(NSDictionary*)params asyncCompletionHandler:(AsyncCompletionHandler)asyncCompletionHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithAsyncRequestURL:(NSString*)strURL withDetailValues:(NSString *)detail asyncCompletionHandler:(AsyncCompletionHandler)asyncCompletionHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithAsyncRequest:(NSString*)strURL actionName:(NSString *)aName params:(NSDictionary*)params asyncCompletionHandler:(AsyncCompletionHandler)asyncCompletionHandler progressHandler:(ProgressHandler)progressHandler NS_DESIGNATED_INITIALIZER;

@end
