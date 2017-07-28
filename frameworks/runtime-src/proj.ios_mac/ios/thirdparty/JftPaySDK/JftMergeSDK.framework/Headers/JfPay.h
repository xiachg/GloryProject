//
//  JftSDK.h
//  Jft_SDK
//
//  Created by dyj on 16/2/26.
//  Copyright © 2016年 HLZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JFTPayModel;
@class JFTTokenModel;
@protocol JftSDKPayDelegate <NSObject>
@optional
- (void)getPayTypeListSuccess:(NSArray *)list;//获取支付列表成功
- (void)getPayTypeListFailure:(NSString *)message;//获取支付列表失败
- (void)jftPaySuccess;//支付成功
- (void)jftPayFailure:(NSString *)message;//支付失败
- (void)jftPayResult:(NSString *)result;//支付结果
//pcsoama
- (void)openAppSuccessed;
- (void)openAppFailer:(NSString *)failer;
@end
@interface JfPay : NSObject
/**
 SDK中获取token
 @param tokenModel 数据模型
 */
+ (void)getToken:(JFTTokenModel*)tokenModel success:(void(^)(BOOL tokenSuccess))successful failer:(void(^)(NSString *failerStr))failer;
/**
 *  获取支付列表
 *  @param appId      商家App从自己服务器获得带订单token
 *  @param key        加密Key,预留参数
 *  @param iv         加密向量,预留参数
 *  @param delegate   指定代理对象
 */
+ (void) getPayTypeListkey:(NSString *)key iv:(NSString *)iv appId:(NSString *)appId delegate:(id<JftSDKPayDelegate>)delegate;

/**
 @param payModel 参数模型
 @param delegate 指定代理对象
 */
+ (void)payByJftPayModel:(JFTPayModel *)payModel delegate:(id<JftSDKPayDelegate>)delegate;

+ (void)applicationWillEnterForeground:(UIApplication*)app;


//#pragma mark - 使用微信APP支付和支付宝APP支付，必须实现以下三个UIApplicationDelegate代理方法
//+ (BOOL)openApplication:(UIApplication *)application appPayUrl:(NSURL*)url;
//
+ (void)application:(UIApplication*)application lanchOption:(NSDictionary*)option;
//
+ (BOOL)getApplication:(UIApplication*)app sourceApplication:(NSString *)sourceApplication openURL:(NSURL *)url annotation:(id)annotation;
/**
 *  Log 输出开关 (默认关闭)
 *
 *  @param flag 是否开启
 */
+ (void)setLogEnable:(BOOL)flag;


@end
