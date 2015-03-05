//
//  AUTClient+PaginationSpec.m
//  AutomaticSDK
//
//  Created by Robert Böhnke on 11/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <Nocilla/Nocilla.h>

#import "AUTClient+Pagination.h"

SpecBegin(AUTClient_Pagination)

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

describe(@"-fetchPage:success:error:", ^{
    it(@"should fetch the page at the given URL", ^{
        stubRequest(@"GET", @"https://api.automatic.com/vehicle/")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"_metadata\": {"
                    "\"count\": 2,"
                    "\"next\": \"https://api.automatic.com/vehicle/?page=2&limit=1\","
                    "\"previous\": null"
                "},"
                "\"results\": ["
                    "{"
                        "\"url\": \"https://api.automatic.com/vehicle/C_2a8220e75a88be75/\","
                        "\"id\": \"C_2a8220e75a88be75\","
                        "\"make\": \"Ford\","
                        "\"model\": \"Mustang\","
                        "\"year\": 1993,"
                        "\"submodel\": \"SVT Cobra\","
                        "\"color\": null,"
                        "\"display_name\": \"Ford Mustang\""
                    "}"
                "]"
            "}");

        stubRequest(@"GET", @"https://api.automatic.com/vehicle/?page=2&limit=1")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"_metadata\": {"
                    "\"count\": 2,"
                    "\"next\": null,"
                    "\"previous\": \"https://api.automatic.com/vehicle/?page=1&limit=1\""
                "},"
                "\"results\": ["
                    "{"
                        "\"url\": \"https://api.automatic.com/vehicle/C_512006d79b5dbf99/\","
                        "\"id\": \"C_512006d79b5dbf99\","
                        "\"make\": \"BMW\","
                        "\"model\": \"530i\","
                        "\"year\": 1995,"
                        "\"submodel\": \"Base\","
                        "\"color\": null,"
                        "\"display_name\": \"BMW 530i\""
                    "}"
                "]"
            "}");

        __block NSDictionary *secondPage;

        waitUntil(^(DoneCallback done) {
            [client
                fetchVehiclesForCurrentUserWithSuccess:^(NSDictionary *firstPage) {
                    NSURL *pageURL = [NSURL URLWithString:firstPage[@"_metadata"][@"next"]];

                    [client
                        fetchPage:pageURL
                        success:^(NSDictionary *result) {
                            secondPage = result;
                            done();
                        }
                        failure:nil];
                }
                failure:nil];
        });

        NSArray *results = secondPage[@"results"];

        expect(results).to.haveCountOf(1);
        expect(results[0][@"display_name"]).to.equal(@"BMW 530i");
    });
});

SpecEnd
