//
//  JftTokenModel.h
//  JftMergeSDK
//
//  Created by zhl on 2017/1/17.
//  Copyright © 2017年 HLZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFTTokenModel : NSObject
//以下参数为必填参数
@property (nonnull , nonatomic ,strong)NSString *p1_user_code;
@property (nonnull , nonatomic ,strong)NSString *p2_order;
@property (nonnull , nonatomic ,strong)NSString *p3_money;
@property (nonnull , nonatomic ,strong)NSString *p4_returnurl;
@property (nonnull , nonatomic ,strong)NSString *p5_notifyurl;
@property (nonnull , nonatomic ,strong)NSString *p6_ordertime;
@property (nonnull , nonatomic ,strong)NSString *p7_sign;
@property (nonnull , nonatomic ,strong)NSString *serviceType;
@property (nonnull , nonatomic ,strong)NSString *keyString;
@property (nonnull , nonatomic ,strong)NSString *ivString;
@property (nonnull , nonatomic ,strong)NSString *userAppid;

//以下参数可空
@property (nullable, nonatomic ,copy)NSDictionary  *parameterDic;
@end
