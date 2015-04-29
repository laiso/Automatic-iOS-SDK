//
//  AUTClient+User.h
//  AutomaticSDK
//
//  Created by Robert Böhnke on 06/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AutomaticSDK/AutomaticSDK.h>

NS_ASSUME_NONNULL_BEGIN

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
- (AFHTTPRequestOperation *)fetchCurrentUserWithSuccess:(nullable AUTResponseBlock)success failure:(nullable AUTFailureBlock)failure;

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
- (AFHTTPRequestOperation *)fetchCurrentUserWithID:(NSString *)userID success:(nullable AUTResponseBlock)success failure:(nullable AUTFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
