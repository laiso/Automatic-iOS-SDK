//
//  AUTClient+Vehicle.m
//  AutomaticSDK
//
//  Created by Robert Böhnke on 10/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "AUTClient+Vehicle.h"

@implementation AUTClient (Vehicle)

- (AFHTTPRequestOperation *)fetchVehiclesForCurrentUserWithSuccess:(void(^)(NSDictionary *))success failure:(void(^)(NSError *))failure {
    return [self.requestManager
        GET:@"vehicle/"
        parameters:nil
        success:AUTExtractResponseObject(success)
        failure:AUTExtractError(failure)];
}

- (AFHTTPRequestOperation *)fetchVehiclesForUserWithID:(NSString *)userID success:(void(^)(NSDictionary *))success failure:(void(^)(NSError *))failure {
    NSParameterAssert(userID != nil);

    return [self.requestManager
        GET:[NSString stringWithFormat:@"user/%@/vehicle/", userID]
        parameters:nil
        success:AUTExtractResponseObject(success)
        failure:AUTExtractError(failure)];
}

- (AFHTTPRequestOperation *)fetchVehicleWithID:(NSString *)vehicleID success:(void(^)(NSDictionary *))success failure:(void(^)(NSError *))failure {
    NSParameterAssert(vehicleID != nil);

    return [self.requestManager
        GET:[NSString stringWithFormat:@"vehicle/%@/", vehicleID]
        parameters:nil
        success:AUTExtractResponseObject(success)
        failure:AUTExtractError(failure)];
}

@end
