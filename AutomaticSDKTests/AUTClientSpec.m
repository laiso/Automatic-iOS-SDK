//
//  AUTClientSpec.m
//  AutomaticSDK
//
//  Created by Robert Böhnke on 05/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <Nocilla/Nocilla.h>

#import "AUTClient.h"

SpecBegin(AUTClient)

beforeAll(^{
    [LSNocilla.sharedInstance start];
});

afterEach(^{
    [LSNocilla.sharedInstance clearStubs];
});

afterAll(^{
    [LSNocilla.sharedInstance stop];
});

it(@"should initialize with a client ID and secret", ^{
    AUTClient *client = [[AUTClient alloc] initWithClientID:@"client-id" clientSecret:@"client-secret"];

    expect(client.clientID).to.equal(@"client-id");
    expect(client.clientSecret).to.equal(@"client-secret");
});

it(@"should create a NSURL for authorization", ^{
    AUTClient *client = [[AUTClient alloc] initWithClientID:@"client-id" clientSecret:@"client-secret"];

    NSURL *URL = [client URLForAuthorizationWithScopes:AUTClientScopesBehavior];

    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];

    expect(URLComponents.host).to.equal(@"accounts.automatic.com");
    expect(URLComponents.scheme).to.equal(@"https");

    expect(URLComponents.queryItems).to.contain([NSURLQueryItem queryItemWithName:@"client_id" value:@"client-id"]);
    expect(URLComponents.queryItems).to.contain([NSURLQueryItem queryItemWithName:@"response_type" value:@"code"]);
    expect(URLComponents.queryItems).to.contain([NSURLQueryItem queryItemWithName:@"scope" value:@"scope:behavior"]);
});

__block BOOL success;
__block NSError *error;

beforeEach(^{
    success = NO;
    error = nil;
});

describe(@"Handling the callback URI", ^{
    __block AUTClient *client;

    beforeEach(^{
        client = [[AUTClient alloc] initWithClientID:@"client-id" clientSecret:@"client-secret"];
    });

    // This test no longer passes since the AUTClient cannot open the
    // authorization URL without there being a UIApplication.sharedApplication
    // to open it and since 55ce2b1, failure to open the URL triggers the
    // failure call back (it was fire-and-forget before).
    pending(@"should exchange the code for an access token", ^{
        stubRequest(@"POST", @"https://accounts.automatic.com/oauth/access_token/")
            .withBody(@"client_id=client-id&client_secret=client-secret&code=CODE&grant_type=authorization_code")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"access_token\": \"ACCESS_TOKEN\","
                "\"expires_in\": 31535999,"
                "\"scope\": \"scope:vehicle:events\","
                "\"refresh_token\": \"REFRESH_TOKEN\","
                "\"token_type\": \"Bearer\""
            "}");

        __block BOOL couldHandleRedirect;

        waitUntil(^(DoneCallback done) {
            [client
                authorizeWithScopes:AUTClientScopesVehicleEvents
                success:^{
                    success = YES;
                    done();
                }
                failure:^(NSError *authorizationError) {
                    success = NO;
                    error = authorizationError;
                    done();
                }];

            // Simulate the callback coming back from the browser coming in
            // after one second.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSURL *URL = [NSURL URLWithString:@"automatic-client-id://oauth?code=CODE"];

                couldHandleRedirect = [client handleOpenURL:URL];
            });
        });

        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(couldHandleRedirect).to.beTruthy();
    });

    it(@"should invoke the failure block if the redirect URI has no code", ^{
        __block BOOL couldHandleRedirect;

        waitUntil(^(DoneCallback done) {
            [client
                authorizeWithScopes:AUTClientScopesVehicleEvents
                success:^{
                    success = YES;
                    done();
                }
                failure:^(NSError *authorizationError) {
                    success = NO;
                    error = authorizationError;
                    done();
                }];

            // Simulate the callback coming back from the browser coming in
            // after one second.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSURL *URL = [NSURL URLWithString:@"automatic-client-id://oauth"];

                couldHandleRedirect = [client handleOpenURL:URL];
            });
        });

        expect(success).to.beFalsy();
//        expect(error).notTo.beNil();
//        expect(error.domain).to.equal(AUTClientErrorDomain);
//        expect(error.code).to.equal(AUTClientErrorAuthorizationFailed);
//        expect(couldHandleRedirect).to.beTruthy();
    });
});

describe(@"Making a second authorization request", ^{
    __block AUTClient *client;

    beforeEach(^{
        client = [[AUTClient alloc] initWithClientID:@"CLIENT_ID" clientSecret:@"CLIENT_SECRET"];
    });

    it(@"should invoke the failure block of the first request", ^{
        waitUntil(^(DoneCallback done) {
            [client
                authorizeWithScopes:AUTClientScopesPublic
                success:^{
                    success = YES;
                    done();
                }
                failure:^(NSError *authorizationError) {
                    success = NO;
                    error = authorizationError;
                    done();
                }];

            [client authorizeWithScopes:AUTClientScopesPublic success:nil failure:nil];
        });

        expect(success).to.beFalsy();
        expect(error).notTo.beNil();
        expect(error.domain).to.equal(AUTClientErrorDomain);
        expect(error.code).to.equal(AUTClientErrorAuthorizationFailed);
    });
});

describe(@"-authorizeByRefreshingCredential:success:failure", ^{
    __block AUTClient *client;

    beforeEach(^{
        client = [[AUTClient alloc] initWithClientID:@"client-id" clientSecret:@"client-secret"];
    });

    it(@"should call the success block if authorization was successful", ^{
        stubRequest(@"POST", @"https://accounts.automatic.com/oauth/access_token/")
            .withBody(@"client_id=client-id&client_secret=client-secret&grant_type=refresh_token&refresh_token=REFRESH_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"access_token\": \"ACCESS_TOKEN\","
                "\"expires_in\": 31535999,"
                "\"scope\": \"scope:vehicle:events\","
                "\"refresh_token\": \"REFRESH_TOKEN_2\","
                "\"token_type\": \"Bearer\""
            "}");

        AFOAuthCredential *oldCredential = [AFOAuthCredential credentialWithOAuthToken:@"EXPIRED_TOKEN" tokenType:@"Bearer"];
        oldCredential.refreshToken = @"REFRESH_TOKEN";
        oldCredential.expiration = [NSDate dateWithTimeIntervalSinceNow:-1];

        waitUntil(^(DoneCallback done){
            [client
                authorizeByRefreshingCredential:oldCredential
                success:^{
                    success = YES;
                    done();
                }
                failure:^(NSError *authenticationError) {
                    success = NO;
                    error = authenticationError;
                    done();
                }];
        });

        expect(success).to.beTruthy();
//        expect(error).to.beNil();
    });

    it(@"should call the failure block if the given refresh token is not authorized", ^{
        stubRequest(@"POST", @"https://accounts.automatic.com/oauth/access_token/")
            .withBody(@"client_id=client-id&client_secret=client-secret&grant_type=refresh_token&refresh_token=INVALID_REFRESH_TOKEN")
            .andReturn(403);

        AFOAuthCredential *invalidCredential = [AFOAuthCredential credentialWithOAuthToken:@"EXPIRED_TOKEN" tokenType:@"Bearer"];
        invalidCredential.refreshToken = @"INVALID_REFRESH_TOKEN";
        invalidCredential.expiration = [NSDate dateWithTimeIntervalSinceNow:-1];

        waitUntil(^(DoneCallback done){
            [client
                authorizeByRefreshingCredential:invalidCredential
                success:^{
                    success = YES;
                    done();
                }
                failure:^(NSError *authenticationError) {
                    success = NO;
                    error = authenticationError;
                    done();
                }];
        });

        expect(success).to.beFalsy();
        expect(error).notTo.beNil();
    });
});

describe(@"The requestManager", ^{
    __block AUTClient *client;

    beforeEach(^{
        client = [[AUTClient alloc] initWithClientID:@"CLIENT_ID" clientSecret:@"CLIENT_SECRET"];
        client.credential = [AFOAuthCredential credentialWithOAuthToken:@"ACCESS_TOKEN" tokenType:@"Bearer"];
    });

    it(@"should have its authentication header set by the client", ^{
        stubRequest(@"GET", @"https://api.automatic.com/user/me/")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"email\": \"developer@automatic.com\","
                "\"first_name\": \"Developer\","
                "\"id\": \"U_0123456789abcdef\","
                "\"last_name\": \"Support\","
                "\"url\": \"https://api.automatic.com/user/U_0123456789abcdef/\","
                "\"username\": \"developer@automatic.com\""
            "}");

        __block id response = nil;

        waitUntil(^(DoneCallback done) {
            [client.requestManager
                GET:@"/user/me/"
                parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    response = responseObject;
                    success = YES;
                    done();
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *requestError) {
                    success = NO;
                    error = requestError;
                    done();
                }];
        });

        expect(response[@"email"]).to.equal(@"developer@automatic.com");
        expect(response[@"first_name"]).to.equal(@"Developer");
        expect(response[@"id"]).to.equal(@"U_0123456789abcdef");
        expect(response[@"last_name"]).to.equal(@"Support");
        expect(response[@"url"]).to.equal(@"https://api.automatic.com/user/U_0123456789abcdef/");
        expect(response[@"username"]).to.equal(@"developer@automatic.com");

        expect(success).to.beTruthy();
        expect(error).to.beNil();
    });
});

SpecEnd
