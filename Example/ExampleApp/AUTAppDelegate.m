//
//  AUTAppDelegate.m
//  ExampleApp
//
//  Created by Robert Böhnke on 13/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <AutomaticSDK/AutomaticSDK.h>
#import <libextobjc/EXTScope.h>

#import "AUTAppDelegate.h"
#import "AUTTripListController.h"
#import "AUTLogInViewController.h"

#define CLIENT_ID \
    _Pragma("GCC error \"Put your client ID here. Find it on https://developer.automatic.com\"") @""

#define CLIENT_SECRET \
    _Pragma("GCC error \"Put your client secret here. Find it on https://developer.automatic.com\"") @""

@interface AUTAppDelegate ()

@property (readwrite, nonatomic, strong) AUTClient *client;

@property (readwrite, nonatomic, strong) AUTTripListController *tripController;
@property (readwrite, nonatomic, strong) UINavigationController *navigationController;
@property (readwrite, nonatomic, strong) AUTLogInViewController *logInController;

@end

@implementation AUTAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.client = [[AUTClient alloc] initWithClientID:CLIENT_ID clientSecret:CLIENT_SECRET];

    NSURL *authorizationCallbackURL = [NSURL URLWithString:[NSString stringWithFormat:@"automatic-%@://oauth", CLIENT_ID]];
    if (![UIApplication.sharedApplication canOpenURL:authorizationCallbackURL]) {
        NSAssert(NO, @"You must register the %@ URL scheme to open your app.", authorizationCallbackURL.scheme);
    }
    
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:@"credential"];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = (credential ? self.navigationController : self.logInController);
    [self.window makeKeyAndVisible];

    if (credential) {
        @weakify(self);
        if (credential.isExpired) {
            [self.client
                authorizeByRefreshingCredential:credential
                success:^{
                    @strongify(self);
                    [AFOAuthCredential storeCredential:self.client.credential withIdentifier:@"credential"];
                    [self.tripController refresh:self];
                }
                failure:^(NSError *error) {
                    NSLog(@"Failed to refresh credential with error: %@", error.localizedDescription);
                }];
        } else {
            self.client.credential = credential;
            [self.tripController refresh:self];
        }
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self.client handleOpenURL:URL]) {
        return YES;
    }
    // Handle your other URLs...
    return NO;
}

#pragma mark - AUTAppDelegate

- (AUTLogInViewController *)logInController {
    if (_logInController == nil) {
        @weakify(self);
        _logInController = [[AUTLogInViewController alloc]
            initWithClient:self.client
            success:^{
                @strongify(self);
                [AFOAuthCredential storeCredential:self.client.credential withIdentifier:@"credential"];
                // Transition the app to the logged in state
                self.window.rootViewController = self.navigationController;
                [self.tripController refresh:self];
            } failure:^(NSError *error) {
                NSLog(@"Failed to log in with error: %@", error.localizedDescription);
            }];
    }
    return _logInController;
}

- (UINavigationController *)navigationController {
    if (_navigationController == nil) {
        self.navigationController = [[UINavigationController alloc]
            initWithRootViewController:self.tripController];
    }
    return _navigationController;
}

- (AUTTripListController *)tripController {
    if (_tripController == nil) {
        self.tripController = [[AUTTripListController alloc] initWithClient:self.client];
        self.tripController.title = @"Your Trips";
        self.tripController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:@"Log out"
            style:UIBarButtonItemStyleDone
            target:self
            action:@selector(logOut:)];
    }
    return _tripController;
}

- (void)logOut:(id)sender {
    self.client.credential = nil;
    
    // Delete the persisted credential
    [AFOAuthCredential deleteCredentialWithIdentifier:@"credential"];
    
    // Transition the app to the logged out state
    self.window.rootViewController = self.logInController;
}

@end
