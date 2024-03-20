/**
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "GoogleSignInAppController.h"
#import <objc/runtime.h>
#import <GoogleSignIn/GoogleSignIn.h>

// Handles Google SignIn UI and events.
GoogleSignInHandler *gsiHandler;

/*
 * Create a category to customize the application.  When this is loaded the
 * method for the existing application and  GoogleSignIn are swizzled into the
 * other's class selector.  Then we call our "own" msthod which is actually the
 * original application's implementation. See more info at:
 * https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html
 */

@implementation UnityAppController (GoogleSignInController)

/*
 Called when the category is loaded.  This is where the methods are swizzled
 out.
 */
+ (void)load {
  Method original;
  Method swizzled;

  original = class_getInstanceMethod(
      self, @selector(application:didFinishLaunchingWithOptions:));
  swizzled = class_getInstanceMethod(
      self,
      @selector(GoogleSignInAppController:didFinishLaunchingWithOptions:));
  method_exchangeImplementations(original, swizzled);

  original = class_getInstanceMethod(
      self, @selector(application:openURL:sourceApplication:annotation:));
  swizzled = class_getInstanceMethod(
      self, @selector
      (GoogleSignInAppController:openURL:sourceApplication:annotation:));
  method_exchangeImplementations(original, swizzled);

  original =
      class_getInstanceMethod(self, @selector(application:openURL:options:));
  swizzled = class_getInstanceMethod(
      self, @selector(GoogleSignInAppController:openURL:options:));
  method_exchangeImplementations(original, swizzled);
}
//***************************
//- (BOOL)GoogleSignInAppController:(UIApplication *)application
//    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//
//  // IMPORTANT: IF you are not supplying a GoogleService-Info.plist in your
//  // project that contains the client id, you need to set the client id here.
//
//  NSString *path = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info"
//                                                   ofType:@"plist"];
//  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
//  NSString *clientId = [dict objectForKey:@"CLIENT_ID"];
//
//  gsiHandler = [GoogleSignInHandler alloc];
//
//  // Setup the Sign-In instance.
//  GIDSignIn *signIn = [GIDSignIn sharedInstance];
//  signIn.clientID = clientId;
//  signIn.delegate = gsiHandler;
// looks like it's just calling itself, but the implementations were swapped
// so we're actually calling the original once we're done
//return [self GoogleSignInAppController:application
//         didFinishLaunchingWithOptions:launchOptions];
//}
//******************************
  
- (BOOL)GoogleSignInAppController:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *clientId = dict[@"CLIENT_ID"];
    
    //gsiHandler = [[GoogleSignInHandler alloc] init];
    
    // GIDSignIn의 clientID 및 delegate 설정 코드를 제거하고,
    // GIDConfiguration과 콜백을 사용한 로그인 구성으로 대체합니다.
    GIDConfiguration *configuration = [[GIDConfiguration alloc] initWithClientID:clientId];
    return YES;
}

    // 이제 로그인 버튼이 눌렸을 때 호출될 로직에 다음과 같이 구현합니다.
    // 예를 들어, 사용자가 로그인 버튼을 누를 때 이 메서드를 호출하도록 설정할 수 있습니다.
    // 아래는 단순히 앱이 시작될 때 로그인을 시도하는 예시 코드입니다.
- (void)signInWithGoogle {
    GIDConfiguration *configuration = [[GIDConfiguration alloc] initWithClientID:@"YOUR_CLIENT_ID"];

    [[GIDSignIn sharedInstance] signInWithConfiguration:configuration
        presentingViewController:self.window.rootViewController
        callback:^(GIDGoogleUser * _Nullable user, NSError * _Nullable error) {
            if (error) {
                // 에러 처리
                return;
            }
            // 성공적인 로그인 후의 처리
        }];
}

/**
 * Handle the auth URL
 */
- (BOOL)GoogleSignInAppController:(UIApplication *)application
                          openURL:(NSURL *)url
                sourceApplication:(NSString *)sourceApplication
                       annotation:(id)annotation {
  BOOL handled = [self GoogleSignInAppController:application
                                         openURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];

  return [[GIDSignIn sharedInstance] handleURL:url] ||
         handled;
}

/**
 * Handle the auth URL.
 */
- (BOOL)GoogleSignInAppController:(UIApplication *)app
                          openURL:(NSURL *)url
                          options:(NSDictionary *)options {

  BOOL handled =
      [self GoogleSignInAppController:app openURL:url options:options];

  return [[GIDSignIn sharedInstance] handleURL:url] ||
         handled;
}

@end
