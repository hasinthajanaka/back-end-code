//
//  ServiceManager.h
//  WeddingPlanner
//
//  Created by Platinum Lanka Pvt Ltd on 2/8/17.
//  Copyright © 2017 Platinum Lanka Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceManager : NSObject

+ (id)sharedManager;
- (void)loginNickName:(NSString *)nickName
             password:(NSString *)password
       WithCompletion:(void(^)(NSDictionary *data))completion;
- (void)getDataWithCompletion:(void(^)(NSDictionary *response))completion;
- (void)verificationWithMobileNo:(NSString *)number
                      completion:(void(^)(NSDictionary *hotel))completion;
- (void)signUpNickName:(NSString *)nickName
              mobileNo:(NSString *)mobile
              password:(NSString *)password
            completion:(void(^)(NSDictionary *data))completion;
- (void)sendSms:(NSString *)message phone1:(NSString *)number1 phone2:(NSString *)number2 completion:(void(^)(NSDictionary *data))completion;
- (void)recoveryPin:(NSString *)nickName
         completion:(void(^)(NSDictionary *data))completion;
- (void)contactUs:(NSString *)email
         mobileNo:(NSString *)mobileNo
          message:(NSString *)messsage
   WithCompletion:(void(^)(NSDictionary *data))completion;
-(void)reportUser:(NSString *)user by:(NSString *)currentUser completion:(void(^)(NSDictionary *data))completion;
@end
