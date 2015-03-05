//
//  AUTClient+User.h
//  AutomaticSDK
//
//  Created by Robert Böhnke on 06/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AutomaticSDK/AutomaticSDK.h>

#pragma clang assume_nonnull begin

@class AFHTTPRequestOperation;

@interface AUTClient (User)

/**
 *  Fetches the currently authenticated user.
 *
 *  @param success A block object to be invoked with the results if the request
 *                 succeeds.
 *  @param failure A block object to be invoked with an error if the request
 *                 fails.
 *
 *  @return An `AFHTTPRequestOperation` representing the request.
 */
- (AFHTTPRequestOperation *)fetchCurrentUserWithSuccess:(void(^ __aut_nullable)(__aut_nullable NSDictionary *))success failure:(void(^ __aut_nullable)(__aut_nullable NSError *))failure;

/**
 *  Fetches a user with a given ID.
 *
 *  @param userID  The ID of the user you are interested in. This argument must
 *                 not be nil.
 *  @param success A block object to be invoked with the results if the request
 *                 succeeds.
 *  @param failure A block object to be invoked with an error if the request
 *                 fails.
 *
 *  @return An `AFHTTPRequestOperation` representing the request.
 */
- (AFHTTPRequestOperation *)fetchCurrentUserWithID:(NSString *)userID success:(void(^ __aut_nullable)(__aut_nullable NSDictionary *))success failure:(void(^ __aut_nullable)(__aut_nullable NSError *))failure;

@end

#pragma clang assume_nonnull end
