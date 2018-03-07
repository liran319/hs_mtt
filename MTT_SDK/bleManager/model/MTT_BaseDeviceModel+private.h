//
//  MTT_BaseDeviceModel+private.h
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import "MTT_BaseDeviceModel.h"

@interface MTT_BaseDeviceModel (private)
/**
 类的消息头标识
 
 @return 标示
 */
+(NSString*)Tag;
/**
 根据版本号去的对应的tag
 
 @param version 版本号
 @return 标示
 */
+(NSString*)VTagWith:(NSString*)version;
/**
 *  根据字符串 获得模型
 *
 *  @param str     数据字符串
 *  @param version 版本号
 *
 *  @return 数据模型
 */
+(MTT_BaseDeviceModel*)getModelFormDataStr:(NSString*)str withVersion:(NSString*)version;

+(MTT_BaseDeviceModel*)scanModelFormDataStr:(NSString*)str withVersion:(NSString*)version;

-(NSString*)getMacStr;


@end
