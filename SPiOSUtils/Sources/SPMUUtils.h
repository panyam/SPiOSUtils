
#import "SPMUFwdDefs.h"

#ifndef __SPMU_UTILS_H__
#define __SPMU_UTILS_H__

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define SECONDS_IN_A_MINUTE     60
#define MINUTES_IN_AN_HOUR      60
#define SECONDS_IN_AN_HOUR      3600
#define HOURS_IN_A_DAY          24
#define SECONDS_IN_A_DAY        (HOURS_IN_A_DAY * SECONDS_IN_AN_HOUR)

#define UICOLORRGBA(r,g,b,a)                [UIColor colorWithRed:((float)r)/255.0 green:((float)g)/255.0 blue:((float)b)/255.0 alpha:((float)a)/255.0]
#define UICOLORRGB(r,g,b)                   UICOLORRGBA(r,g,b,255)

#define NONULL(x)       ((((x) != nil) && ((x) != (id)[NSNull null])) ? (x) : @"")
#define NOEMPTY(str)    ((str && str.length > 0) ? (str) : nil)

#define CREATE_VA_LIST(args, param1)    va_list args ; va_start(args, param1)
#define DEFAULT_DATETIME_FORMAT @"yyyy-MM-dd HH:mm:ss"

extern const NSString *SPMUErrorDomain;
extern const NSString *SPMUUserErrorDomain;
extern const NSString *SPMUSystemErrorDomain;

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

#define ns_va_arg(args, type)   (__bridge type)va_arg(args, void *)

typedef void (*dispatcher_method_t)(dispatch_queue_t queue, dispatch_block_t block);


@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end

@interface SPMUUtils : NSObject

+(NSString *)relativeStringFromAbsoluteTime:(NSTimeInterval)currTime;

+(void)handleError:(NSError *)error;

+(NSString *)imageUrlForTag:(NSString *)tag;

+(UIBarButtonItem *)plainBarButtonWithImage:(NSString *)image
                                 withTarget:(id)target
                               withSelector:(SEL)selector;

@end

extern float frand(float lower, float upper);

/**
 * Wraps updates to the user defaults with a synchronized following all updates.
 */
extern void commitToUserDefaults(NSUserDefaults *userDefaults,
                                 void (^updater_block)(NSUserDefaults *));

/**
 * Wraps updates to the standard user defaults with a synchronized following all updates.
 */
extern void commitToStandardUserDefaults(void (^updater_block)(NSUserDefaults *));

extern void presentError(NSError *error, BOOL announceNetworkError);

/**
 * Shows the error but rate limits "no network" errors to
 * the given number of seconds.
 */
void presentErrorRateLimited(NSError *error, double minseconds);

/**
 * Converts a float to a string and optionally rounding to the given decimal places.
 */
extern NSString *floatToStr(double value, int numPlaces, double accuracy);

/**
 * Ensures that the block runs in the main queue only.
 */
extern void ensure_main_queue(dispatch_block_t block);

/**
 * Ensures that the block runs in the main queue only if predicate is satisfied.
 */
extern void ensure_main_queue_if(BOOL predicate, dispatch_block_t block);

/**
 * Dispatch to main queue unconditionally.
 */
extern void dispatch_to_main_queue(dispatch_block_t block);

extern UIView *loadFromNib(NSString *nibName, id owner);

//iOS version
#define OS_ISVERSION_SINCE(X) (BOOL)([[[UIDevice currentDevice] systemVersion] substringToIndex:1].integerValue >= X)

/**
 * Gets the user default that is to be used by the applications.
 * If a value is given then it is set as the user defaults for
 * subsequent invocations.
 */
extern NSUserDefaults *getUserDefaults(NSUserDefaults *newvalue);

extern NSMutableString *makeBaseUrlString(NSString *baseURL, NSString *path);
extern NSMutableString *makeUrlString(NSString *baseURL,
                                      NSString *path,
                                      NSArray *params);
extern NSMutableString *appendUrlParam(NSMutableString *url_string,
                                       NSString *param,
                                       NSObject *value);

/**
 * Converts a byte array into an hex string.
 */
extern NSMutableString *dataToHexString(NSData *data);

/**
 Appends a whole bunch of parameter and values to a string in the form: param1=value1&param2=value2&param3=value3....
 @param params Array listed as [param1, value1, param2, value2, param3, value3, ...], it must be paired.
 */
extern NSMutableString *appendParamsArrayToString(NSMutableString *str, NSArray *params);

/**
 Appends a whole bunch of parameter and values to a string in the form: param1=value1&param2=value2&param3=value3....
 @param params Dictionary listed as {param1 = value1, param2 = value2, param3 = value3, ...}, it must be paired.
 */
extern NSMutableString *appendParamsDictToString(NSMutableString *str, NSDictionary *params);

/**
 * Adds a parameter to an array.
 */
extern void addParamToArray(NSMutableArray *array, NSString *param, NSObject *value);

extern NSString *makeTagFilter(NSArray *firstArray, ...);

/**
 * Converts a float to a string and optionally rounding to the given decimal places.
 */
extern NSString *floatToStr(double value, int numPlaces, double accuracy);

/**
 * Converts a hex char to int.
 */
extern int hexchar2int(int ch);

/**
 * URL encodes a string leaving slashes and ampersands out.
 */
extern NSString *urlEncodeSimple(NSString *input);

/**
 * URL encodes a string including slashes and ampersands.
 */
extern NSString *urlEncodeFull(NSString *input);

/**
 * Creates a new data formatter for StreetHawk-wide date formatting.
 */
extern NSDateFormatter *createDateFormatter(NSString *dateFormat, NSTimeZone *timeZone);

/**
 * Returns the default date formatter with the local time zone.
 */
extern NSDateFormatter *localDateFormatter(void);

/**
 Parses date string into NSDate format. It tries to support as much format as possible. Refer to `input` parameters for the supported date time format. 
 @param input Date time string. It supports this kinds of strings:
 
 * yyyy-MM-dd HH:mm:ss, for example 2012-12-20 18:20:50
 * yyyy-MM-dd, for example 2012-12-20
 * dd/MM/yyyy HH:mm:ss, for example 20/12/2012 18:20:50
 * dd/MM/yyyy, for example 20/12/2012
 * MM/dd/yyyy HH:mm:ss, for example 12/20/2012 18:20:50
 * MM/dd/yyyy, for example 12/20/2012
 
 @param offsetSeconds The offsetSeconds parameter tells how many seconds the parsed date is to be offset by.
 */
extern NSDate *parseDate(NSString *input, int offsetSeconds);

/**
 * Formats a date into a string in StreetHawk-wide format.
 */
extern NSString *formatLocalDate(NSDate *date);

/**
 * Returns an error object
 */
extern NSError *makeError(NSString *domain, int code, NSObject *result_value, NSDictionary *userInfo);

/**
 Tells if the error is one that describes a no-connection to the internet and/or host.
 */
extern BOOL isNetworkError(NSError *error);

/**
 * Calculates the square of distance between two lat/longs.
 * Geared for speed over accuracy.
 */
extern double distanceSquared(double lat1, double lng1, double lat2, double lng2);

/**
 * Splits a string with a delimiter and returns only non empty strings.  An
 * empty array is returned if no non-empty strings exist (instead of an
 * array with a single empty string).
 */
extern NSArray* splitStrings(NSString *input, NSString *delimiter);

/**
 * Run the block in the main thread by dispatching to the main queue
 * if current thread is not the main thread.
 * DO NOT use this as a recursive lock.
 */
extern void ensure_main_thread(dispatch_block_t block);
extern void dispatch_to_main(dispatch_block_t block);
extern void ensure_queue(dispatch_queue_t queue, BOOL asynch, BOOL barrier, dispatch_block_t block);

/**
 * Creates a queue with random value surrounded by a prefix and suffix.
 */
extern dispatch_queue_t create_dispatch_queue_with_random_value(const char *prefix, const char *suffix);

/**
 * Given a container which has the objectEnumerator method,
 * joins all the elements with a given seprator and a string
 * maker function.
 */
extern NSString *joinComponentsByString(id<NSObject>container,
                                        NSString *separator,
                                        NSString *(^stringMaker)(id));

/**
 * These method simulate the barrier async functionalities found in Lion.
 */

/**
 * Convert an ASCII encoded c-string to NSString.
 */
extern NSString *cstringToNSString(const char *input);

/**
 * Returns if input string is a valid email address either in a strict or a lax way.
 * See http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
 */
extern BOOL isEmailAddressValid(NSString *input, BOOL strict);

/**
 * Wraps a given block within a dispatch wait and dispatch signal block
 * with an optional time out value.
 * This is equivalent to:
 *
 *     dispatch_semaphore_wait(semaphore, timeout);
 *     block();
 *     dispatch_semaphore_signal(semaphore);
 */
extern void dispatch_semaphore_wrap(dispatch_semaphore_t semaphore,
                                    dispatch_time_t timeout,
                                    dispatch_block_t block);


/**
 Get device's screen resolution, for example "640*480".
 */
extern NSString *getScreenResolution();

/**
 Parse the string or json object to a dictionary. It handles as much situation as possible, for example, the obj is a right dictionary, or the obj is a string, or the string obj contains wrong "\"" etc.
 */
extern NSDictionary *parseObjectToDict(NSObject *obj);

@interface NSArray (SPMUExt)
- (NSString *)componentsJoinedByString:(NSString *)separator
                       withStringMaker:(NSString * (^)(id object))stringMaker;
/**
 * Return a new array by apply a "transformer" method to each entry of an array.
 */
- (NSArray *)mapTransformer:(id (^)(id input, BOOL *skip, BOOL *stop))transformer;
-(void)mapInto:(NSMutableArray *)output withTransformer:(id (^)(id input, BOOL *skip, BOOL *stop))transformer;
/**
 * Return the array to an item by applying the given reductor
 * to the items from the left.
 */
-(id)foldLeftWithReductor:(id (^)(id a, id b))reductor;
-(id)foldRightWithReductor:(id (^)(id a, id b))reductor;
-(id)foldInReverse:(BOOL)reverse withReductor:(id (^)(id a, id b))reductor;
@end

@interface NSDictionary (SPMUExt)
/**
 * Returns the dictionary contents as an array containing
 * key1,value1,key2,value2....keyn,valuen
 */
-(NSArray *)interleavedKeysAndValues;
-(NSString *)componentsJoinedBy:(NSString *)keySeperator
                    andValuesBy:(NSString *)valueSeperator;
@end

@interface NSSet (SPMUExt)
- (NSString *)componentsJoinedByString:(NSString *)separator;
- (NSString *)componentsJoinedByString:(NSString *)separator
                       withStringMaker:(NSString * (^)(id object))stringMaker;
@end

//_______________________________________________________________________
// This category provides convenience methods to make it easier to use an
// NSIndexPath to represent a column as well as a section and a row.
@interface NSIndexPath (StreetHawkColumedIndexPath)

+ (NSIndexPath *)indexPathForRow:(NSInteger)row
                      withColumn:(NSInteger)column
                       inSection:(NSInteger)section;
@property(nonatomic,readonly) NSInteger column;

@end

#endif

