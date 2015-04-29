//
//  AUTClient.m
//  AutomaticSDK
//
//  Created by Robert Böhnke on 05/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <AFOAuth2Manager/AFHTTPRequestSerializer+OAuth2.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <libextobjc/EXTScope.h>

#import "AUTClient.h"

NSString * const AUTClientErrorDomain = @"AUTClientErrorDomain";

const NSInteger AUTClientErrorAuthorizationFailed = 1;

@interface AUTClient ()

@property (readonly, nonatomic, strong) AFOAuth2Manager *OAuth2Manager;

@property (readwrite, nonatomic, copy) void(^pendingFailureCallback)(NSError *);

@property (readwrite, nonatomic, copy) void(^pendingSuccessCallback)(void);

@property (readonly, nonatomic, strong) NSString *authorizationURLScheme;

+ (NSURL *)accessTokenEndpoint;

+ (NSURL *)APIBaseURL;

+ (NSURL *)authenticationBaseURL;

+ (NSURL *)authorizationEndpoint;

+ (NSString *)serializeScopes:(AUTClientScopes)scopes;

/**
 *  Authorize the receiver with a code.
 *
 *  @param code    The authorization code obtained from the browser. This
 *                 argument must not be `nil`.
 *  @param success A block to be invoked when the authorization was successful.
 *                 The receiver's `credential` will be set by the time the block
 *                 is invoked.
 *  @param failure A block to be invoked with an error if the authorization
 *                 fails.
 */
- (void)authorizeWithCode:(NSString *)code success:(nullable AUTSuccessBlock)success failure:(nullable AUTFailureBlock)failure;

@end

@implementation AUTClient

#pragma mark - Lifecycle

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret {
    NSParameterAssert(clientID != nil);
    NSParameterAssert(clientSecret != nil);

    self = [super init];
    if (self == nil) return nil;

    _clientID = [clientID copy];
    _clientSecret = [clientSecret copy];
    _OAuth2Manager = [[AFOAuth2Manager alloc] initWithBaseURL:AUTClient.authenticationBaseURL clientID:clientID secret:clientSecret];
    _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.class.APIBaseURL];

    return self;
}

#pragma mark - Property

- (NSString *)authorizationURLScheme {
    return [[NSString stringWithFormat:@"automatic-%@", self.clientID] lowercaseString];
}

- (void)setCredential:(AFOAuthCredential *)credential {
    _credential = credential;

    [self.requestManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
}

#pragma mark - AUTClient

- (NSURL *)URLForAuthorizationWithScopes:(AUTClientScopes)scopes {
    NSString *serializedScopes = [AUTClient serializeScopes:scopes];

    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:AUTClient.authorizationEndpoint resolvingAgainstBaseURL:YES];
    URLComponents.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"client_id" value:self.clientID],
        [NSURLQueryItem queryItemWithName:@"scope" value:serializedScopes],
        [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"],
    ];

    return [URLComponents URL];
}

- (void)authorizeWithScopes:(AUTClientScopes)scopes success:(void(^)(void))success failure:(void(^)(NSError *))failure {
    if (self.pendingFailureCallback != nil) {
        NSError *error = [NSError
            errorWithDomain:AUTClientErrorDomain
            code:AUTClientErrorAuthorizationFailed
            userInfo:@{
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The authorization request was cancelled by a subsequent request.", nil),
                NSLocalizedDescriptionKey: NSLocalizedString(@"The authorization could not be completed.", nil)
            }];

        self.pendingFailureCallback(error);
    }

    self.pendingFailureCallback = failure;
    self.pendingSuccessCallback = success;

    NSURL *URL = [self URLForAuthorizationWithScopes:scopes];

    BOOL didOpenURL = [UIApplication.sharedApplication openURL:URL];
    
    if (!didOpenURL && self.pendingFailureCallback != nil) {
        NSError *error = [NSError
            errorWithDomain:AUTClientErrorDomain
            code:AUTClientErrorAuthorizationFailed
            userInfo:@{
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The system was unable to perform the authorization request.", nil),
                NSLocalizedDescriptionKey: NSLocalizedString(@"The authorization could not be completed.", nil)
            }];
        
        self.pendingFailureCallback(error);
    }
}

- (BOOL)handleOpenURL:(NSURL *)URL {
    NSParameterAssert(URL != nil);

    BOOL (^caseInsensitiveEqual)(NSString *, NSString *) = ^BOOL(NSString *a, NSString *b) {
        return a != nil && b != nil && [a caseInsensitiveCompare:b] == NSOrderedSame;
    };

    if (caseInsensitiveEqual(URL.scheme, self.authorizationURLScheme) && caseInsensitiveEqual(URL.host, @"oauth")) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];

        NSString *code = nil;
        for (NSURLQueryItem *item in components.queryItems) {
            if ([item.name isEqualToString:@"code"]) {
                code = item.value;
                break;
            }
        }

        if (code == nil) {
            if (self.pendingFailureCallback != nil) {
                NSError *error = [NSError
                    errorWithDomain:AUTClientErrorDomain
                    code:AUTClientErrorAuthorizationFailed
                    userInfo:@{
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The callback URI did not contain a valid authorization code.", nil),
                        NSLocalizedDescriptionKey: NSLocalizedString(@"The authorization could not be completed.", nil)
                    }];

                self.pendingFailureCallback(error);
            }

            self.pendingSuccessCallback = nil;
            self.pendingFailureCallback = nil;

            return YES;
        }

        @weakify(self);
        [self
            authorizeWithCode:code
            success:^{
                @strongify(self);

                if (self.pendingSuccessCallback != nil) {
                    self.pendingSuccessCallback();
                }

                self.pendingSuccessCallback = nil;
                self.pendingFailureCallback = nil;
            }
            failure:^(NSError *error) {
                if (self.pendingFailureCallback != nil) {
                    self.pendingFailureCallback(error);
                }

                self.pendingSuccessCallback = nil;
                self.pendingFailureCallback = nil;
            }];

        return YES;
    }

    return NO;
}

- (void)authorizeWithCode:(NSString *)code success:(void(^)(void))success failure:(void(^)(NSError *))failure {
    NSParameterAssert(code != nil);

    NSDictionary *parameters = @{
        @"client_id": self.clientID,
        @"client_secret": self.clientSecret,
        @"code": code ?: NSNull.null,
        @"grant_type": @"authorization_code"
    };

    @weakify(self);
    [self.OAuth2Manager
        authenticateUsingOAuthWithURLString:AUTClient.accessTokenEndpoint.absoluteString
        parameters:parameters
        success:^(AFOAuthCredential *credential) {
            @strongify(self);

            self.credential = credential;

            if (success != nil) {
                success();
            }
        }
        failure:failure];
}

- (void)authorizeByRefreshingCredential:(AFOAuthCredential *)credential success:(void(^)(void))success failure:(void(^)(NSError *))failure {
    NSParameterAssert(credential != nil);

    NSDictionary *parameters = @{
        @"client_id": self.clientID,
        @"client_secret": self.clientSecret,
        @"refresh_token": credential.refreshToken ?: NSNull.null,
        @"grant_type": @"refresh_token"
    };

    @weakify(self);
    [self.OAuth2Manager
        authenticateUsingOAuthWithURLString:AUTClient.accessTokenEndpoint.absoluteString
        parameters:parameters
        success:^(AFOAuthCredential *credential) {
            @strongify(self);

            self.credential = credential;

            if (success != nil) {
                success();
            }
        }
        failure:failure];
}

#pragma mark - Private

+ (NSURL *)accessTokenEndpoint {
    return [NSURL URLWithString:@"/oauth/access_token/" relativeToURL:self.authenticationBaseURL];
}

+ (NSURL *)APIBaseURL {
    return [NSURL URLWithString:@"https://api.automatic.com"];
}

+ (NSURL *)authenticationBaseURL {
    return [NSURL URLWithString:@"https://accounts.automatic.com"];
}

+ (NSURL *)authorizationEndpoint {
    return [NSURL URLWithString:@"/oauth/authorize/" relativeToURL:self.authenticationBaseURL];
}

+ (NSString *)serializeScopes:(AUTClientScopes)scopes {
    NSDictionary *scopeStringsByEnum = @{
        @(AUTClientScopesPublic): @"scope:public",
        @(AUTClientScopesUserProfile): @"scope:user:profile",
        @(AUTClientScopesUserFollow): @"scope:user:follow",
        @(AUTClientScopesLocation): @"scope:location",
        @(AUTClientScopesCurrentLocation): @"scope:current_location",
        @(AUTClientScopesVehicleProfile): @"scope:vehicle:profile",
        @(AUTClientScopesVehicleEvents): @"scope:vehicle:events",
        @(AUTClientScopesVehicleVIN): @"scope:vehicle:vin",
        @(AUTClientScopesTrip): @"scope:trip",
        @(AUTClientScopesBehavior): @"scope:behavior"
    };

    NSMutableArray *scopesArray = [NSMutableArray array];

    for (NSNumber *scope in scopeStringsByEnum) {
        if ((scopes & scope.unsignedIntegerValue) != 0) {
            [scopesArray addObject:scopeStringsByEnum[scope]];
        }
    }

    return [scopesArray componentsJoinedByString:@" "];
}

@end

extern void (^ __nullable AUTExtractResponseObject(__nullable AUTResponseBlock callback))(AFHTTPRequestOperation * __nullable, id __nullable) {
    if (callback == nil) return nil;

    return ^(AFHTTPRequestOperation *_, id responseObject) {
        callback(responseObject);
    };
}

extern void (^ __nullable AUTExtractError(__nullable AUTFailureBlock callback))(AFHTTPRequestOperation * __nullable, NSError * __nullable) {
    if (callback == nil) return nil;

    return ^(AFHTTPRequestOperation *_, NSError *error) {
        callback(error);
    };
}
