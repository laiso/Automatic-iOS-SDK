//
//  AUTTripListController.h
//  ExampleApp
//
//  Created by Robert Böhnke on 13/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AUTClient;

@interface AUTTripListController : UITableViewController

- (instancetype)initWithClient:(AUTClient *)client NS_DESIGNATED_INITIALIZER;

@property (readonly, nonatomic, strong) AUTClient *client;

- (void)refresh:(id)sender;

- (void)fetchMore:(id)sender;

@end
