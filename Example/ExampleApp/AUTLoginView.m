//
//  AUTLogInView.m
//  ExampleApp
//
//  Created by Eric Horacek on 3/16/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import "AUTLogInView.h"
#import "UIButton+LogInButton.h"

@implementation AUTLogInView

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.logInButton];
        self.backgroundColor = [UIColor
            colorWithRed:0.19
            green:0.20
            blue:0.21
            alpha:1.0];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self addConstraint:[NSLayoutConstraint
        constraintWithItem:self.logInButton
        attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual
        toItem:self
        attribute:NSLayoutAttributeCenterX
        multiplier:1.0
        constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint
        constraintWithItem:self.logInButton
        attribute:NSLayoutAttributeCenterY
        relatedBy:NSLayoutRelationEqual
        toItem:self
        attribute:NSLayoutAttributeCenterY
        multiplier:1.0
        constant:0.0]];
}

#pragma mark - AUTLogInView

@synthesize logInButton = _logInButton;

- (UIButton *)logInButton {
    if (_logInButton == nil) {
        UIButton *button = [UIButton aut_logInButton];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        _logInButton = button;
    }
    return _logInButton;
}

@end
