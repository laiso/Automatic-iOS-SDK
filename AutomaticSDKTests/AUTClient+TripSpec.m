//
//  AUTTripSpec.m
//  AutomaticSDK
//
//  Created by Robert Böhnke on 10/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <Nocilla/Nocilla.h>

#import "AUTClient+Trip.h"

SpecBegin(AUTTrip)

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

describe(@"-fetchTripsForCurrentUserWithSuccess:failure:", ^{
    it(@"should fetch a list of trips", ^{
        stubRequest(@"GET", @"https://api.automatic.com/trip/")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"_metadata\": {"
                    "\"count\": 1,"
                    "\"next\": null,"
                    "\"previous\": null"
                "},"
                "\"results\": ["
                    "{"
                        "\"url\": \"https://api.automatic.com/trip/T_37957a8a27db3e3e/\","
                        "\"id\": \"T_37957a8a27db3e3e\","
                        "\"user\": \"https://api.automatic.com/user/U_acdbcbbe83d3c554/\","
                        "\"started_at\": \"2015-02-26T01:56:52.600000Z\","
                        "\"ended_at\": \"2015-02-26T01:57:24.600000Z\","
                        "\"distance_m\": 1455.3,"
                        "\"duration_s\": 32,"
                        "\"vehicle\": \"https://api.automatic.com/vehicle/C_2a8220e75a88be75/\","
                        "\"start_location\": {"
                            "\"lon\": -0.99196,"
                            "\"accuracy_m\": 5005,"
                            "\"lat\": 51.98931"
                        "},"
                        "\"start_address\": {"
                            "\"name\": \"Unknown\","
                            "\"display_name\": null,"
                            "\"street_number\": null,"
                            "\"street_name\": null,"
                            "\"state\": null,"
                            "\"city\": null,"
                            "\"country\": null"
                        "},"
                        "\"end_location\": {"
                            "\"lon\": -122.40993,"
                            "\"accuracy_m\": 65,"
                            "\"lat\": 37.76194"
                        "},"
                        "\"end_address\": {"
                            "\"name\": \"Unknown\","
                            "\"display_name\": null,"
                            "\"street_number\": null,"
                            "\"street_name\": null,"
                            "\"state\": null,"
                            "\"city\": null,"
                            "\"country\": null"
                        "},"
                        "\"path\": null,"
                        "\"fuel_cost_usd\": 0.14,"
                        "\"fuel_volume_l\": 0,"
                        "\"average_kmpl\": 9.4,"
                        "\"score\": null,"
                        "\"hard_brakes\": 0,"
                        "\"hard_accels\": 0,"
                        "\"duration_over_70_s\": 31,"
                        "\"duration_over_75_s\": 31,"
                        "\"duration_over_80_s\": 31,"
                        "\"vehicle_events\": ["
                            "{"
                                "\"type\": \"speeding\","
                                "\"started_at\": \"2015-02-26T01:56:52Z\","
                                "\"end_distance_m\": 1455,"
                                "\"ended_at\": \"2015-02-26T01:57:23Z\","
                                "\"start_distance_m\": 0,"
                                "\"velocity_kph\": 128.75"
                            "}"
                        "],"
                        "\"start_timezone\": \"US/Pacific\","
                        "\"end_timezone\": \"US/Pacific\""
                    "}"
                "]"
            "}");

        __block NSDictionary *tripsPage;

        waitUntil(^(DoneCallback done) {
            [client fetchTripsForCurrentUserWithSuccess:^(NSDictionary *tripsDictionary) {
                tripsPage = tripsDictionary;
                done();
            } failure:nil];
        });

        expect(tripsPage).notTo.beNil();
        expect(tripsPage[@"results"]).to.haveCountOf(1);
    });
});

describe(@"-fetchTripsForUserWithID:success:failure:", ^{
    it(@"should fetch a list of trips", ^{
        stubRequest(@"GET", @"https://api.automatic.com/user/U_acdbcbbe83d3c554/trip/")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"_metadata\": {"
                    "\"count\": 1,"
                    "\"next\": null,"
                    "\"previous\": null"
                "},"
                "\"results\": ["
                    "{"
                        "\"url\": \"https://api.automatic.com/trip/T_37957a8a27db3e3e/\","
                        "\"id\": \"T_37957a8a27db3e3e\","
                        "\"user\": \"https://api.automatic.com/user/U_acdbcbbe83d3c554/\","
                        "\"started_at\": \"2015-02-26T01:56:52.600000Z\","
                        "\"ended_at\": \"2015-02-26T01:57:24.600000Z\","
                        "\"distance_m\": 1455.3,"
                        "\"duration_s\": 32,"
                        "\"vehicle\": \"https://api.automatic.com/vehicle/C_2a8220e75a88be75/\","
                        "\"start_location\": {"
                            "\"lon\": -0.99196,"
                            "\"accuracy_m\": 5005,"
                            "\"lat\": 51.98931"
                        "},"
                        "\"start_address\": {"
                            "\"name\": \"Unknown\","
                            "\"display_name\": null,"
                            "\"street_number\": null,"
                            "\"street_name\": null,"
                            "\"state\": null,"
                            "\"city\": null,"
                            "\"country\": null"
                        "},"
                        "\"end_location\": {"
                            "\"lon\": -122.40993,"
                            "\"accuracy_m\": 65,"
                            "\"lat\": 37.76194"
                        "},"
                        "\"end_address\": {"
                            "\"name\": \"Unknown\","
                            "\"display_name\": null,"
                            "\"street_number\": null,"
                            "\"street_name\": null,"
                            "\"state\": null,"
                            "\"city\": null,"
                            "\"country\": null"
                        "},"
                        "\"path\": null,"
                        "\"fuel_cost_usd\": 0.14,"
                        "\"fuel_volume_l\": 0,"
                        "\"average_kmpl\": 9.4,"
                        "\"score\": null,"
                        "\"hard_brakes\": 0,"
                        "\"hard_accels\": 0,"
                        "\"duration_over_70_s\": 31,"
                        "\"duration_over_75_s\": 31,"
                        "\"duration_over_80_s\": 31,"
                        "\"vehicle_events\": ["
                            "{"
                                "\"type\": \"speeding\","
                                "\"started_at\": \"2015-02-26T01:56:52Z\","
                                "\"end_distance_m\": 1455,"
                                "\"ended_at\": \"2015-02-26T01:57:23Z\","
                                "\"start_distance_m\": 0,"
                                "\"velocity_kph\": 128.75"
                            "}"
                        "],"
                        "\"start_timezone\": \"US/Pacific\","
                        "\"end_timezone\": \"US/Pacific\""
                    "}"
                "]"
            "}");

        __block NSDictionary *tripsPage;

        waitUntil(^(DoneCallback done) {
            [client
                fetchTripsForUserWithID:@"U_acdbcbbe83d3c554"
                success:^(NSDictionary *tripsDictionary) {
                    tripsPage = tripsDictionary;
                    done();
                }
                failure:nil];
        });

        expect(tripsPage).notTo.beNil();
        expect(tripsPage[@"results"]).to.haveCountOf(1);
    });
});

describe(@"-fetchTripWithID:success:failure:", ^{
    it(@"should fetch a trip", ^{
        stubRequest(@"GET", @"https://api.automatic.com/trip/T_37957a8a27db3e3e/")
            .withHeader(@"Authorization", @"Bearer ACCESS_TOKEN")
            .andReturn(200)
            .withHeader(@"Content-type", @"application/json")
            .withBody(@"{"
                "\"url\": \"https://api.automatic.com/trip/T_37957a8a27db3e3e/\","
                "\"id\": \"T_37957a8a27db3e3e\","
                "\"user\": \"https://api.automatic.com/user/U_acdbcbbe83d3c554/\","
                "\"started_at\": \"2015-02-26T01:56:52.600000Z\","
                "\"ended_at\": \"2015-02-26T01:57:24.600000Z\","
                "\"distance_m\": 1455.3,"
                "\"duration_s\": 32,"
                "\"vehicle\": \"https://api.automatic.com/vehicle/C_2a8220e75a88be75/\","
                "\"start_location\": {"
                    "\"lon\": -0.99196,"
                    "\"accuracy_m\": 5005,"
                    "\"lat\": 51.98931"
                "},"
                "\"start_address\": {"
                    "\"name\": \"Unknown\","
                    "\"display_name\": null,"
                    "\"street_number\": null,"
                    "\"street_name\": null,"
                    "\"state\": null,"
                    "\"city\": null,"
                    "\"country\": null"
                "},"
                "\"end_location\": {"
                    "\"lon\": -122.40993,"
                    "\"accuracy_m\": 65,"
                    "\"lat\": 37.76194"
                "},"
                "\"end_address\": {"
                    "\"name\": \"Unknown\","
                    "\"display_name\": null,"
                    "\"street_number\": null,"
                    "\"street_name\": null,"
                    "\"state\": null,"
                    "\"city\": null,"
                    "\"country\": null"
                "},"
                "\"path\": null,"
                "\"fuel_cost_usd\": 0.14,"
                "\"fuel_volume_l\": 0,"
                "\"average_kmpl\": 9.4,"
                "\"score\": null,"
                "\"hard_brakes\": 0,"
                "\"hard_accels\": 0,"
                "\"duration_over_70_s\": 31,"
                "\"duration_over_75_s\": 31,"
                "\"duration_over_80_s\": 31,"
                "\"vehicle_events\": ["
                    "{"
                        "\"type\": \"speeding\","
                        "\"started_at\": \"2015-02-26T01:56:52Z\","
                        "\"end_distance_m\": 1455,"
                        "\"ended_at\": \"2015-02-26T01:57:23Z\","
                        "\"start_distance_m\": 0,"
                        "\"velocity_kph\": 128.75"
                    "}"
                "],"
                "\"start_timezone\": \"US/Pacific\","
                "\"end_timezone\": \"US/Pacific\""
            "}");

        __block NSDictionary *trip;

        waitUntil(^(DoneCallback done) {
            [client
             fetchTripWithID:@"T_37957a8a27db3e3e"
             success:^(NSDictionary *tripsDictionary) {
                 trip = tripsDictionary;
                 done();
             }
             failure:nil];
        });

        expect(trip).notTo.beNil();
        expect(trip[@"id"]).to.equal(@"T_37957a8a27db3e3e");
    });
});

SpecEnd
