//
//  AUTClient+UserSpec.m
//  AutomaticSDK
//
//  Created by Robert Böhnke on 06/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <Nocilla/Nocilla.h>

#import "AUTClient.h"
#import "AUTClient+User.h"

SpecBegin(AUTClient_User)

beforeAll(^{
    [LSNocilla.sharedInstance start];
});

afterEach(^{
    [LSNocilla.sharedInstance clearStubs];
});

afterAll(^{
    [LSNocilla.sharedInstance stop];
});

__block AUTClient *client;

beforeEach(^{
    client = [[AUTClient alloc] initWithClientID:@"CLIENT_ID" clientSecret:@"CLIENT_SECRET"];
    client.credential = [AFOAuthCredential credentialWithOAuthToken:@"ACCESS_TOKEN" tokenType:@"Bearer"];
});

describe(@"-fetchCurrentUserWithSuccess:failure:", ^{
    it(@"should fetch a user", ^{
        stubRequest(@"GET", @"https://api.automatic.com/user/me/")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"id\": \"U_acdbcbbe83d3c554\","
                "\"url\": \"https://api.automatic.com/user/U_acdbcbbe83d3c554/\","
                "\"username\": \"robb.bohnke@automatic.com\","
                "\"first_name\": \"Robb\","
                "\"last_name\": \"Böhnke\","
                "\"email\": \"robb.bohnke@automatic.com\""
            "}");

        __block NSDictionary *user;

        waitUntil(^(DoneCallback done) {
            [client fetchCurrentUserWithSuccess:^(NSDictionary *userDictionary) {
                user = userDictionary;
                done();
            } failure:nil];
        });

        expect(user).notTo.beNil();
        expect(user[@"first_name"]).to.equal(@"Robb");
    });
});

describe(@"-fetchCurrentUserWithID:success:failure:", ^{
    it(@"should fetch a user", ^{
        stubRequest(@"GET", @"https://api.automatic.com/user/U_acdbcbbe83d3c554/")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"id\": \"U_acdbcbbe83d3c554\","
                "\"url\": \"https://api.automatic.com/user/U_acdbcbbe83d3c554/\","
                "\"username\": \"robb.bohnke@automatic.com\","
                "\"first_name\": \"Robb\","
                "\"last_name\": \"Böhnke\","
                "\"email\": \"robb.bohnke@automatic.com\""
            "}");

        __block NSDictionary *user;

        waitUntil(^(DoneCallback done) {
            [client
                fetchCurrentUserWithID:@"U_acdbcbbe83d3c554"
                success:^(NSDictionary *userDictionary) {
                    user = userDictionary;
                    done();
                }
                failure:nil];
        });

        expect(user).notTo.beNil();
        expect(user[@"first_name"]).to.equal(@"Robb");
    });
});

SpecEnd
