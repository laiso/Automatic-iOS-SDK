//
//  AUTClient+Trip.m
//  AutomaticSDK
//
//  Created by Robert Böhnke on 10/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "AUTClient+Trip.h"

@implementation AUTClient (Trip)

- (AFHTTPRequestOperation *)fetchTripsForCurrentUserWithSuccess:(void(^)(NSDictionary *))success failure:(void(^)(NSError *))failure {
    return [self.requestManager
        GET:@"trip/"
        parameters:nil
        success:AUTExtractResponseObject(success)
        failure:AUTExtractError(failure)];
}

- (AFHTTPRequestOperation *)fetchTripsForUserWithID:(NSString *)userID success:(void(^)(NSDictionary *))success failure:(void(^)(NSError *))failure {
    NSParameterAssert(userID != nil);

    return [self.requestManager
        GET:[NSString stringWithFormat:@"user/%@/trip/", userID]
        parameters:nil
        success:AUTExtractResponseObject(success)
        failure:AUTExtractError(failure)];
}

- (AFHTTPRequestOperation *)fetchTripWithID:(NSString *)tripID success:(void(^)(NSDictionary *))success failure:(void(^)(NSError *))failure {
    NSParameterAssert(tripID != nil);

    return [self.requestManager
        GET:[NSString stringWithFormat:@"trip/%@/", tripID]
        parameters:nil
        success:AUTExtractResponseObject(success)
        failure:AUTExtractError(failure)];
}

@end
