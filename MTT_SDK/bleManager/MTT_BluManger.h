//
//  MTT_BluManger.h
//  MTT_SDK
//
//  Created by IDAGE on 2017/3/18.
//  Copyright © 2017年 IDAGE. All rights reserved.



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MTT_BaseDeviceModel.h"



#define MTT_BLE_SHARED  [MTT_BluManger sharedMTT_BluManger]
//蓝牙状态改变的通知
#define MTT_NOBLESTATUSCHANGE @"MTT_NOBLESTATUSCHANGE"

//蓝牙状态
typedef NS_ENUM(NSInteger, MTTCBManagerState) {
	K_MTTCBManagerStateUnknown = 0,
	K_MTTCBManagerStateResetting,
	K_MTTCBManagerStateUnsupported,
	K_MTTCBManagerStateUnauthorized,
	K_MTTCBManagerStatePoweredOff,
	K_MTTCBManagerStatePoweredOn,
};

//设备类型
typedef NS_ENUM(NSInteger, MTTDeviceType) {
    K_MTTDeviceTypeTableTop = 0,        //摆式传感器
    K_MTTDeviceTypeOrnaments = 1,       //挂式传感器
    K_MTTDeviceTypePassengerflow  = 2   //客流传感器
};

//设备状态
typedef NS_ENUM(NSInteger, MTTDeviceState) {
    K_MTTDeviceStateNormal = 0,      //设备正常有数据
    K_MTTDeviceStateElectricLow = 1, //电量低
    K_MTTDeviceStateHeartbeat  = 2   //心跳包用来告知设备在正常运转
};
// MAC地址回调block   macStr：mac地址 rssi设备信号强度
typedef void (^MTT_MACRESPOND)(NSString *macStr ,int rssi,MTTDeviceType type);
//状态回调
typedef void (^MTT_STATUERESPOND)(NSString *macStr,id responseObject);
//数据回调  macStr：mac地址 rssi设备信号强度 state：设备状态  responseObject：预留字段
typedef void (^MTT_DATARESPOND)(NSString *macStr,int rssi,NSInteger state,  MTT_BaseDeviceModel *model);
//错误回调block
typedef void (^MTT_ERROR)(id error);

@interface MTT_BluManger : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
/**
 当前蓝牙的状态
 */
@property(nonatomic)CBManagerState mtt_currentBlueState;

/**
   单利
 @return MTT_BluManger
 */
+ (MTT_BluManger*)sharedMTT_BluManger;

/**
 注册方法

 @param appKey key
 @return 结果
 */
-(BOOL)mtt_registerAppKey:(NSString*)appKey;
/**
 是否打印log   默认为NO

 @param isShowLog 在发布的时候选择NO
 */
-(void)mtt_isShowLog:(BOOL)isShowLog;
/**
 停止扫描所有设备
 */
-(void)mtt_stopScanPeriphals;

/**
 扫描所有设备

 @param respond 扫描到设备的mac地址 和设备的信号强度
 @param failure 错误回调
 */
-(void)mtt_scanPeripheralsRespond:(MTT_MACRESPOND)respond
                          failure:(MTT_ERROR)failure;
/**
 链接已经绑定的所有设备

 @param macStrArray mac地址数组
 @param respond 回调(mac地址 ，设备状态，预留字段)
 @param failure 失败的回调
 */
-(void)mtt_scanPeripheralsWithMacStrArray:(NSArray *)macStrArray
                                  Respond:(MTT_DATARESPOND)respond
                                  failure:(MTT_ERROR)failure;

@end
