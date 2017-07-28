//
//  JftPayModel.h
//  SDK_Demo
//
//  Created by dyj on 16/8/19.
//  Copyright © 2016年 dyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JFTPayModel : NSObject
@property (nonatomic, strong ,nonnull) NSString * key; //**加密向量//
@property (nonatomic, strong ,nonnull) NSString * iv; //**加密密钥//

@property (nonatomic, strong ,nonnull) NSString * appId; //**AppId
@property (nonatomic, strong ,nonnull) NSString * payTypeId;
@property (nonatomic, strong ,nonnull) UIViewController * controler;
@property (nonatomic, strong ,nonnull) NSString * weichatAppid;
@property (nonatomic , assign)         BOOL isReturn;//是否回掉

//@property (nonatomic, strong ,nonnull) NSString * userCode;//商户号
//@property (nonatomic, strong ,nonnull) NSString * CommonKey;//商户密钥
//@property (nonatomic, strong ,nonnull) NSString * nocer;//随机字符串

@end
