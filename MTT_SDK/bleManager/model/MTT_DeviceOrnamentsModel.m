//
//  MTT_DeviceStateModel.m
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import "MTT_DeviceOrnamentsModel.h"
#import "MTT_deviceDataTools.h"

static NSMutableDictionary *_deviceTimeDic;

static NSMutableDictionary *_deviceDic;


@interface MTT_DeviceOrnamentsModel()
@property(nonatomic,assign)DeviceOrnamentState   state;
//@property(nonatomic,copy)  NSString            *macStr;
@property(nonatomic,copy)  NSString            *verson;
@end
@implementation MTT_DeviceOrnamentsModel
+(void)initialize{
    _deviceDic = [NSMutableDictionary dictionary];
    _deviceTimeDic = [NSMutableDictionary dictionary];
}

+(NSString*)Tag{
    return @"41";
}
+(MTT_DeviceOrnamentsModel*)getModelFormDataStr:(NSString*)str withVersion:(NSString*)version{
    
    MTT_DeviceOrnamentsModel *model  = [[MTT_DeviceOrnamentsModel alloc]init];
    
    model.verson                = version;
    
    NSString *macStr            = [str substringWithRange:NSMakeRange(8, 12)];
    
    model.macStr                = macStr;
    
    NSString *dataStateStr         = [str substringWithRange:NSMakeRange(20, 2)];
    int dataState =[MTT_deviceDataTools mtt_getIntValueFromHexString:dataStateStr];
    model.state                = dataState;
    
    
    NSString *devStateStr           = [str substringWithRange:NSMakeRange(str.length-2, 2)];
    int devState = [MTT_deviceDataTools mtt_getIntValueFromHexString:devStateStr];
    model.deviceState           =  devState;
    
//    NSLog(@"devState=%@==%zd==%zd",str,devState,dataState);
    
//     NSString *dataState         = [str substringWithRange:NSMakeRange(str.length-4, 2)];
    
    
    if (model.state==0) {
        model.deviceState           = 2;
    }else{
        model.deviceState           = 0;
    }
    
    //心跳包
//    if (model.state==0) {
//        return nil;
//    }
    model.dataStr = str;
        //  计算差值
    if (![_deviceDic valueForKey:macStr] ) {
        
        [_deviceDic setValue:@(model.state) forKey:macStr];
        
        return model;
        
    }else{
        
        NSNumber *value = [_deviceDic valueForKey:macStr];
        
        if (value.intValue==model.state) {
            return nil;
        }
        [_deviceDic setValue:@(model.state) forKey:macStr];

        return model;
    }
    
//        double currTime = [[NSDate date]timeIntervalSince1970];
//
//        if (model.deviceState != DeviceStateNormal) {
//            
//            if (![_deviceTimeDic valueForKey:macStr]) {
//                [_deviceTimeDic setValue:@(currTime) forKey:macStr];
//                
//            }else{
//                NSNumber *timeValue = [_deviceTimeDic valueForKey:macStr];
//                if (timeValue  && currTime-timeValue.doubleValue>0 && currTime-timeValue.doubleValue<20) {
//                    return nil;
//                }
//                [_deviceTimeDic setValue:@(currTime) forKey:macStr];
//            }
//            return model;
//        }
//        
//        
//        NSNumber *value = [_deviceDic valueForKey:macStr];
//        
//        if (value && value.intValue>=0) {
//            
//            if (value.intValue==model.state && model.deviceState !=DeviceStateHeartbeat) {
//                return nil;
//            }
//            
//            [_deviceDic setValue:@(model.state) forKey:macStr];
//
//        }
//        
//        [_deviceDic setValue:@(dataState) forKey:macStr];
//    
//    }
//     return model;
}
+(MTT_DeviceOrnamentsModel*)scanModelFormDataStr:(NSString*)str withVersion:(NSString*)version{

    MTT_DeviceOrnamentsModel *model  = [[MTT_DeviceOrnamentsModel alloc]init];
    
    model.verson                = version;
    
    NSString *macStr            = [str substringWithRange:NSMakeRange(8, 12)];
    
    model.macStr                = macStr;
    
    NSString *dataState         = [str substringWithRange:NSMakeRange(20, 2)];
    model.state                 = dataState.intValue;
    
//    NSString *devState          = [str substringWithRange:NSMakeRange(str.length-2, 2)];
    
    if (model.state==0) {
        model.deviceState           = 2;
    }else{
        model.deviceState           = 0;
    }
    
    return model;
}
-(NSString *)tag{
    return [MTT_DeviceOrnamentsModel Tag];
}
+(NSString*)VTagWith:(NSString*)version
{
    return [MTT_DeviceOrnamentsModel Tag];;
}
-(NSString*)getMacStr{
    return self.macStr;
}
-(int)type{
    return [MTT_DeviceOrnamentsModel Tag].intValue-40;
}
@end
