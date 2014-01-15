
#import "SPMobileUtils.h"

const NSString *SPMUErrorDomain = @"SPMUErrorDomain";
const NSString *SPMUUserErrorDomain = @"SPMUUserErrorDomain";
const NSString *SPMUSystemErrorDomain = @"SPMUSystemErrorDomain";

#pragma mark -
#pragma mark Map conversion met


/**
 * Wraps updates to the user defaults with a synchronized following all updates.
 */
void commitToUserDefaults(NSUserDefaults *userDefaults,
                          void (^updater_block)(NSUserDefaults *userDefaults))
{
    updater_block(userDefaults);
    [userDefaults synchronize];
}

/**
 * Wraps updates to the standard user defaults with a synchronized following all updates.
 */
void commitToStandardUserDefaults(void (^updater_block)(NSUserDefaults *userDefaults))
{
    commitToUserDefaults([NSUserDefaults standardUserDefaults], updater_block);
}

void presentError(NSError *error, BOOL announceNetworkError)
{
    if (error == nil)  //this checks error inside, so the caller can safely call it directly without checking error.
        return;
    
    dispatch_to_main(^{
        if (isNetworkError(error))
        {
            if (announceNetworkError)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network error" message:@"You are not currently connected to the internet. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
        }
        else
        {
            NSString *errorTitle = error.localizedFailureReason;
            if (errorTitle == nil || errorTitle.length == 0)
            {
                errorTitle = [error.domain isEqualToString:SPMUErrorDomain] ? @"Error" : error.domain;
            }
            NSString *errorMsg = (error.localizedDescription != nil && error.localizedDescription.length > 0) ? error.localizedDescription : @"No detail error message. Please contact App administrator.";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    });        
}

/**
 * Shows the error but rate limits "no network" errors to
 * the given number of seconds.
 */
void presentErrorRateLimited(NSError *error, double minseconds)
{
    static double lastShownTime = 0;
    BOOL show = [NSDate timeIntervalSinceReferenceDate] - lastShownTime > minseconds;
    if (show)
        lastShownTime = [NSDate timeIntervalSinceReferenceDate];
    presentError(error, show);
}

@implementation NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                               NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end

@implementation SPMUUtils

+(NSString *)relativeStringFromAbsoluteTime:(NSTimeInterval)timeInSeconds
{
    // THIS DOES NOT LOOK RIGHT BUT WORKS!
    NSTimeZone *utc = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDate *currentLocalTime = [NSDate date];
    NSTimeInterval timeZoneOffset = -[utc secondsFromGMTForDate:currentLocalTime];
    NSDate *currentTimeInUTC = [NSDate dateWithTimeInterval:timeZoneOffset sinceDate:currentLocalTime];
    NSTimeInterval currentTimeIntervalInUTC = [currentTimeInUTC timeIntervalSince1970];
    NSTimeInterval elapsedTimeInSeconds = currentTimeIntervalInUTC - timeInSeconds;
    NSTimeInterval elapsedTimeInMinutes = elapsedTimeInSeconds / 60;
    NSTimeInterval elapsedTimeInHours = elapsedTimeInSeconds / 3600;
    NSTimeInterval elapsedTimeInDays = elapsedTimeInSeconds / (24 * 3600);
    if (elapsedTimeInMinutes < 1.0)
    {
        return [NSString stringWithFormat:@"%d seconds ago", (int)elapsedTimeInSeconds];
    }
    else if (elapsedTimeInHours < 1.0)  // less than an hour
    {
        return [NSString stringWithFormat:@"%d minutes ago", (int)elapsedTimeInMinutes];
    }
    else if (elapsedTimeInDays < 1.0)  // less than a day
    {
        return [NSString stringWithFormat:@"%d hours ago", (int)elapsedTimeInHours];
    }
    else if (elapsedTimeInDays < 30)  // less than a day
    {
        return [NSString stringWithFormat:@"%d days ago", (int)(elapsedTimeInMinutes / (60 * 24))];
    }
    else    // more than a year
    {
        return [NSString stringWithFormat:@"%d years ago", (int)(elapsedTimeInSeconds / 365)];
    }
}

+(void)handleError:(NSError *)error
{
    if (error != nil)
    {
        ensure_main_queue(^{
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        });
    }
}

+(NSString *)imageUrlForTag:(NSString *)tag
{
    static NSDictionary *imageDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"http://t3.gstatic.com/images?q=tbn:ANd9GcQjIr7-Ku8UxRRSyK2MRagehy08ZxUZj7r1L6MPAmCVoF0GCXYYoMhLZA", @"starbucks coffee",
                     @"http://t2.gstatic.com/images?q=tbn:ANd9GcRZlm0JtNafwGrWa7V8co8jk4JK7qa8MDB2CkAT8y5FDuL_meT5MZuUQTpE7w", @"starbucks",
                     @"http://t2.gstatic.com/images?q=tbn:ANd9GcTFH4iqsoDJFg4uxnWgLYENZe2vJt9_mC9BoY9cJA0qYIQkwonWznkdcJE5", @"cafe",
                     @"http://t3.gstatic.com/images?q=tbn:ANd9GcSfA_gnUhJn-CvRNkgmVst6cXp3Holf9Lpb79N1IWMgvVi0OzRk4Jvum2wg", @"establishment",
                     @"http://t2.gstatic.com/images?q=tbn:ANd9GcTgZWniBW_vZAxGyWk2TImODXWkTqQf_GaLYLiaFxFgqORpzW1e7EyT7n6k", @"food",
                     @"http://t1.gstatic.com/images?q=tbn:ANd9GcTxMHxENwJtclDXgH-10BcoZ_fTHqHhwo9qMPfDdfOoFXy2Ah1oWfUcd0Wg", @"bakery",
                     @"http://t3.gstatic.com/images?q=tbn:ANd9GcRCMHXne3IH-5hMZKGupT0mn5mv1WVVk0kjU459Me7EZr-zzyrYw_pTo4c", @"store",
                     nil];
    });
    return [imageDict objectForKey:tag];
}

+(UIBarButtonItem *)plainBarButtonWithImage:(NSString *)image_name
                                 withTarget:(id)target
                               withSelector:(SEL)selector
{
    UIImage *image = [UIImage imageNamed:image_name];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage: [image stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0] forState:UIControlStateNormal];
    button.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [button addTarget:target action:selector
     forControlEvents:UIControlEventTouchUpInside];
    UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height) ];
    [v addSubview:button];
    return [[UIBarButtonItem alloc] initWithCustomView:v];
}

@end


/**
 * Ensures that the block runs in the main queue only.
 */
void ensure_main_queue(dispatch_block_t block)
{
    // TODO: need to find a way to check whether we are in main queue
    if (dispatch_get_current_queue() == dispatch_get_main_queue())
        block();
    else
        dispatch_to_main_queue(block);
}

/**
 * Ensures that the block runs in the main queue only if predicate is satisfied.
 */
void ensure_main_queue_if(BOOL predicate, dispatch_block_t block)
{
    if (predicate)
        ensure_main_queue(block);
}

/**
 * Dispatch to main queue unconditionally.
 */
void dispatch_to_main_queue(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}

float frand(float lower, float upper)
{
    float value = ((float)rand()) / ((float)RAND_MAX);
    return lower + (value * (upper - lower));
}

/**
 * Converts a float to a string and optionally rounding to the given decimal places.
 */
NSString *floatToStr(double value, int numPlaces, double accuracy)
{
    if (numPlaces == 0)
    {
        return [[NSNumber numberWithInt:(int)value] stringValue];
    }
    else if (numPlaces < 0)
    {
        return [[NSNumber numberWithDouble:value] stringValue];
    }
    else
    {
        if (accuracy > 0)
        {
            // so value will now be rounded TO the nearest multiple of "accuracy"
            float incr = value < 0 ? -0.5 : 0.5;
            value = (float)((int)(incr + value / accuracy)) * accuracy;
        }
        NSString *format = [NSString stringWithFormat:@"%%.%df", numPlaces];
        return [NSString stringWithFormat:format, value];
    }
}

UIView *loadFromNib(NSString *nibName, id owner)
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *views = [bundle loadNibNamed:nibName owner:owner options:nil];
    return (UIView *)[views objectAtIndex:0];
}

/**
 * Convert an ASCII encoded c-string to NSString.
 */
NSString *cstringToNSString(const char *input)
{
    if (input)
        return [NSString stringWithCString:(input) encoding:NSASCIIStringEncoding];
    else
        return @"";
}

/** 
 * Gets the user default that is to be used by the applications.
 * If a value is given then it is set as the user defaults for 
 * subsequent invocations.
 */
NSUserDefaults *getUserDefaults(NSUserDefaults *newvalue)
{
    static NSUserDefaults *defaultUserDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultUserDefaults = [NSUserDefaults standardUserDefaults];
    });
    if (newvalue)
    {
        defaultUserDefaults = newvalue;
    }
    return defaultUserDefaults;
}

/**
 * Helper function to create a url string starting at a given root URL
 * and a whole bunch of GET parameters.
 */
NSMutableString *makeBaseUrlString(NSString *baseURL, NSString *path)
{
    if (baseURL == nil)
    {
        return nil;
    }
    else
    {
        NSMutableString *url_string = [NSMutableString stringWithCapacity:128];
        [url_string appendString:baseURL];
        if (path && [path length] > 0)
        {        
            if ([url_string hasSuffix:@"/"])
            {
                [url_string deleteCharactersInRange:NSMakeRange(url_string.length-1, 1)]; //remove last "/"
            }
            if ([path characterAtIndex:0] == '/')
            {
                path = [path substringFromIndex:1];  //remove first "/"
            }
            if ([path rangeOfString:@"format=json"].location == NSNotFound)
            {
                NSString *sep;            
                if ([path rangeOfString:@"?"].location != NSNotFound)
                {
                    sep = @"&";
                }
                else if ([path hasSuffix:@"/"])
                {
                    sep = @"?";
                }
                else
                {
                    sep = @"/?";
                }
                [url_string appendFormat:@"/%@%@format=json", path, sep];
            }
            else
            {
                [url_string appendFormat:@"/%@", path];
            }        
        }
        return url_string;
    }
}

/**
 * Converts a byte array into an hex string.
 */
NSMutableString *dataToHexString(NSData *data)
{
    NSMutableString *str = [NSMutableString string];
    char *hexChars = "0123456789ABCDEF";
    const char *bytes = [data bytes];
    if (bytes)
    {
        for (int i = 0, count = [data length];i < count;i++)
        {
            unsigned currChar = ((unsigned char *)bytes)[i];
            [str appendFormat:@"%c%c", hexChars[currChar / 16], hexChars[currChar % 16]];
        }
    }
    return str;
}

/**
 * Splits a string with a delimiter and returns only non empty strings.  An
 * empty array is returned if no non-empty strings exist (instead of an
 * array with a single empty string).
 */
NSArray* splitStrings(NSString *input, NSString *delimiter)
{
    if (input != nil && input.length > 0)
    {
        return [input componentsSeparatedByString:delimiter];
    }
    else 
    {
        //if tagsStr is @"", should not return [@""], but nil is expected
        return nil;
    }
}

/**
 * Creates a new data formatter for system-wide date formatting in UTC.
 */
NSDateFormatter *createDateFormatter(NSString *dateFormat, NSTimeZone *timeZone)
{
    NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
    if (!dateFormat)
        dateFormat = DEFAULT_DATETIME_FORMAT;
    [date_formatter setDateFormat:dateFormat];
    if (!timeZone)
        timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [date_formatter setTimeZone:timeZone];
    return date_formatter;
}

/**
 * Returns the default date formatter with the local time zone.
 */
NSDateFormatter *localDateFormatter(void)
{
    static NSDateFormatter *date_formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        date_formatter = createDateFormatter(nil, [NSTimeZone localTimeZone]);
    });
    return date_formatter;
}

/**
 * Formats a date into a string in system-wide format.
 */
NSString *formatLocalDate(NSDate *date)
{
    NSDateFormatter *date_formatter = localDateFormatter();
    return [date_formatter stringFromDate:date];
}

NSDate *parseDate(NSString *input, int offsetSeconds)
{
    static dispatch_semaphore_t formatter_semaphore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter_semaphore = dispatch_semaphore_create(1);
    });
    NSDate *out = nil;
    if (input && input != (id)[NSNull null])
    {
        dispatch_semaphore_wait(formatter_semaphore, DISPATCH_TIME_FOREVER);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:DEFAULT_DATETIME_FORMAT];
        out = [dateFormatter dateFromString:input];
        if (out == nil)
        {
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            out = [dateFormatter dateFromString:input];
        }
        if (out == nil)
        {
            [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
            out = [dateFormatter dateFromString:input];
        }
        if (out == nil)
        {
            [dateFormatter setDateFormat:@"dd/MM/yyyy"];
            out = [dateFormatter dateFromString:input];
        }
        if (out == nil)
        {
            [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
            out = [dateFormatter dateFromString:input];
        }
        if (out == nil)
        {
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            out = [dateFormatter dateFromString:input];
        }
        dispatch_semaphore_signal(formatter_semaphore);
        if (offsetSeconds != 0)
        {
            out = [NSDate dateWithTimeInterval:offsetSeconds sinceDate:out];
        }
    }
    return out;
}

NSMutableString *appendParamsArrayToString(NSMutableString *str, NSArray *params)
{
    if (params)
    {
        assert((params.count % 2 == 0) && "Query url paramters should be paired.");
        for (int i = 0; i < params.count; i ++)
        {
            NSString *param = [params objectAtIndex:i];
            assert(param != nil && param.length > 0 && "Param is empty.");
            [str appendFormat:@"%@%@=", (str.length > 0 ? @"&" : @""), urlEncodeFull(NONULL(param))];
            i++; //move to value
            assert(i < params.count && "Get value out of range.");
            if (i < params.count)
            {
                NSObject *value = [params objectAtIndex:i];
                if ([value isKindOfClass:[NSString class]])
                    [str appendString:urlEncodeFull(NONULL((NSString *)value))];
                else if ([value isKindOfClass:[NSNumber class]])
                    [str appendString:[((NSNumber *)value) stringValue]];
                else
                    assert(NO && "Only numbers or strings allowed in URL Parameters");
            }
        }
    }
    return str;
}

NSMutableString *appendParamsDictToString(NSMutableString *str, NSDictionary *params)
{
    __block int index = 0;
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (str.length > 0)
            [str appendString:@"&"];
        if ([key isKindOfClass:[NSString class]])
            [str appendString:urlEncodeFull(NONULL((NSString *)key))];
        else if ([key isKindOfClass:[NSNumber class]])
            [str appendString:[((NSNumber *)key) stringValue]];
        else
            assert(NO && "Only numbers or strings allowed in URL Parameters");
        [str appendString:@"="];
        if (obj && obj != [NSNull null])
        {
            if ([obj isKindOfClass:[NSString class]])
                [str appendString:urlEncodeFull(NONULL((NSString *)obj))];
            else if ([obj isKindOfClass:[NSNumber class]])
                [str appendString:[((NSNumber *)obj) stringValue]];
            else
                assert(NO && "Only numbers or strings allowed in URL Parameters");
        }
        index++;
    }];
    return str;
}

/**
 * Makes a URL string given a baseURL, the path and a list of GET
 * parameters (and their values).
 */
NSMutableString *makeUrlString(NSString *baseURL, NSString *path, NSArray *params)
{
    NSMutableString *url_string = makeBaseUrlString(baseURL, path);
    return appendParamsArrayToString(url_string, params);
}

/**
 * Appends a new parameter and value for an already constructed URL string.
 */
NSMutableString *appendUrlParam(NSMutableString *url_string, NSString *param, NSObject *value)
{
    [url_string appendFormat:@"&%@=%@", param, NONULL(value)];
    return url_string;
}

/**
 * Adds a parameter to an array.
 */
void addParamToArray(NSMutableArray *array, NSString *param, NSObject *value)
{
    if (value)
    {
        [array addObject:param];
        [array addObject:value];
    }
}

NSString *makeTagFilter(NSArray *firstArray, ...)
{
    NSMutableString *output = [NSMutableString stringWithCapacity:32];
    if (firstArray)
    {
        CREATE_VA_LIST(args, firstArray);
        [output appendString:[firstArray componentsJoinedByString:@","]];
        NSArray *nextarray = nil;
        while ((nextarray = ns_va_arg(args, NSArray*)) != nil)
        {
            NSString *next_tag = [nextarray componentsJoinedByString:@","];
            if (next_tag.length > 0)
            {
                [output appendString:@"|"];
                [output appendString:next_tag];
            }
        }
    }
    return output;
}

/**
 * Converts a hex char to int.
 */
int hexchar2int(int ch)
{
    if (ch >= 'a' && ch <= 'z')
        return 10 + (ch - 'a');
    else if (ch >= 'A' && ch <= 'Z')
        return 10 + (ch - 'A');
    else if (ch >= '0' && ch <= '9')
        return ch - '0';
    return 0;
}

BOOL isNetworkError(NSError *error)
{
    return (error.domain == NSURLErrorDomain &&
            (error.code == NSURLErrorNotConnectedToInternet ||
             error.code == NSURLErrorTimedOut ||
             error.code == kCFURLErrorCannotConnectToHost ||
             error.code == kCFURLErrorNetworkConnectionLost));
}

/**
 * Run the block in the main thread by dispatching to the main queue 
 * if current thread is not the main thread.
 * DO NOT use this as a recursive lock.
 */
void ensure_main_thread(dispatch_block_t block)
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

void ensure_queue(dispatch_queue_t queue, BOOL asynch, BOOL barrier, dispatch_block_t block)
{
    if (queue == dispatch_get_current_queue())
    {
        block();
    }
    else
    {
        dispatcher_method_t dispatcher = dispatch_async;
        if (asynch)
            dispatcher = barrier ? dispatch_barrier_async : dispatch_async;
        else
            dispatcher = barrier ? dispatch_barrier_sync : dispatch_sync;
        dispatcher(queue, block);
    }
}

/**
 * A shortcut to dispatch a block asynchronously to the main thread.
 */
void dispatch_to_main(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}

/**
 * URL encodes a string leaving slashes and ampersands out.
 */
NSString *urlEncodeSimple(NSString *input)
{
    return [input stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

/**
 * URL encodes a string including slashes and ampersands.
 */
NSString *urlEncodeFull(NSString *input)
{    
    return (__bridge NSString *)CFAutorelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                        (__bridge CFStringRef)input,
                                                        NULL,
                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                        kCFStringEncodingUTF8));
}

/**
 * Creates a queue with random value surrounded by a prefix and suffix.
 */
dispatch_queue_t create_dispatch_queue_with_random_value(const char *prefix, const char *suffix)
{
    char queue_name[256];
    sprintf(queue_name,
            "%s%f%s",
            (prefix ? prefix : ""),
            [NSDate timeIntervalSinceReferenceDate],
            (suffix ? suffix : ""));
    return dispatch_queue_create(queue_name, NULL);
}

/**
 * Wraps a given block within a dispatch wait and dispatch signal block 
 * with an optional time out value.
 * This is equivalent to:
 *
 *     dispatch_semaphore_wait(semaphore, timeout);
 *     block();
 *     dispatch_semaphore_signal(semaphore);
 */
void dispatch_semaphore_wrap(dispatch_semaphore_t semaphore,
                             dispatch_time_t timeout,
                             dispatch_block_t block)
{
    dispatch_semaphore_wait(semaphore, timeout);
    block();
    dispatch_semaphore_signal(semaphore);
}

/**
 * Returns if input string is a valid email address either in a strict or a lax way.
 * See http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
 */
BOOL isEmailAddressValid(NSString *input, BOOL strict)
{
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = strict ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:input];
}

/**
 * Given a container which has the objectEnumerator method,
 * joins all the elements with a given seprator and a string
 * maker function.
 */
NSString *joinComponentsByString(id<NSObject>container,
                                 NSString *separator,
                                 NSString *(^stringMaker)(id))
{
    NSMutableString *out = nil;
    if ([container respondsToSelector:@selector(objectEnumerator)])
    {
        NSEnumerator *enumerator = [container performSelector:@selector(objectEnumerator)];
        BOOL firstItemDone = NO;
        out = [NSMutableString stringWithCapacity:32];
        if (!stringMaker)
            stringMaker = ^(id obj) {
                return (NSString *)obj;
            };
        for (NSObject *object in enumerator)
        {
            if (firstItemDone)
            {
                [out appendString:separator];
            }
            [out appendString:stringMaker(object)];
            firstItemDone = YES;
        }
    }
    return out;
}
//
//NSString *getScreenResolution()
//{
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    return [NSString stringWithFormat:@"%.0f * %.0f", screenRect.size.height, screenRect.size.width];
//}

@implementation NSSet(SPMUExt)

- (NSString *)componentsJoinedByString:(NSString *)separator
{
    return [self componentsJoinedByString:separator withStringMaker:nil];
}

- (NSString *)componentsJoinedByString:(NSString *)separator
                       withStringMaker:(NSString * (^)(id object))stringMaker
{
    return joinComponentsByString(self, separator, stringMaker);
}

@end

@implementation NSDictionary (SPMUExt)

/**
 * Returns the dictionary contents as an array containing
 * key1,value1,key2,value2....keyn,valuen
 */
-(NSArray *)interleavedKeysAndValues
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [array addObject:key];
        [array addObject:obj];
    }];
    return array;
}

/**
 * Returns the keys and values joined as a string in the format:
 * key1<keySeperator>value1<valueSeperator>key2<keySeperator<value2>....
 */
-(NSString *)componentsJoinedBy:(NSString *)keySeperator
                    andValuesBy:(NSString *)valueSeperator
{
    NSMutableString *out = [NSMutableString stringWithCapacity:32];
    __block BOOL dontPrefixSeperator = YES;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (dontPrefixSeperator)
            dontPrefixSeperator = NO;
        else
            [out appendString:valueSeperator];
        [out appendFormat:@"%@%@%@", key, keySeperator, obj];
    }];
    return out;
}

@end

@implementation NSArray (SPMUExt)
- (NSString *)componentsJoinedByString:(NSString *)separator
                       withStringMaker:(NSString * (^)(id object))stringMaker
{
    return joinComponentsByString(self, separator, stringMaker);
}

/**
 * Return a new array by apply a "transformer" method to each entry of an array.
 */
-(void)mapInto:(NSMutableArray *)output withTransformer:(id (^)(id input, BOOL *skip, BOOL *stop))transformer
{
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL skip = NO;
        id newval = transformer(obj, &skip, stop);
        if (!skip)
            [output addObject:newval];
    }];
}

/**
 * Return a new array by apply a "transformer" method to each entry of an array.
 */
-(NSArray *)mapTransformer:(id (^)(id input, BOOL *skip, BOOL *stop))transformer
{
    NSMutableArray *output = [NSMutableArray arrayWithCapacity:self.count];
    [self mapInto:output withTransformer:transformer];
    return output;
}

/**
 * Return the array to an item by applying the given reductor
 * to the items from the left.
 */
-(id)foldLeftWithReductor:(id (^)(id a, id b))reductor
{
    return [self foldInReverse:NO withReductor:reductor];
}
-(id)foldRightWithReductor:(id (^)(id a, id b))reductor
{
    return [self foldInReverse:YES withReductor:reductor];
}
-(id)foldInReverse:(BOOL)reverse withReductor:(id (^)(id a, id b))reductor
{
    __block id output = nil;
    __block BOOL first = YES;
    NSEnumerationOptions options = reverse ? NSEnumerationReverse : 0;
    [self enumerateObjectsWithOptions:options usingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
         if (first)
         {
             output = obj;
             first = NO;
         }
         else
         {
             output = reductor(output, obj);
         }
     }];
    return output;
}

@end


@implementation NSIndexPath(SPMUColumedIndexPath)

+ (NSIndexPath *)indexPathForRow:(NSInteger)row withColumn:(NSInteger)column inSection:(NSInteger)section
{
    NSUInteger indexes[3] = {section, row, column + 1};
    return [NSIndexPath indexPathWithIndexes:indexes length:3];
}

-(NSInteger)column
{
    return self.length < 2 ? -1 : ([self indexAtPosition:2] - 1);
}

@end
