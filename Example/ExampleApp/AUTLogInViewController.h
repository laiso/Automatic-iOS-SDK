//
//  AUTLogInViewController.h
//  AutomaticSDK
//
//  Created by Eric Horacek on 3/16/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AUTClient;

@interface AUTLogInViewController : UIViewController

- (instancetype)initWithClient:(AUTClient *)client success:(void(^)())success failure:(void(^)(NSError *))failure;

@property (nonatomic, readonly) AUTClient *client;

@end
