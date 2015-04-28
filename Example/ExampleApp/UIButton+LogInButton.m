//
//  UIButton+LogInButton.m
//  ExampleApp
//
//  Created by Eric Horacek on 3/16/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import "UIButton+LogInButton.h"

@implementation UIButton (LogInButton)

+ (instancetype)aut_logInButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor colorWithRed:0.33f green:0.71f blue:0.92f alpha:1.0f];
    button.tintColor = [UIColor whiteColor];
    button.layer.cornerRadius = 5.0;
    
    CGFloat imageTextPadding = 13.0;
    CGFloat horizontalInset = 15.0;
    CGFloat verticalInset = 7.0;
    
    button.titleEdgeInsets = (UIEdgeInsets){
        .left = imageTextPadding,
        .right = -imageTextPadding
    };
    
    button.contentEdgeInsets = (UIEdgeInsets){
        .top = verticalInset,
        .left = horizontalInset,
        .bottom = verticalInset,
        .right = imageTextPadding + horizontalInset
    };
    
    button.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0];
    
    [button setImage:[UIImage imageNamed:@"AutomaticLogo"] forState:UIControlStateNormal];
    [button setTitle:@"Log in with Automatic" forState:UIControlStateNormal];
    
    return button;
}

@end
