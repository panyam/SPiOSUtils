//
//  SPMUUser.m
//  TrackMyBattery
//
//  Created by Panyam, Sriram on 12/3/13.
//  Copyright (c) 2013 Panyam. All rights reserved.
//

#import "SPMobileUtils.h"

@interface SPMUUser()
@property (nonatomic, strong) NSMutableDictionary *properties;
@end

@implementation SPMUUser

@synthesize properties;
@synthesize readPermissions;
@synthesize writePermissions;

-(void)dealloc
{
    self.readPermissions = nil;
    self.writePermissions = nil;
    self.properties = nil;
}

-(id)objectForKey:(NSString *)key
{
    return [properties objectForKey:key];
}

-(void)setObject:(id)value forKey:(NSString *)key
{
    if (value && key)
    {
        if (!properties)
            self.properties = [NSMutableDictionary dictionary];
        [properties setObject:value forKey:key];
    }
}

-(void)removeObjectForKey:(NSString *)key
{
    if (key)
        [self.properties removeObjectForKey:key];
}

-(NSEnumerator *)keyEnumerator
{
    return [self.properties keyEnumerator];
}

-(NSUInteger)propertyCount { return [properties count]; }
-(NSString *)email { return [self objectForKey:@"email"]; };
-(NSString *)domain { return [self objectForKey:@"domain"]; };
-(NSString *)userid { return [self objectForKey:@"userid"]; };
-(NSString *)username { return [self objectForKey:@"username"]; };
-(NSString *)name { return [self objectForKey:@"name"]; };
-(NSString *)first_name { return [self objectForKey:@"first_name"]; };
-(NSString *)last_name { return [self objectForKey:@"last_name"]; };
-(NSString *)middle_name { return [self objectForKey:@"middle_name"]; };
-(NSString *)nick_name { return [self objectForKey:@"nick_name"]; };

-(void)setEmail:(NSString *)email { [self setObject:email forKey:@"email"]; };
-(void)setDomain:(NSString *)domain { [self setObject:domain forKey:@"domain"]; };
-(void)setUserid:(NSString *)userid { [self setObject:userid forKey:@"userid"]; };
-(void)setUsername:(NSString *)username { [self setObject:username forKey:@"username"]; };
-(void)setName:(NSString *)name { [self setObject:name forKey:@"name"]; };
-(void)setFirst_name:(NSString *)first_name { [self setObject:first_name forKey:@"first_name"]; };
-(void)setLast_name:(NSString *)last_name { [self setObject:last_name forKey:@"last_name"]; };
-(void)setMiddle_name:(NSString *)middle_name { [self setObject:middle_name forKey:@"middle_name"]; };
-(void)setNick_name:(NSString *)nick_name { [self setObject:nick_name forKey:@"nick_name"]; };

@end
