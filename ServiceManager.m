//
//  ServiceManager.m
//  WeddingPlanner
//
//  Created by Platinum Lanka Pvt Ltd on 2/8/17.
//  Copyright © 2017 Platinum Lanka Pvt Ltd. All rights reserved.
//

#import "ServiceManager.h"
#import <AFNetworking.h>
#import "Yaalu-Bridging-Header.h"
#import "Yaalu-Prefix.pch"
#import "OBConstants.h"
#import "Yaalu-Swift.h"

@implementation ServiceManager

+ (id)sharedManager {
    static ServiceManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if(self = [super init]) {
        
    }
    return self;
}

#pragma mark - Rest API for Post
- (void)postData:(NSString *)api withParams:(NSDictionary *)param withCompletion:(void(^)(NSData *data))completion {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if(delegate.isReachable) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [manager POST:[kBaseURL stringByAppendingString:api] parameters:param progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            completion(responseObject);
            DLog(@"JSON: %@", responseObject);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            DLog(@"Error: %@", error.localizedDescription);
            
            NSDictionary *data =  @{ @"code" : @420
                                    };
            
            NSDictionary *erroObject = @{
                                            @"error" : data
                                       };
            
            NSData *dataObject = [NSKeyedArchiver archivedDataWithRootObject:erroObject];
            completion(erroObject);

        }];
    }
}

- (void)sendSmsWithParams:(NSDictionary *)param withCompletion:(void(^)(NSData *data))completion {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if(delegate.isReachable) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json",
                                                @"Accept" : @"application/json",
                                                @"Authorization" : @"Basic Y3liZXJkcmVhbXM6ZnJlZXBvcnQ3NzU0MQ==" };
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSString *url = @"http://api.infobip.com/sms/1/text/multi";
        
        [manager POST:url parameters:param progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            completion(responseObject);
            DLog(@"JSON: %@", responseObject);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            DLog(@"Error: %@", error.localizedDescription);
        }];
    }
}

- (void)getData:(NSString *)api withParams:(NSDictionary *)param withCompletion:(void(^)(NSData *data))completion {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
}

- (void)loginNickName:(NSString *)nickName
             password:(NSString *)password
       WithCompletion:(void(^)(NSDictionary *data))completion {
    
    NSDictionary *params = @{
                             kAppKey: kAPIKeyValue,
                             kNickName: nickName,
                             kPin: password,
                             kDeviceId: [[Constants sharedInstance] getDeviceId],
                             kDeviceType:kPhoneDeviceType
                             };
    
    
    [self postData:kLogin withParams:params withCompletion:^(NSData *data) {
        completion((NSDictionary *)data);
    }];
}

- (void)contactUs:(NSString *)email
             mobileNo:(NSString *)mobileNo
          message:(NSString *)messsage
       WithCompletion:(void(^)(NSDictionary *data))completion {
    
    NSDictionary *params = @{
                             kAppKey: kAPIKeyValue,
                             kAccessToken:[[Constants sharedInstance] accessToken],
                             kEmail:email,
                             kMobileNo: mobileNo,
                             kMessage: messsage
                             };
    
    
    [self postData:kContactUs withParams:params withCompletion:^(NSData *data) {
        completion((NSDictionary *)data);
    }];
}

- (void)verificationWithMobileNo:(NSString *)number completion:(void(^)(NSDictionary *hotel))completion {
    
    NSDictionary *params = @{
                             kAppKey: kAPIKeyValue,
                             kMobileNumber: [number stringByReplacingOccurrencesOfString:@"94" withString:@""]
                             };
    [self postData:kVerification withParams:params withCompletion:^(NSData *data) {
        completion((NSDictionary *)data);
    }];
}

- (void)sendSms:(NSString *)message phone1:(NSString *)number1 phone2:(NSString *)number2 completion:(void(^)(NSDictionary *data))completion {
    
    
    NSArray *to = nil;
    
    if ([number2  isEqualToString: @""]) {
        to = @[number1];
    } else {
        to = @[number1, number2];
    }
    
    NSDictionary *messageData = @{ @"from": @"Yaalu.com",
                                   @"to" : to,
                                   @"text": message};
    
    NSArray *messages = @[messageData];
    NSDictionary *params = @{@"messages" : messages};
    
    
    [self sendSmsWithParams:params withCompletion:^(NSData *data) {
        completion((NSDictionary *)data);
    }];
}

- (void)signUpNickName:(NSString *)nickName
              mobileNo:(NSString *)mobile
              password:(NSString *)password
        completion:(void(^)(NSDictionary *data))completion {
    
    
    
    NSDictionary *params = @{
                             kAppKey: kAPIKeyValue,
                             kNickName: nickName,
                             kMobileNumber:[mobile stringByReplacingOccurrencesOfString:@"94" withString:@""],
                             kPin: password,
                             kDeviceId: [[Constants sharedInstance] getDeviceId],
                             kDeviceType:kPhoneDeviceType
                            };
    
    [self postData:kSignUp withParams:params withCompletion:^(NSData *data) {
        completion((NSDictionary *)data);
    }];
}

- (void)getDataWithCompletion:(void(^)(NSDictionary *response))completion {
    
    NSDictionary *params = @{
                             kAppKey: kAPIKeyValue,
                             kAccessToken:[[Constants sharedInstance] accessToken],
                             kLastUpdatedTime:[NSString stringWithFormat: @"%ld", (long)[[Constants sharedInstance] lastUpdatedDate]],
                             kNetworkProvider:[[Utility shared] mobileNetwork]
                             };
    
    [self postData:kSyncList withParams:params withCompletion:^(NSData *data) {
        completion((NSDictionary *)data);
    }];
}

- (void)recoveryPin:(NSString *)phoneNumber
            completion:(void(^)(NSDictionary *data))completion {
    
    NSDictionary *params = @{
                             kAppKey: kAPIKeyValue,
                             @"phone": phoneNumber
                            };
    
    [self postData:kRecoveryPin withParams:params withCompletion:^(NSData *data) {
        completion((NSDictionary *)data);
    }];
}

-(void)reportUser:(NSString *)user by:(NSString *)currentUser completion:(void(^)(NSDictionary *data))completion {
    
    NSDictionary *params = @{
                             kAppKey: kAPIKeyValue,
                             @"current_user": currentUser,
                             @"reported_user": user
                             };
    
    [self postData:kReportedUser withParams:params withCompletion:^(NSData *data) {
        completion((NSDictionary *)data);
    }];
}

#pragma mark - Rest API


@end
