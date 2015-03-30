//
//  AUTClient.h
//  AutomaticSDK
//
//  Created by Robert Böhnke on 05/03/15.
//  Copyright (c) 2015 Automatic Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

// Allow the use of nullability attributes while keeping compatibility with
// Xcode 6.1 and 6.2
#if __has_feature(nullability)
#define aut_nonnull nonnull
#define aut_nullable nullable
#define aut_null_unspecified null_unspecified
#define __aut_nonnull __nonnull
#define __aut_nullable __nullable
#define __aut_null_unspecified __null_unspecified
#else
#define aut_nonnull
#define aut_nullable
#define aut_null_unspecified
#define __aut_nonnull
#define __aut_nullable
#define __aut_null_unspecified
#endif

#pragma clang assume_nonnull begin

@class AFHTTPRequestOperation;
@class AFHTTPRequestOperationManager;
@class AFOAuthCredential;

/**
 *  The different scopes an `AUTClient` can request.
 */
typedef NS_OPTIONS(NSUInteger, AUTClientScopes){
    /**
     *  Access to public information about user.
     */
    AUTClientScopesPublic          = 1 << 0,
    /**
     *  Access to user's profile (i.e. `first_name`, `last_name`).
     */
    AUTClientScopesUserProfile     = 1 << 1,
    /**
     *  Ability to follow other users.
     */
    AUTClientScopesUserFollow      = 1 << 2,
    /**
     *  Access to historical location. Applies to all events.
     */
    AUTClientScopesLocation        = 1 << 3,
    /**
     *  Access to user's current location.
     */
    AUTClientScopesCurrentLocation = 1 << 4,
    /**
     *  Access to vehicle information (i.e. `year`, `make`, `model`). Applies to
     *  all events.
     */
    AUTClientScopesVehicleProfile  = 1 << 5,
    /**
     *  Access to real-time vehicle events (i.e. `hard_brake`, `hard_accel`).
     */
    AUTClientScopesVehicleEvents   = 1 << 6,
    /**
     *  Access to vehicle VIN.
     */
    AUTClientScopesVehicleVIN      = 1 << 7,
    /**
     *  Access to user's trips.
     *
     *  _Note:_ the Trip endpoint requires many scopes to get the complete set
     *  of data. `AUTClientScopesTrip` alone does not give very much, but is
     *  required to get anything in the Trip object.
     */
    AUTClientScopesTrip            = 1 << 8,
    /**
     *  Access to user's driving profile.
     */
    AUTClientScopesBehavior        = 1 << 9
};

/**
 *  The error domain for all errors originating in AUTClient.
 */
extern NSString * const AUTClientErrorDomain;

/**
 *  Authorization could not be completed.
 */
extern const NSInteger AUTClientErrorAuthorizationFailed;

/**
 *  `AUTClient` allows you to authenticate with the Automatic API and make
 *  requests to it.
 */
@interface AUTClient : NSObject

/**
 *  Your application's client ID.
 */
@property (readonly, nonatomic, copy) NSString *clientID;

/**
 *  Your application's client secret.
 */
@property (readonly, nonatomic, copy) NSString *clientSecret;

/**
 *  The `AFOAuthCredential` credentials used by the `requestManager`.
 *  Setting this property with update the `requestManager`s `Authorization`
 *  header accordingly.
 *
 *  See +[AFOAuthCredential storeCredential:withIdentifier:] on information how
 *  to persist this credential.
 */
@property (readwrite, nonatomic, strong, aut_nullable) AFOAuthCredential *credential;

/**
 *  The `AFHTTPRequestOperationManager` used by the client.
 *
 *  You can use this request manager to make additional API requests if need be.
 */
@property (readonly, nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

/**
 *  Initializes a new `AUTClient`.
 *
 *  @param clientID     Your application's client ID. This argument must not be
 *                      `nil`.
 *  @param clientSecret Your application's client secret. This argument must not
 *                      be `nil`.
 *
 *  @return A new `AUTClient` instance.
 */
- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret NS_DESIGNATED_INITIALIZER;

/**
 *  Creates a new URL for authenticating the client.
 *
 *  Open this URL in Safari.app to authenticate the user.
 *
 *  @param scopes The scopes you want to authorize the client with.
 *
 *  @return A URL that requests the given scopes for the receiver.
 */
- (NSURL *)URLForAuthorizationWithScopes:(AUTClientScopes)scopes;

/**
 *  Authorizes the receiver through Safari.
 *
 *  @param scopes The scopes you want to authorize the client with.
 *  @param success A block to be invoked when the authorization was successful.
 *                 The receiver's `credential` will be set by the time the block
 *                 is invoked.
 *  @param failure A block to be invoked with an error if the authorization
 *                 fails.
 */
- (void)authorizeWithScopes:(AUTClientScopes)scopes success:(aut_nullable void(^)(void))success failure:(aut_nullable void(^)(__aut_nullable NSError *))failure;

/**
 *  Complete the authorization flow by calling this method.
 *
 *  This method should only be called from 
 *  -[UIApplicationDelegate openURL:sourceApplication:annotation:]
 *
 *  @param openURL The URL your application was called with.
 *
 *  @return `YES` if the receiver could handle the URL, `NO` otherwise.
 */
- (BOOL)handleOpenURL:(NSURL *)URL;

/**
 *  Authorize the receiver by refreshing existing `AFOAuthCredential`.
 *
 *  @param credential The credential to refresh the receiver with. This argument
 *                    must not be `nil`.
 *  @param success    A block to be invoked when the authorization was
 *                    successful. The receiver's `credential` will be set by
 *                    the time the block is invoked.
 *  @param failure    A block to be invoked with an error if the authorization
 *                    fails.
 */
- (void)authorizeByRefreshingCredential:(AFOAuthCredential *)credential success:(aut_nullable void(^)(void))success failure:(aut_nullable void(^)(__aut_nullable NSError *))failure;

@end

/**
 *  Converts a block that takes an `NSDictionary` as its only argument into one
 *  that can be used as a success callback with `AFHTTPRequestOperationManager`.
 *
 *  @param ^block The block to convert.
 *
 *  @return A block that can be used as a success callback to
 *          `AFHTTPRequestOperationManager` or `nil` if the block was `nil`.
 */
extern void (^__aut_nullable AUTExtractResponseObject(void (^__aut_nullable block)(__aut_nullable NSDictionary *)))(__aut_nullable AFHTTPRequestOperation *, __aut_nullable id);

/**
 *  Converts a block that takes an `NSError *` as its only argument into one
 *  that can be used as a failure callback with `AFHTTPRequestOperationManager`.
 *
 *  @param ^block The block to convert.
 *
 *  @return A block that can be used as a failure callback to
 *          `AFHTTPRequestOperationManager` or `nil` if the block was `nil`.
 */
extern void (^__aut_nullable AUTExtractError(void (^__aut_nullable block)(__aut_nullable NSError *)))(__aut_nullable AFHTTPRequestOperation *, __aut_nullable NSError *);

#pragma clang assume_nonnull end
