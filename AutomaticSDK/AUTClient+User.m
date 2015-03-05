//
//  AUTClient+User.m
//  AutomaticSDK
//
//  Created by Robert Böhnke on 06/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "AUTClient+User.h"

@implementation AUTClient (User)

- (AFHTTPRequestOperation *)fetchCurrentUserWithSuccess:(void(^)(NSDictionary *))success failure:(void(^)(NSError *))failure {
    return [self.requestManager
        GET:@"user/me/"
        parameters:nil
        success:AUTExtractResponseObject(success)
        failure:AUTExtractError(failure)];
}

- (AFHTTPRequestOperation *)fetchCurrentUserWithID:(NSString *)userID success:(void(^)(NSDictionary *))success failure:(void(^)(NSError *))failure {
    NSParameterAssert(userID != nil);

    return [self.requestManager
        GET:[NSString stringWithFormat:@"user/%@/", userID]
        parameters:nil
        success:AUTExtractResponseObject(success)
        failure:AUTExtractError(failure)];
}

@end
