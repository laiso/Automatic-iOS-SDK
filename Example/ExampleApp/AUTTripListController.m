//
//  AUTTripListController.m
//  ExampleApp
//
//  Created by Robert Böhnke on 13/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <AutomaticSDK/AutomaticSDK.h>
#import <libextobjc/EXTScope.h>

#import "AUTTripListController.h"

@interface AUTTripListController ()

@property (readwrite, nonatomic, strong) AFHTTPRequestOperation *currentRequest;

@property (readwrite, nonatomic, strong) NSURL *nextPageURL;

@property (readwrite, nonatomic, copy) NSArray *results;

@end

@implementation AUTTripListController

#pragma mark - Lifecycle

- (instancetype)initWithClient:(AUTClient *)client {
    NSParameterAssert(client != nil);

    self = [super initWithStyle:UITableViewStylePlain];
    if (self == nil) return nil;

    _client = client;
    _results = @[];

    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return [self initWithClient:nil];
}

#pragma mark - Properties

- (void)setResults:(NSArray *)results {
    _results = [results copy];

    if (self.isViewLoaded && self.view.window) {
        [self.tableView reloadData];
    }
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - AUTTripController

- (void)refresh:(id)sender {
    [self.refreshControl beginRefreshing];

    if (self.currentRequest.isExecuting) {
        [self.currentRequest cancel];

        self.currentRequest = nil;
        self.nextPageURL = nil;
    }

    @weakify(self);
    self.currentRequest = [self.client
        fetchTripsForCurrentUserWithSuccess:^(NSDictionary *page){
            @strongify(self);

            [self.refreshControl endRefreshing];

            self.results = page[@"results"];

            id nextPage = page[@"_metadata"][@"next"];

            if (nextPage == NSNull.null || nextPage == nil) {
                self.nextPageURL = nil;
            } else {
                self.nextPageURL = [NSURL URLWithString:nextPage];
            }
        }
        failure:^(NSError *error){
            [self.refreshControl endRefreshing];
        }];
}

- (void)fetchMore:(id)sender {
    if (self.currentRequest.isExecuting) return;

    @weakify(self);
    self.currentRequest = [self.client
        fetchPage:self.nextPageURL
        success:^(NSDictionary *page) {
            @strongify(self);

            [self.refreshControl endRefreshing];

            NSArray *results = page[@"results"];

            self.results = [self.results arrayByAddingObjectsFromArray:results];

            id nextPage = page[@"_metadata"][@"next"];

            if (nextPage == NSNull.null || nextPage == nil) {
                self.nextPageURL = nil;
            } else {
                self.nextPageURL = [NSURL URLWithString:nextPage];
            }
        }
        failure:^(NSError *error){
            [self.refreshControl endRefreshing];
        }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];

    NSDictionary *trip = self.results[indexPath.row];
    
    NSString *(^streetNameFromKeyPath)(NSString *) = ^NSString *(NSString *keyPath) {
        id streetName = [trip valueForKeyPath:keyPath];
        return (streetName != nil && streetName != NSNull.null) ? streetName : @"Unknown";
    };
    
    NSString *from = streetNameFromKeyPath(@"start_address.street_name");
    NSString *to = streetNameFromKeyPath(@"end_address.street_name");

    cell.textLabel.text = [NSString stringWithFormat:@"From %@ to %@", from, to];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Fetch more when the last row is displayed
    NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
    BOOL isLastRow = numberOfRows > 0 && (numberOfRows - 1) == indexPath.row;
    if (isLastRow && self.nextPageURL != nil) {
        [self fetchMore:self];
    }
}

@end
