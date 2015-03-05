//
//  AUTClient+Pagination.h
//  AutomaticSDK
//
//  Created by Robert Böhnke on 11/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AutomaticSDK/AutomaticSDK.h>

#pragma clang assume_nonnull begin

@interface AUTClient (Pagination)

/**
 *  Fetches a page at a given URL.
 *
 *  @param pageURL The URL to fetch. This argument must not be nil.
 *  @param success A block object to be invoked with the results if the request
 *                 succeeds.
 *  @param failure A block object to be invoked with an error if the request
 *                 fails.
 *
 *  @return An `AFHTTPRequestOperation` representing the request.
 */
- (AFHTTPRequestOperation *)fetchPage:(NSURL *)pageURL success:(void(^ __aut_nullable)(__aut_nullable NSDictionary *))success failure:(void(^ __aut_nullable)(__aut_nullable NSError *))failure;

@end

#pragma clang assume_nonnull end
