//
//  SPMUUser.h
//  TrackMyBattery
//
//  Created by Panyam, Sriram on 12/3/13.
//  Copyright (c) 2013 Panyam. All rights reserved.
//

#import "SPMUFwdDefs.h"

/**
 * A generic user object for the purposes of login.
 */
@interface SPMUUser : NSObject


@property (nonatomic, strong) NSMutableSet *readPermissions;
@property (nonatomic, strong) NSMutableSet *writePermissions;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *middle_name;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *nick_name;
@property (nonatomic, readonly) NSUInteger propertyCount;
@property (nonatomic, readonly) NSEnumerator *keyEnumerator;

-(void)removeObjectForKey:(NSString *)key;
-(id)objectForKey:(NSString *)key;
-(void)setObject:(id)value forKey:(NSString *)key;

@end
