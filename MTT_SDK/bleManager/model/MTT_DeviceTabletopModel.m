//
//  MTT_DevicePickedModel.m
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import "MTT_DeviceTabletopModel.h"

static NSMutableDictionary *_deviceDic;
static NSMutableDictionary *_deviceTimeDic;

@interface MTT_DeviceTabletopModel()
//@property(nonatomic,copy)NSString *macStr;
@property(nonatomic,copy)NSString *verson;
@property(nonatomic)DeviceTabletopState state;

@end

@implementation MTT_DeviceTabletopModel

+(void)initialize{
    _deviceDic = [NSMutableDictionary dictionary];
    _deviceTimeDic = [NSMutableDictionary dictionary];
}

+(NSString*)Tag{
    return @"40";
}
+(MTT_DeviceTabletopModel*)getModelFormDataStr:(NSString*)str withVersion:(NSString*)version{
    
        MTT_DeviceTabletopModel *model  = [[MTT_DeviceTabletopModel alloc]init];
    
        model.verson                = version;

        NSString *macStr            = [str substringWithRange:NSMakeRange(8, 12)];

        model.macStr                = macStr;

        NSString *devState          = [str substringWithRange:NSMakeRange(str.length-2, 2)];
        model.deviceState           =  devState.intValue;

        NSString *dataState         = [str substringWithRange:NSMakeRange(str.length-4, 2)];
        model.state                 = dataState.intValue;
    
        model.dataStr = str;

    
    //  计算差值
    if (![_deviceDic valueForKey:macStr]) {
        
        [_deviceDic setValue:@(model.state) forKey:macStr];
       
        double currTime = [[NSDate date]timeIntervalSince1970];
        
        if (model.deviceState != DeviceStateNormal) {
            if (![_deviceTimeDic valueForKey:macStr]) {
                [_deviceTimeDic setValue:@(currTime) forKey:macStr];
                
            }else{
                NSNumber *timeValue = [_deviceTimeDic valueForKey:macStr];
                //                NSLog(@"timeValue==%f===%f==%@--%f",timeValue.doubleValue,currTime,str,currTime-timeValue.doubleValue);
                if (timeValue && currTime-timeValue.doubleValue<20) {
                    //                    NSLog(@"11111111111");
                    return nil;
                }
                //                NSLog(@"2222222222");
                [_deviceTimeDic setValue:@(currTime) forKey:macStr];
            }
            return model;
        }
    }else{
        
        double currTime = [[NSDate date]timeIntervalSince1970];

        if (model.deviceState != DeviceStateNormal) {
            if (![_deviceTimeDic valueForKey:macStr]) {
                [_deviceTimeDic setValue:@(currTime) forKey:macStr];

            }else{
                NSNumber *timeValue = [_deviceTimeDic valueForKey:macStr];
//                NSLog(@"timeValue==%f===%f==%@--%f",timeValue.doubleValue,currTime,str,currTime-timeValue.doubleValue);
                if (timeValue && currTime-timeValue.doubleValue<20) {
//                    NSLog(@"11111111111");
                    return nil;
                }
//                NSLog(@"2222222222");
                [_deviceTimeDic setValue:@(currTime) forKey:macStr];
            }
            return model;
        }
        
        NSNumber *value = [_deviceDic valueForKey:macStr];
        if (value && value.intValue>=0) {
            
            if (value.intValue == model.state && model.deviceState !=DeviceStateHeartbeat) {
                return  nil;
            }
            [_deviceDic setValue:@(model.state) forKey:macStr];

        }
    }
 
    return model;
}
+(MTT_DeviceTabletopModel*)scanModelFormDataStr:(NSString*)str withVersion:(NSString*)version{
    
    MTT_DeviceTabletopModel *model  = [[MTT_DeviceTabletopModel alloc]init];
    
    model.verson                = version;
    
    NSString *macStr            = [str substringWithRange:NSMakeRange(8, 12)];
    
    model.macStr                = macStr;
    
    NSString *devState          = [str substringWithRange:NSMakeRange(str.length-2, 2)];
    model.deviceState           =  devState.intValue;
    
    NSString *dataState         = [str substringWithRange:NSMakeRange(str.length-4, 2)];
    model.state                 = dataState.intValue;
    
    return model;
}
-(NSString *)tag{
    return [MTT_DeviceTabletopModel Tag];
}
+(NSString*)VTagWith:(NSString*)version
{
    return [MTT_DeviceTabletopModel Tag];;
}
-(NSString*)getMacStr{
    return self.macStr;
}
-(int)type{
    return [MTT_DeviceTabletopModel Tag].intValue-40;
}
@end
