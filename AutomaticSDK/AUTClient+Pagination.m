//
//  AUTClient+Pagination.m
//  AutomaticSDK
//
//  Created by Robert Böhnke on 11/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "AUTClient+Pagination.h"

@implementation AUTClient (Pagination)

- (AFHTTPRequestOperation *)fetchPage:(NSURL *)pageURL success:(void(^)(NSDictionary *))success failure:(void(^)(NSError *))failure {
    NSParameterAssert(pageURL != nil);

    NSError *error;
    NSURLRequest *request = [self.requestManager.requestSerializer
        requestBySerializingRequest:[NSURLRequest requestWithURL:pageURL]
        withParameters:nil
        error:&error];

    if (request == nil && failure != nil) {
        dispatch_async(self.requestManager.completionQueue ?: dispatch_get_main_queue(), ^{
            failure(error);
        });
    }

    AFHTTPRequestOperation *operation = [self.requestManager
        HTTPRequestOperationWithRequest:request
        success:AUTExtractResponseObject(success)
        failure:AUTExtractError(failure)];

    [self.requestManager.operationQueue addOperation:operation];

    return operation;
}

@end
