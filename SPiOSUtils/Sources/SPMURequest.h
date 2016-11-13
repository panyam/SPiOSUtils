
#import "SPMUFwdDefs.h"

@class SPMURequest;

typedef void (^SPMURequestHandler)(SPMURequest *request);
typedef void (^SPMURequestProgressHandler)(SPMURequest *request, NSData *data, long totalReceived, long totalBytes);

@interface SPMURequest : NSOperation <NSCopying>

+(SPMURequest *)withRequest:(NSURLRequest *)request;
+(SPMURequest *)withRequest:(NSURLRequest *)request
              withHandler:(SPMURequestHandler)requestHandler;
+(SPMURequest *)withRequest:(NSURLRequest *)request
              withHandler:(SPMURequestHandler)requestHandler
          progressHandler:(SPMURequestProgressHandler)progressHandler;

/**
 * Extra context associated with the request.
 */
@property (nonatomic, strong) id extraContext;

/**
 The request handler for caller to deal with returned value.
 */
@property (nonatomic, copy) SPMURequestHandler requestHandler;

/**
 The progress handler for caller to deal with progress. It needs server to support return total bytes. 
 */
@property (nonatomic, copy) SPMURequestProgressHandler progressHandler;

/**
 * Work in an incremental mode where the data is sent off to the `progressHandler` 
 * as it arrives so we are not storing it.  This is useful when the response data 
 * can be really large (eg downloading media) and it is better to handle the data 
 * and discard it rather than keep track of it all in memory and overwhelm the 
 * amount of device memory.
 * 
 * This will only take effect if a progressHandler is supplied and this property is true.
 */
@property (nonatomic) BOOL discardPreviousData;

// A flag to indicate the request need to be send again.
@property (nonatomic) BOOL resubmit;
@property (nonatomic, readonly) NSURLResponse *response;
@property (nonatomic, readonly) NSInteger responseStatusCode;
@property (nonatomic, readonly) NSMutableData *responseData;
@property (nonatomic, readonly) NSString *responseString;
@property (nonatomic, readonly) NSError *error;

+(NSOperationQueue *)defaultOperationQueue;

+(NSError *)requestCancelledError;

-(void)startAsynchronouslyInQueue:(NSOperationQueue *)queue;
-(void)startAsynchronously;
-(NSData *)startSynchronously;

-(void)cancel;

-(BOOL)shouldResubmit;
-(void)invokeHandler;

@end

