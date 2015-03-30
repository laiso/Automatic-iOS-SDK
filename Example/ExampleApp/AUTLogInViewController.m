//
//  AUTLogInViewController.m
//  AutomaticSDK
//
//  Created by Eric Horacek on 3/16/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <AutomaticSDK/AutomaticSDK.h>
#import <libextobjc/EXTScope.h>
#import "AUTLogInViewController.h"
#import "AUTLogInView.h"

@interface AUTLogInViewController ()

@property (nonatomic, readonly) void (^success)();
@property (nonatomic, readonly) void (^failure)(NSError *);
@property (nonatomic) AUTLogInView *view;

@end

@implementation AUTLogInViewController

#pragma mark - UIViewController

- (void)loadView {
    self.view = [AUTLogInView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view.logInButton addTarget:self action:@selector(logIn:) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - AUTLogInViewController

- (instancetype)initWithClient:(AUTClient *)client success:(void(^)())success failure:(void(^)(NSError *))failure {
    NSParameterAssert(client != nil);
    NSParameterAssert(success != nil);
    NSParameterAssert(failure != nil);
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _client = client;
        _success = success;
        _failure = failure;
    }
    return self;
}

- (void)logIn:(id)sender {
    @weakify(self);
    [self.client
        authorizeWithScopes:(AUTClientScopesTrip | AUTClientScopesLocation)
        success:^{
            @strongify(self);
            self.success();
        }
        failure:^(NSError *error) {
            @strongify(self);
            self.failure(error);
        }];
}

@end
