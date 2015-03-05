//
//  AUTClient+VehicleSpec.m
//  AutomaticSDK
//
//  Created by Robert Böhnke on 10/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <Nocilla/Nocilla.h>

#import "AUTClient+Vehicle.h"

SpecBegin(AUTClient_Vehicle)

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

describe(@"-fetchVehiclesForCurrentUserWithSuccess:failure:", ^{
    it(@"should fetch a list of vehicles", ^{
        stubRequest(@"GET", @"https://api.automatic.com/vehicle/")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"_metadata\": {"
                    "\"count\": 2,"
                    "\"next\": null,"
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
                    "},"
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

        __block NSDictionary *vehiclePage;

        waitUntil(^(DoneCallback done) {
            [client
                fetchVehiclesForCurrentUserWithSuccess:^(NSDictionary *dictionary) {
                    vehiclePage = dictionary;
                    done();
                }
                failure:nil];
        });

        NSArray *results = vehiclePage[@"results"];

        expect(results).to.haveCountOf(2);
        expect(results[0][@"display_name"]).to.equal(@"Ford Mustang");
    });
});

describe(@"-fetchVehiclesForUserWithID:success:failure:", ^{
    it(@"should fetch a list of vehicles", ^{
        stubRequest(@"GET", @"https://api.automatic.com/user/U_acdbcbbe83d3c554/vehicle/")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"_metadata\": {"
                    "\"count\": 2,"
                    "\"next\": null,"
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
                    "},"
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

        __block NSDictionary *vehiclePage;

        waitUntil(^(DoneCallback done) {
            [client
                fetchVehiclesForUserWithID:@"U_acdbcbbe83d3c554"
                success:^(NSDictionary *dictionary) {
                    vehiclePage = dictionary;
                    done();
                }
                failure:nil];
        });

        NSArray *results = vehiclePage[@"results"];

        expect(results).to.haveCountOf(2);
        expect(results[0][@"display_name"]).to.equal(@"Ford Mustang");
    });
});

describe(@"-fetchVehiclesForUserWithID:success:failure:", ^{
    it(@"should fetch a list of vehicles", ^{
        stubRequest(@"GET", @"https://api.automatic.com/vehicle/C_512006d79b5dbf99/")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"url\": \"https://api.automatic.com/vehicle/C_512006d79b5dbf99/\","
                "\"id\": \"C_512006d79b5dbf99\","
                "\"make\": \"BMW\","
                "\"model\": \"530i\","
                "\"year\": 1995,"
                "\"submodel\": \"Base\","
                "\"color\": null,"
                "\"display_name\": \"BMW 530i\""
            "}");

        __block NSDictionary *vehicle;

        waitUntil(^(DoneCallback done) {
            [client
                fetchVehicleWithID:@"C_512006d79b5dbf99"
                success:^(NSDictionary *dictionary) {
                    vehicle = dictionary;
                    done();
                }
                failure:nil];
        });

        expect(vehicle[@"display_name"]).to.equal(@"BMW 530i");
    });
});

SpecEnd
