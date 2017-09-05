
#import "RapidWebServiceConnection.h"
#import "RmsDbController.h"

typedef NS_ENUM(NSInteger, ContentType) {
    ContentTypeOther,
    ContentTypeXML,
    ContentTypeJason,
};

@interface RapidWebServiceConnection ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate> {
    NSMutableData *responseData;
    NSString *methodName;
    CompletionHandler _completionHandler;
    AsyncCompletionHandler _asyncCompletionHandler;
    ProgressHandler _progressHandler;
    ContentType contentType;
}

@property (nonatomic) NSURLSession *session;
//@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation RapidWebServiceConnection

#pragma mark - Defualt Service Call

- (instancetype)initWithRequest:(NSString*)strURL actionName:(NSString *)aName params:(NSDictionary*)params completionHandler:(CompletionHandler)completionHandler
{
    self = [super init];
    if (!self) {
        return self;
    }
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    // Create Session Configuration Object
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Configure Class Elements
    [self configureElements:aName completionHandler:completionHandler asyncCompletionHandler:nil progressHandler:nil];

    // Create Url Request
    NSMutableURLRequest *request = [self createUrlRequest:aName strURL:strURL params:params];
    
    // Create Session From Session Configuration Object
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Check Content Type & Handle Response
        [self setContentType:response];
        [self handleResponseFromData:data withError:error];
    }] resume];
    return self;
}

#pragma mark - Background Service Call

- (instancetype)initWithAsyncRequest:(NSString*)strURL actionName:(NSString *)aName params:(NSDictionary*)params asyncCompletionHandler:(AsyncCompletionHandler)asyncCompletionHandler
{
    self = [super init];
    if (!self) {
        return self;
    }

    self.rmsDbController = [RmsDbController sharedRmsDbController];

    // Create Background Session
    self.session = [self backgroundSession];
    
    // Configure Class Elements
    [self configureElements:aName completionHandler:nil asyncCompletionHandler:asyncCompletionHandler progressHandler:nil];

    // Create Url Request
    NSMutableURLRequest *request = [self createUrlRequest:aName strURL:strURL params:params];
    
    // Download Task
    [self downloadTaskWithRequest:request];
    return self;
}

- (instancetype)initWithAsyncRequestURL:(NSString*)strURL withDetailValues:(NSString *)detail asyncCompletionHandler:(AsyncCompletionHandler)asyncCompletionHandler
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    // Create Background Session
    self.session = [self backgroundSession];
    
    // Configure Class Elements
    [self configureElements:nil completionHandler:nil asyncCompletionHandler:asyncCompletionHandler progressHandler:nil];
    
    // Create Url Request
    NSMutableURLRequest *request = [self createAsyncRequest:strURL detail:detail];
    
    // Download Task
    [self downloadTaskWithRequest:request];
    return self;
}

- (instancetype)initWithAsyncRequest:(NSString*)strURL actionName:(NSString *)aName params:(NSDictionary*)params asyncCompletionHandler:(AsyncCompletionHandler)asyncCompletionHandler progressHandler:(ProgressHandler)progressHandler
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    // Create Background Session
    self.session = [self backgroundSession];

    // Configure Class Elements
    [self configureElements:aName completionHandler:nil asyncCompletionHandler:asyncCompletionHandler progressHandler:progressHandler];

    // Create Url Request
    NSMutableURLRequest *request = [self createUrlRequest:aName strURL:strURL params:params];
    
    // Download Task
    [self downloadTaskWithRequest:request];
    return self;
}

- (void)configureElements:(NSString *)aName completionHandler:(CompletionHandler)completionHandler asyncCompletionHandler:(AsyncCompletionHandler)asyncCompletionHandler progressHandler:(ProgressHandler)progressHandler
{
    methodName = aName;
    _completionHandler = completionHandler;
    _asyncCompletionHandler = asyncCompletionHandler;
    _progressHandler = progressHandler;
}

- (void)downloadTaskWithRequest:(NSMutableURLRequest *)request
{
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    responseData = [data mutableCopy];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // Download Progress
    if (_progressHandler) {
        _progressHandler (bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    [self setContentType:task.response];
    [self handleAsyncResponseWithError:error];
}

#pragma mark - Set Content Type

- (void)setContentType:(NSURLResponse *)response
{
    NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
    NSDictionary *headers = r.allHeaderFields;
    if (headers){
        if (headers[@"Content-Type"]) {
            [self contentTypeForConnection:headers[@"Content-Type"]];
        }
    }
}

-(void)contentTypeForConnection:(NSString *)checkContentType
{
    if ([checkContentType rangeOfString:@"json" options:NSCaseInsensitiveSearch].length > 0)
    {
        contentType = ContentTypeJason;
    }
    else if ([checkContentType rangeOfString:@"xml" options:NSCaseInsensitiveSearch].length > 0)
    {
        contentType = ContentTypeXML;
    }
    else
    {
        contentType = ContentTypeOther;
    }
}

#pragma mark - Create Background Session

- (NSURLSession *)backgroundSession {
    NSURLSession *session = nil;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.timeoutIntervalForRequest = 40;
    session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    return session;
}

#pragma mark - Create URL

- (NSString *)createURL:(NSString *)strURL aName:(NSString *)aName
{
    NSString *full_URL = @"";
    if (aName != nil) {
        full_URL = [NSString stringWithFormat:@"%@%@",strURL,aName];
        
    } else {
        full_URL = [NSString stringWithFormat:@"%@",strURL];
    }
    return full_URL;
}

#pragma mark - Create Request

- (NSMutableURLRequest *)createUrlRequest:(NSString *)aName strURL:(NSString *)strURL params:(NSDictionary *)params
{
    NSMutableURLRequest *request;
    NSString *full_URL;
    full_URL = [self createURL:strURL aName:aName];
    request = [self requestWithUrl:full_URL];
    if(params!=nil)
    {
        [self configureRequest:request params:params];
    }
    return request;
}

- (NSMutableURLRequest *)requestWithUrl:(NSString *)full_URL
{
    NSMutableURLRequest *request;
    request = [[NSMutableURLRequest alloc] initWithURL:
               [NSURL URLWithString:
                [full_URL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    return request;
}

#pragma mark - Configure Request

- (void)configureRequest:(NSMutableURLRequest *)request params:(NSDictionary *)params
{
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)requestData.length] forHTTPHeaderField:@"Content-Length"];
    if (![(self.rmsDbController.globalDict)[@"DBName"] isEqualToString:@""])
    {
        [request addValue:(self.rmsDbController.globalDict)[@"DBName"] forHTTPHeaderField:@"DBName-Header"];
    }
    request.HTTPBody = requestData;
}

- (NSMutableURLRequest *)createAsyncRequest:(NSString *)urlString detail:(NSString *)details
{
    NSData *postData=[details dataUsingEncoding:NSASCIIStringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)postData.length];
    NSMutableURLRequest *request = [self requestWithUrl:urlString];
    request.HTTPMethod = @"POST";
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];                                                 
    request.HTTPBody = postData;
    return request;
}

#pragma mark - Handle Response

- (void)handleAsyncResponseWithError:(NSError *)error
{
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    switch (contentType) {
        case ContentTypeOther:
            if (responseData == nil || responseData.length == 0) {
                _asyncCompletionHandler (nil,error);
            }
            break;
            
        case ContentTypeXML:
            _asyncCompletionHandler (responseString,error);
            break;
            
        case ContentTypeJason:
        {
            NSDictionary *responseDictionary = [self responseDictionaryFromData:responseData];
            _asyncCompletionHandler (responseDictionary,error);
        }
            break;
    }
}

- (void)handleResponseFromData:(NSData *)data withError:(NSError *)error
{
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    switch (contentType) {
        case ContentTypeOther:
            if (data == nil || data.length == 0) {
                _completionHandler (nil,error);
            }
            break;
            
        case ContentTypeXML:
            _completionHandler (responseString,error);
            break;
            
        case ContentTypeJason:
        {
            NSDictionary *responseDictionary = [self responseDictionaryFromData:data];
            _completionHandler (responseDictionary,error);
            
        }
            break;
    }
}

#pragma mark - Convert Response

- (NSDictionary *)responseDictionaryFromData:(NSData *)data
{
    NSMutableDictionary *dicResponse;
    if (data) {
        dicResponse = [self convertResponsetoDictionaryFromData:data];
    }
    NSString *actionNameResult = [NSString stringWithFormat:@"%@Result",methodName];
    NSDictionary *responseDictionary = [dicResponse valueForKey:actionNameResult];
    data = nil;
    return responseDictionary;
}

-(NSMutableDictionary *)convertResponsetoDictionaryFromData:(NSData *)data {
    NSMutableDictionary *dicResponse;
    NSString *actionNameResult = [NSString stringWithFormat:@"%@Result",methodName];
    dicResponse = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves) error:nil];
    if (dicResponse && [[dicResponse[actionNameResult] valueForKey:@"IsError"] integerValue] == -786) {
        dicResponse = nil;
    }
    return dicResponse;
}

@end