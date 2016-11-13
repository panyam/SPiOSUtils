
#import "SPMobileUtils.h"

@interface SPMURequest()
{
    dispatch_semaphore_t flagsSemaphore;
}

//request and connection used to send HTTP communication.
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
//internal used flag to know this connection's invokeHandler has been called.
// If it's already been invoked, no need to invoke again, as notify will notice all listeners.
@property (nonatomic) BOOL handlerInvoked;
//Keeps track of the total bytes received for a particular response.
@property (nonatomic) long totalBytesReceived;
//The status of current operator. It will called by NSOperator return status.
@property (nonatomic) BOOL isRequestExecuting;
@property (nonatomic) BOOL isRequestFinished;
@property (nonatomic) BOOL isRequestCancelled;
//The operation queue it will executed
@property (nonatomic, weak) NSOperationQueue *operationQueue;
//Time to do performance trace
@property (nonatomic) NSTimeInterval timeAddIntoQueue;
@property (nonatomic) NSTimeInterval timeStartExecute;
@property (nonatomic) NSTimeInterval timeEndExecute;
//header files declare them as readonly, make a read-write property as private
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic) NSInteger responseStatusCode;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSError *error;

//Initiates a StreetHawk with a url request, request handler and progress handlers.
-(SPMURequest *)initWithRequest:(NSURLRequest *)request
               requestHandler:(SPMURequestHandler)requestHandler
              progressHandler:(SPMURequestProgressHandler)progressHandler;

//Make isRequestExecuting=NO, isRequestFinished=YES, and set KOV values.
-(void)markAsFinished;

@end

@implementation SPMURequest

@synthesize extraContext;
@synthesize requestHandler;
@synthesize progressHandler;
@synthesize discardPreviousData;
@synthesize response;
@synthesize responseStatusCode;
@synthesize responseData;
@synthesize error;

@synthesize request;
@synthesize connection;
@synthesize resubmit;
@synthesize handlerInvoked;
@synthesize totalBytesReceived;
@synthesize isRequestExecuting;
@synthesize isRequestFinished;
@synthesize isRequestCancelled;
@synthesize operationQueue;
@synthesize timeAddIntoQueue;
@synthesize timeStartExecute;
@synthesize timeEndExecute;

+(NSOperationQueue *)defaultOperationQueue
{
    static NSOperationQueue *sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = [[NSOperationQueue alloc] init];
        sharedQueue.maxConcurrentOperationCount = 3;
        sharedQueue.name = @"SPMURequestQueue";
    });
    return sharedQueue;
}

+(NSError *)requestCancelledError
{
    static NSError *error = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        error = [[NSError alloc] initWithDomain:(NSString *)SPMUErrorDomain
                                           code:INT_MIN
                                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Request cancelled by user", NSLocalizedDescriptionKey, nil]];
    });
    return error;
}

#pragma mark - life cycle

-(SPMURequest *)initWithRequest:(NSURLRequest *)request_
               requestHandler:(SPMURequestHandler)requestHandler_
              progressHandler:(SPMURequestProgressHandler)progressHandler_
{
    if ((self = [super init]))
    {
        self.request = request_;
        self.requestHandler = requestHandler_;
        self.progressHandler = progressHandler_;
        flagsSemaphore = dispatch_semaphore_create(1);
        self.operationQueue = nil;
        //clear newly created request's status
        [self resetRequest];
    }
    return self;
}

+(SPMURequest *)withRequest:(NSURLRequest *)request
{
    return [[[self class] alloc] initWithRequest:request
                                  requestHandler:nil progressHandler:nil];
}

+(SPMURequest *)withRequest:(NSURLRequest *)request
              withHandler:(SPMURequestHandler)requestHandler
{
    return [[[self class] alloc] initWithRequest:request
                                  requestHandler:requestHandler progressHandler:nil];
}

+(SPMURequest *)withRequest:(NSURLRequest *)request
              withHandler:(SPMURequestHandler)requestHandler
          progressHandler:(SPMURequestProgressHandler)progressHandler
{
    return [[[self class] alloc] initWithRequest:request
                                  requestHandler:requestHandler
                                 progressHandler:progressHandler];
}

-(id)copyWithZone:(NSZone *)zone
{
    SPMURequest *copy = [[[self class] allocWithZone:zone] initWithRequest:self.request requestHandler:self.requestHandler progressHandler:self.progressHandler];
    copy.operationQueue = self.operationQueue;
    copy.discardPreviousData = self.discardPreviousData;
    copy.totalBytesReceived = self.totalBytesReceived;
    //other such as response***, result*** cannot copy here, because the copied request will start again.
    return copy;
}

-(void)resetRequest
{
    self.connection = nil;
    self.error = nil;
    self.resubmit = NO;
    self.handlerInvoked = NO;
    self.response = nil;
    self.responseStatusCode = 0;
    self.responseData = [NSMutableData data];
    self.totalBytesReceived = 0;
    self.isRequestExecuting = NO;
    self.isRequestFinished = NO;
    self.isRequestCancelled = NO;
}

-(void)dealloc
{
    [self resetRequest];
    self.extraContext = nil;
    self.requestHandler = nil;
    self.progressHandler = nil;
    self.request = nil;
    flagsSemaphore = 0;
    self.operationQueue = nil;
}

#pragma mark - start/cancel functions

-(void)startAsynchronously
{
    [self startAsynchronouslyInQueue:nil];
}

-(void)startAsynchronouslyInQueue:(NSOperationQueue *)queue
{
    [self resetRequest];
    if (queue == nil)
        queue = self.class.defaultOperationQueue;
    self.timeAddIntoQueue = [NSDate timeIntervalSinceReferenceDate];
    self.operationQueue = queue;    
    [queue addOperation:self];  //it's added into queue, but not start until queue start it. The start function is called by queue.
}

-(NSData *)startSynchronously
{
    NSAssert(self.requestHandler == nil, @"Request handler does not work in synchronous mode.");
    self.isRequestExecuting = YES;
    self.connection = nil;
    //directly send connection request, and finish in this method. 
    NSURLResponse *response_ = nil;
    NSError *error_ = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:self.request returningResponse:&response_ error:&error_];
    self.response = response_;
    self.error = error_;
    self.responseData = [NSMutableData dataWithData:data];
    [self markAsFinishedAndInvokeHandler];
    return data;
}

-(void)cancel
{
    [self cancelSilently];
    [self markAsFinishedAndInvokeHandler];
}

//This will cancel this request but in silent mode - ie the request will not be released and the request handler will NOT be invoked.
//This for cases when a request needs to be cancelled because other requests have been started recursively to continue the work of a previous request and it no longer makes sense to keep the previous request in the operation queue.
-(BOOL)cancelSilently
{
    dispatch_semaphore_wait(flagsSemaphore, DISPATCH_TIME_FOREVER);
    if (self.isRequestCancelled)
    {
        dispatch_semaphore_signal(flagsSemaphore);
        return NO;
    }
    else
    {
        self.isRequestCancelled = YES;
        dispatch_semaphore_signal(flagsSemaphore);
    }
    [self.connection cancel];
    [super cancel];
    return YES;
}

#pragma mark - override NSOperation functions

//called by NSOperationQueue to start the operation inside it. 
-(void)start
{
    NSLog(@"Starting Request: %@", self.request.URL);
    if (!self.isRequestCancelled && !self.isRequestExecuting) //only start if neither executing nor cancelled
    {
        [self willChangeValueForKey:@"isExecuting"];
        self.isRequestExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
        self.timeStartExecute = [NSDate timeIntervalSinceReferenceDate];
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
        [self.connection start];
    }
    // If this request is not running in main thread, keep its run loop
    // until it's finished. Otherwise the run loop will disappear and it
    // cannot run successfully.
    if (![NSThread isMainThread])
    {
        while(!self.isRequestFinished)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

//Asynchronous request is concurrent, as operation queue max concurrent number = 3. Synchronous request not need this override.
-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isCancelled
{
    return self.isRequestCancelled;
}

-(BOOL)isExecuting
{
    return self.isRequestExecuting;
}

-(BOOL)isFinished
{
    return self.isRequestFinished;
}

-(void)markAsFinished
{
    self.timeEndExecute = [NSDate timeIntervalSinceReferenceDate];
    [self willChangeValueForKey:@"isExecuting"];
    self.isRequestExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.isRequestFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

-(BOOL)shouldResubmit
{
    return resubmit;
}

#pragma mark - result

-(NSString *)responseString
{
    if (self.discardPreviousData && self.progressHandler != nil)  //it's for large media download, the data is not cache in memory, so cannot create responding string.
        return @"";
    if (self.responseData != nil)
        return [[NSString alloc] initWithData:self.responseData encoding:NSASCIIStringEncoding];
    else
        return @"";
}

#pragma mark - UIConnection delegate handlers

-(void)markAsFinishedAndInvokeHandler
{
    [self markAsFinished];
    dispatch_semaphore_wait(flagsSemaphore, DISPATCH_TIME_FOREVER);
    if (self.handlerInvoked)
    {
        dispatch_semaphore_signal(flagsSemaphore);
        return ;
    }
    else
    {
        self.handlerInvoked = YES;
        dispatch_semaphore_signal(flagsSemaphore);
    }
    [self invokeHandler];
}

//Mark status to be finished, call requestHandler and release self.
-(void)invokeHandler
{
    //if need resubmit, copy self to make a fresh new one, and send again.
    if (self.shouldResubmit)
    {
        SPMURequest *new_request = [self copy];
        [new_request startAsynchronously];
    }
    else
    {
        // TODO: see if there any errors
        if (self.error == nil && self.isRequestCancelled)
            self.error = [SPMURequest requestCancelledError];
        //finish handling
        if (self.requestHandler)
            self.requestHandler(self);
    }
}

- (void)connection:(NSURLConnection *)connection_ didFailWithError:(NSError *)error_
{
    if (!self.isRequestCancelled)
    {
        self.error = error_;
        self.responseData = nil;
        [self markAsFinishedAndInvokeHandler];
    }
}

- (void)connection:(NSURLConnection *)connection_ didReceiveResponse:(NSURLResponse *)response_
{
    if (!self.isRequestCancelled)
    {
        self.totalBytesReceived = 0;
        self.response = response_;
        responseStatusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (self.responseStatusCode / 100 == 2)  // 2XX status codes are ok
        {
            // all good
        }
        else if (self.responseStatusCode >= 500)
        {
            NSString *message = [NSString stringWithFormat:@"System Error %ld", (long)self.responseStatusCode];
            self.error = [NSError errorWithDomain:(NSString *)SPMUSystemErrorDomain
                                             code:self.responseStatusCode
                                         userInfo:[NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey]];
        }
        else if (self.responseStatusCode >= 400)
        {
            NSString *message = [NSString stringWithFormat:@"User Error %ld", (long)self.responseStatusCode];
            self.error = [NSError errorWithDomain:(NSString *)SPMUUserErrorDomain
                                             code:self.responseStatusCode
                                         userInfo:[NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey]];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!self.isRequestCancelled)
    {
        if (self.progressHandler == nil && !self.discardPreviousData)  //not for download large media. 
        {
            [self.responseData appendData:data];
        }
        self.totalBytesReceived += data.length;
        if (self.progressHandler)
        {
            id content_length = [[((NSHTTPURLResponse *)self.response) allHeaderFields] objectForKey:@"Content-Length"];
            long totalBytes = 0;
            if (content_length)
            {
                if ([content_length isKindOfClass:[NSNumber class]])
                {
                    totalBytes =  [content_length longValue];
                }
                else if ([content_length isKindOfClass:[NSString class]])
                {
                    totalBytes = [[[[NSNumberFormatter alloc] init] numberFromString:content_length] longValue];
                }
            }
            self.progressHandler(self, data, self.totalBytesReceived, totalBytes);
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection_
{
    if (!self.isRequestCancelled)
    {
        [self markAsFinishedAndInvokeHandler];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection_ willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[cachedResponse response];
    // Look up the cache policy used in our request
    if(self.request.cachePolicy == NSURLRequestUseProtocolCachePolicy)
    {
        NSDictionary *headers = [httpResponse allHeaderFields];
        NSString *cacheControl = [headers valueForKey:@"Cache-Control"];
        NSString *expires = [headers valueForKey:@"Expires"];
        if((cacheControl == nil) && (expires == nil))
        {
            return nil; // don't cache this
        }
    }
    return cachedResponse;
}

/**
 * Overridden to prevent webkit from managing the sessionid cookie.
 */
-(NSURLRequest *)connection:(NSURLConnection *)connection_ willSendRequest:(NSURLRequest *)request_ redirectResponse:(NSURLResponse *)response
{
    return request_;
}

@end
