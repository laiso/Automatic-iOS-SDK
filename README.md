# Automatic iOS SDK

[![Build Status](https://travis-ci.org/Automatic/Automatic-iOS-SDK.svg?branch=master)](https://travis-ci.org/Automatic/Automatic-iOS-SDK)

---

**Note: This SDK is in alpha. Please try it out and send us your feedback!**

---

The Automatic SDK is the best way to build iOS apps powered by [Automatic](automatic.com).

With the Automatic iOS SDK, your users can log in to your app with their [Automatic](automatic.com) accounts. Think _Facebook_ or _Twitter_ login—but rather than bringing a users' social graph, instead unlocking a wealth of automotive data that you can use to supercharge your app.

<img src='https://github.com/automatic/Automatic-iOS-SDK/blob/master/README/log-in-with-automatic-button.png?raw=true' alt='Log in with Automatic' height='100' width='300'/>
> Pictured: your app's new login screen

Once a user approves your app's request to access their data, your app could:

- Access your users' trips to analyze driving habits
- Query your users' cars to provide up-to-date resale values estimates
- Populate your users' profiles without a lengthy signup form
- :sparkles: _so much more_ :sparkles:

We can't wait to see what you build. Let's get to it!

## Usage

### 1. Register your app with Automatic

1. Register your app on the [Automatic Developer site][developers].  
2. Once your app is approved, make note of its _Client ID_ and _Client Secret_.
   Make sure to use a redirect URL scheme that follows this pattern:  
   `automatic-[client-id]://oauth`.

### 2. Integrating the Automatic iOS SDK

1. Integrate the _Automatic iOS SDK_. We recommend using CocoaPods, which makes
   integration as easy as adding

   ```ruby
   pod "AutomaticSDK", "0.0.1"
   ```

   to your Podfile.
2. [Configure your app][url-scheme-howto] to use the URL scheme you decided on
   earlier. You can do this by adding this to your `Info.plist` file. If your
   Client ID was for example `123abc`, it would look like this:

   ```xml
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>automatic-123abc</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>automatic-123abc</string>
            </array>
        </dict>
    </array>
   ```

### 3. Make Authorization requests and handle them

1. Create an instance of `AUTClient` with your _Client ID_ and _Client Secret_.

   ```objc
   AUTClient *client = [[AUTClient alloc] initWithClientID:@"CLIENT_ID" clientSecret:@"CLIENT_SECRET"];
   ```
2. When you're ready to authorize your app with the Automatic API, call
   `-[AUTClient authorizeWithScopes:success:failure:]` to have the SDK open
   Safari for you:

   ```objc
   [self.client
       authorizeWithScopes:AUTClientScopesTrip | AUTClientScopesLocation
       success:^{
           NSLog(@"🎉 Your app is now authorized. 🎉");
       }
       failure:^(NSError *error) {
           NSLog(@"Failed to log in with error: %@", error.localizedDescription);
       }];
   ```

3. Implement [`-application:openURL:sourceApplication:annotation:`][handler] to
   handle your custom URL scheme that Automatic will redirect to, once a user
   has given your app access:

   ```objc
   - (BOOL)application:(UIApplication *)application openURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
      if ([self.client handleOpenURL:URL]) {
          return YES;
      }

      return NO;
   }

   ```

4. Once your client is authorized, you can store its credentials in the keychain
   using `AFOAuthCredential`:

   ```objc
   [AFOAuthCredential storeCredential:self.client.credential withIdentifier:@"credential"];
   ```

### 4. Make requests against the Automatic API

You can now make requests against the Automatic API on behalf of your user:

```objc
[self.client
     fetchTripsForCurrentUserWithSuccess:^(NSDictionary *page){
         NSArray *trips = page[@"results"];
         
         // Do something cool with the trip data here.
     }
     failure:^(NSError *error){
         NSLog(@"Something went wrong.");
     }];
```

[developers]: https://developer.automatic.com
[url-scheme-howto]: https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html#//apple_ref/doc/uid/TP40007072-CH6-SW10
[handler]: https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/#//apple_ref/occ/intfm/UIApplicationDelegate/application:openURL:sourceApplication:annotation:
