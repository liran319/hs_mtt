//
//  MTT_deviceDataTools.h
//  MTT_SDK
//
//  Created by IDAGE on 2017/3/24.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MTT_deviceDataTools : NSObject

//获取商家信心
//+(Mtt_PeripheralModel*)mtt_DeviceModelWith:(NSDictionary *)advertisementData peripheral:(CBPeripheral *)peripheral;
//处理电量数据处理
+(NSDictionary*)mtt_receiveEletricDataValue:(NSData*)dataValue;
//获取数据的基本信息
+(NSDictionary*)mtt_setAsyncDataBaseInfo:(NSData*)dataValue;
//获取设备的状态码
+(NSDictionary*)mtt_getStateWithDataValue:(NSData*)dataValue;

//计算时间查数组
+(NSArray *)mtt_computeTheTimeDifferenceArray:(NSData*)dataValue;

/**
 获取设备UUID

 @return uuid
 */
+(NSString*)mtt_uuid;
/**
 获取设备的广播时间

 @param count 一共有多少个设备
 @return 广播时间
 */
+(NSInteger)mtt_getBroadcastDurtion:(NSInteger)count;

+(int)mtt_getIntValueFromHexString:(NSString*)str;
@end
