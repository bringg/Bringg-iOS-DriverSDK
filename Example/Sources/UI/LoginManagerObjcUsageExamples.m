//
//  LoginManagerObjcUsageExamples.m
//  BringgDriverSDKExample
//
//  Copyright © 2020 Bringg. All rights reserved.
//

#import "LoginManagerObjcUsageExamples.h"
@import BringgDriverSDKObjc;

@implementation LoginManagerObjcUsageExamples

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialize the bringg driver sdk objc access once. Should probably happen on application start
        NSError *initializationError = [BringgObjc initializeSDKWithLogger:nil];
        if (initializationError) {
            NSLog(@"Failed initializing error: %@", initializationError);
        }
    }
    return self;
}

- (void)loginWithEmailAndPassword {
    [BringgObjc.shared.loginManager loginWithEmail:@"someEmail@somewhere.com" password:@"somePassword" merchant:nil completion:^(NSArray<MerchantSelection *> * _Nullable merchants, ChangeToOpenIdConnectResponse * _Nullable changeToOpenIdConnectResponse, NSError * _Nullable error) {
        if (error) {
            if (error.code == LoginWithEmailAndPasswordErrorCodes.userIsNotADriver) {
                NSLog(@"Only a driver can login using the driver SDK");
            } else if (error.code == LoginWithEmailAndPasswordErrorCodes.unauthorized) {
                NSLog(@"Unauthorized credentials");
            } else {
                NSLog(@"Error while logging in: %@", error.localizedDescription);
            }
            return;
        }

        if (merchants) {
            NSLog(@"There are multiple merchants for this email and password. Allow the user to choose one and call login again with the merchant id");
            return;
        }

        if (changeToOpenIdConnectResponse) {
            NSLog(@"Login should now be changed to open id connect flow. On the response you can find the openIdConfiguration");
            return;
        }

        NSLog(@"If both merchants and error are nil, the user is logged in");
    }];
}

@end
