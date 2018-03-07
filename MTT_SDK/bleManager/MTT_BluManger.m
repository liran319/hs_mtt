//
//  MTT_BluManger.m
//  MTT_SDK
//
//  Created by IDAGE on 2017/3/18.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import "MTT_BluManger.h"
#import <objc/runtime.h>
//#import "Mtt_PeripheralModel.h"
//#import "MTT_DeviceModel.h"
//#import "MTT_deviceDataTools.h"
#import "MTT_DeviceFactory.h"
#import "MTT_BaseDeviceModel.h"
#import "MTT_DeviceTabletopModel.h"
#import "MTT_DeviceOrnamentsModel.h"
#import "MTT_DevicePassengerFlowModel.h"
#import "MTT_BaseDeviceModel+private.h"

#define keyMTTDeviceServiceUUID @"FFF0"
#define keyMTTConnectTimeOut 20

//block的关联KEY
static void *MTT_MACRESPONDKEY      = @"MTT_MACRESPONDKEY";
static void *MTT_MACRESPONDFAILURE  = @"MTT_MACRESPONDFAILURE";
static void *MTT_DATARESPONDKEY     = @"MTT_DATARESPONDKEY";
static void *MTT_DATAESPONDFAILURE  = @"MTT_DATAESPONDFAILURE";

static NSString *MTT_APPKEY;
static NSString *MTT_UUID;

@interface MTT_BluManger()

@property (nonatomic)BOOL isCanLog; //是否显示log


@property (strong, nonatomic) CBCentralManager      *centralManager;
/*扫描用的mac字符串字典*/
@property (strong,nonatomic)  NSMutableDictionary   *scanMacStrDic;
/*用来区设备别状态字典*/
//@property (strong,nonatomic)  NSMutableDictionary   *deviceStateDic;
/*链接设备用的mac字符串字典*/
@property (strong,nonatomic)  NSMutableDictionary   *deviceMacStrDic;

@property (strong,nonatomic)  NSTimer *timer;
/*连接中的数组*/
//@property (strong,nonatomic)  NSMutableArray        *inConnectionArray;
/**是否当前有设备连接中*/
//@property (assign,atomic)BOOL isHaveDeviceConnecd;
/*连接中的设备模型*/
//@property (strong,nonatomic)Mtt_PeripheralModel *connectModel;
//设备广播时间 默认是30秒
//@property (assign,nonatomic)NSInteger deviceBroadcastTime;

///*需要同步数据的个数*/
//@property (assign,nonatomic)NSInteger asyncDataCount;
///*同步数据一共经过了得多少秒个数*/
//@property (assign,nonatomic)NSInteger asyncTimeCount;
///*同步数据一共经过了多少个人*/
//@property (assign,nonatomic)NSInteger asyncPassCount;
///*同步数据的数组*/
//@property (strong,nonatomic)NSMutableArray* asyncDataArray;


@end
@implementation MTT_BluManger{
//    //只读服务
//    CBCharacteristic * _readCharacteristicMabiao;
//    //写服务
//    CBCharacteristic * _writeCharacteristicMabiao;
//
//    CBCharacteristic * _readFFF4CharacteristicMabiao;
//
//    CBCharacteristic * _readFFF5CharacteristicMabiao;

}

-(NSMutableDictionary *)scanMacStrDic{
    if (!_scanMacStrDic) {
        _scanMacStrDic = [[NSMutableDictionary alloc]init];
    }
    return _scanMacStrDic;
}
-(NSMutableDictionary *)deviceMacStrDic{
    if (!_deviceMacStrDic) {
        _deviceMacStrDic = [[NSMutableDictionary alloc]init];
    }
    return _deviceMacStrDic;
}
//-(NSMutableDictionary *)deviceStateDic{
//    if (!_deviceStateDic) {
//        _deviceStateDic = [[NSMutableDictionary alloc]init];
//    }
//    return _deviceStateDic;
//
//}
//-(NSMutableArray *)inConnectionArray{
//    if (_inConnectionArray==nil) {
//        _inConnectionArray = [[NSMutableArray alloc]init];
//    }
//    return _inConnectionArray;
//}
//-(NSMutableArray *)asyncDataArray{
//    if (_asyncDataArray==nil) {
//        _asyncDataArray=[[NSMutableArray alloc]init];
//    }
//    return _asyncDataArray;
//}

+ (MTT_BluManger*)sharedMTT_BluManger{
    static MTT_BluManger *blueteethService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{blueteethService = [[MTT_BluManger alloc] init];});
    return blueteethService;
}
- (id)init{
    self = [super init];
    if (self) {
        //初始化蓝牙中心
        if (!_centralManager) {
             _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES]}];

        }
    }
    return self;
}
-(void)mtt_isShowLog:(BOOL)isShowLog{

    self.isCanLog = isShowLog;
}
//注册key  为以后统计数据用
-(BOOL)mtt_registerAppKey:(NSString*)appKey{
//    if (appKey && appKey.length>0 && ![appKey isEqualToString:@"APPkey"]){
//        MTT_UUID   = [MTT_deviceDataTools mtt_uuid];
        MTT_APPKEY = appKey;
//        return YES;
//    }
//    return NO;
    return YES;
}

#pragma mark - CBManagerDelegate Method
//判断蓝牙是否开启，如果没有开启，则提示开启；如果开始，则开始扫描设备
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //状态改变

    if (central.state==CBCentralManagerStatePoweredOff && self.mtt_currentBlueState !=CBCentralManagerStatePoweredOff) {

        if (self.scanMacStrDic.count>0 ) {
            //关联block 返回状态
            void (^block)(id) = objc_getAssociatedObject(self, MTT_MACRESPONDFAILURE);
            if (block) {

                block(@"蓝牙已经关闭");
            }
        }
        if ( self.deviceMacStrDic.count>0) {
            //关联block 返回状态
            void (^block)(id) = objc_getAssociatedObject(self,MTT_DATAESPONDFAILURE);
            if (block) {
                block(@"蓝牙已经关闭");
            }
        }
    }

    self.mtt_currentBlueState = central.state;

    //发送通知
    [[NSNotificationCenter defaultCenter]postNotificationName:MTT_NOBLESTATUSCHANGE object:@(central.state)];

}
/**
 停止扫描所有设备
 */
- (void)mtt_stopScanPeriphals;
{
      [_centralManager stopScan];
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
}

/**
 扫描所有设备

 @param respond 扫描到设备的mac地址 和设备的信号强度
 @param failure 错误回调
 */
-(void)mtt_scanPeripheralsRespond:(MTT_MACRESPOND)respond
                          failure:(MTT_ERROR)failure{

    if (!MTT_APPKEY) {
        if (failure) {
            failure(@"请设置正确的KEY");
        }
        return;
    }

    //停止扫描
    [self mtt_stopScanPeriphals];
    //判断蓝牙当前状态
    if (self.mtt_currentBlueState  ==  CBManagerStatePoweredOff) {
        failure(@"请打开蓝牙");
        return;
    }
    //清空设备地址字典
    [self.deviceMacStrDic removeAllObjects];
    [self.scanMacStrDic removeAllObjects];
//    [self.deviceStateDic removeAllObjects];

    //当标志位使用
    [self.scanMacStrDic setObject:@"default" forKey:@"default"];

    //设置关联block
    void (^block)(NSString*,int,MTTDeviceType) = ^(NSString *macStr, int rssi,MTTDeviceType type){
        respond(macStr,rssi,type);
    };
    objc_setAssociatedObject(self,MTT_MACRESPONDKEY, block, OBJC_ASSOCIATION_COPY);


    void (^failureBLO)(id ) = ^(id error){
        failure(error);
    };
    objc_setAssociatedObject(self,MTT_MACRESPONDFAILURE, failureBLO, OBJC_ASSOCIATION_COPY);

    [self startScanPeriphals];//开始扫描

    [self showlog:@"MTT-正在扫描所有设备"];
}

/**
 链接已经绑定的所有设备

 @param macStrArray mac地址数组
 @param respond 回调(mac地址 ，返回的数据以字典的形式返回所需要的数据)
 @param failure 失败的回调
 */
-(void)mtt_scanPeripheralsWithMacStrArray:(NSArray *)macStrArray
                                  Respond:(MTT_DATARESPOND)respond
                                  failure:(MTT_ERROR)failure{

    if (!MTT_APPKEY) {
        if (failure) {
            failure(@"请设置正确的KEY");
        }
        return;
    }

    //停止扫描
    [self mtt_stopScanPeriphals];

//    self.isHaveDeviceConnecd =  NO;
   //判断蓝牙当前状态
    if (self.mtt_currentBlueState  ==  CBManagerStatePoweredOff) {

        failure(@"请打开蓝牙");
        return;
    }
//    if (!macStrArray || !macStrArray.count) {
//        failure(@"请传入正确的mac地址数组");
//        return;
//    }
//    [self.deviceMacStrDic removeAllObjects];
//    //把所有设备放在字典里
//    for (NSString *macStr in macStrArray) { //&& macStr !=[NSNull null]
//        if (macStr && (id)macStr !=[NSNull null] && macStr.length>0) {
//            [self.deviceMacStrDic setValue:macStr forKey:macStr];
//        }
//    }

    /*设置当前的设备的发送时间*/
//    self.deviceBroadcastTime  = [MTT_deviceDataTools mtt_getBroadcastDurtion:macStrArray.count];


    //清空设备地址字典
    [self.scanMacStrDic removeAllObjects];
//    [self.inConnectionArray removeAllObjects];
//    [self.deviceStateDic removeAllObjects];

    //设置关联block
    void (^dataBlock)(NSString*,int,NSInteger,MTT_BaseDeviceModel*) = ^(NSString *macStr,int rssi,NSInteger state, MTT_BaseDeviceModel* obj){
        respond(macStr,rssi,state,obj);
    };

    objc_setAssociatedObject(self,MTT_DATARESPONDKEY, dataBlock, OBJC_ASSOCIATION_COPY);

    void (^failureBLO)(id ) = ^(id error){
        failure(error);
    };
    objc_setAssociatedObject(self,MTT_DATAESPONDFAILURE, failureBLO, OBJC_ASSOCIATION_COPY);

    [self startScanPeriphals];//开始扫描

    [self showlog:@"MTT-正在扫描已经绑定的所有设备"];

    if (_timer) {
        [_timer invalidate];
    }
     _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(startScanPeriphals) userInfo:nil repeats:YES];
}
- (void)startScanPeriphals
{
//    NSLog(@"startScanPeriphals");

    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [_centralManager stopScan];
    [_centralManager scanForPeripheralsWithServices:nil
                                            options:dict];
}
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI{


//    NSLog(@"扫描到的蓝牙设备：%@", peripheral.name);


    int ID = 0;
    id  data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    if (!data) {

        return;
    }
    NSString *manufacturerDataString = [NSString stringWithFormat:@"%@",data];

    manufacturerDataString = [manufacturerDataString lowercaseString];

    NSString *dataStr = [manufacturerDataString substringWithRange:NSMakeRange(1, manufacturerDataString.length-2)];

    //如果外设是MTT的产品

    if (![[dataStr substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"1112"]) {
        return;
    }

    ID = [dataStr substringWithRange:NSMakeRange(4, 2)].intValue;

    if (ID<40 || ID>42) {
        return;
    }

    dataStr = [dataStr stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSString *deVersion    = [dataStr substringWithRange:NSMakeRange(6, 2)];


    int rssi = [RSSI intValue];

    NSString *mac            = [dataStr substringWithRange:NSMakeRange(8, 12)];

    [self showlog:[NSString stringWithFormat:@"MTT-扫描到设备，mac=%@",mac]];

    MTT_BaseDeviceModel*deviceModel = nil;

//    if (self.deviceMacStrDic.count>0  && [self.deviceMacStrDic valueForKey:mac] ){

        deviceModel = [[MTT_DeviceFactory deviceFactory] getDeviceInfo:dataStr deviceId:ID version:deVersion];

        if (deviceModel==nil) {
            return;
        }
        void (^DATARESPOND)(NSString*,int,NSInteger,MTT_BaseDeviceModel*) = objc_getAssociatedObject(self,MTT_DATARESPONDKEY);

        if (DATARESPOND) {
            DATARESPOND(mac,rssi,deviceModel.deviceState,deviceModel);
        }


        //如果设备的广播时间和设定的时间长度不相等就更新设备的时间
        //            if (deviceModel.broadcastDurtion != self.deviceBroadcastTime) {
        //                if (! [self.inConnectionArray containsObject:deviceModel]) {
        //
        //                    [self.inConnectionArray addObject:deviceModel];
        //
        //                    if (!_isHaveDeviceConnecd) {
        //                        self.connectModel = deviceModel;
        //                        [self connectPeripheral:deviceModel.peripheral];
        //                    }
        //                }
        //            }


//    }else if (self.scanMacStrDic.count>0 && ![self.scanMacStrDic valueForKey:mac]){
//        deviceModel = [[MTT_DeviceFactory deviceFactory] scanDeviceInfo:dataStr deviceId:ID version:deVersion];
//
//        if (deviceModel==nil) {
//            return;
//        }
//
//        //关联block 返回状态
//        void (^macRespondBlock)(NSString *macStr, int rssi,MTTDeviceType  type) = objc_getAssociatedObject(self, MTT_MACRESPONDKEY);
//        if (macRespondBlock) {
//            macRespondBlock(mac,rssi,deviceModel.type);
//        }
//        [self.scanMacStrDic setValue:mac forKey:mac];
//    }
}
-(void)connectPeripheral:(CBPeripheral *)peripheral{
    [_centralManager connectPeripheral:peripheral
                               options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}
/*
//确认连接上蓝牙周边后
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    NSLog(@"链接成功");
    [self showlog:@"链接成功"];

    _isHaveDeviceConnecd = YES;

    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}
//链接失败的回调
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    _isHaveDeviceConnecd = NO;

    [self connectFail:@"链接设备失败"];
}
//断开链接的回调
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
  // NSLog(@"断开连接了");
    _isHaveDeviceConnecd = NO;

    if ( self.inConnectionArray.count>0) {

//        [self.deviceStateDic removeObjectForKey:self.connectModel.macStr];

        [self.inConnectionArray removeObject:self.connectModel];

        if (self.inConnectionArray.count>0) {

            double currTime = [[NSDate date]timeIntervalSince1970]; //获得当前时间

            for (Mtt_PeripheralModel *model in self.inConnectionArray) {

                if (currTime - model.scanDate >keyMTTConnectTimeOut) {
                    [self.inConnectionArray removeObject:model];
                }else{
                    self.connectModel = model;
                    [self connectPeripheral:model.peripheral];
                    break;
                }

            }

        }
    }
}

//扫描到服务后
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [self connectFail:@"扫描服务失败"];
        return;
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:keyMTTDeviceServiceUUID]]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

//扫描到指定服务的关键字后
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [self connectFail:@"扫描到指定服务的关键字失败"];
        return;
    }
    if (peripheral == self.connectModel.peripheral) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:keyMTTDeviceServiceUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics) {

                if ([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]) {
//                    [self.connectModel.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
                if ([characteristic.UUID.UUIDString isEqualToString:@"FFF2"]) {
                    _readCharacteristicMabiao = characteristic;

//                    if (self.connectModel.dataState == PeripheralStateElectricLow) {//电量低

//                        [self.connectModel.peripheral readValueForCharacteristic:characteristic];
//                    }

                }
                if ([characteristic.UUID.UUIDString isEqualToString:@"FFF3"]) {
                    _writeCharacteristicMabiao = characteristic;
//                    if (self.connectModel.pheralState == PeripheralStateAsyncData) {
                        //写入读取数据个数
                        unsigned char cmd[1] ={0x25};
                        NSData *data = [NSData dataWithBytes:cmd length:1];
                         [self.connectModel.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//                    }
                }
                if ([characteristic.UUID.UUIDString isEqualToString:@"FFF4"]) {
                    _readFFF4CharacteristicMabiao = characteristic;
                }
//                if ([characteristic.UUID.UUIDString isEqualToString:@"FFF5"]) {
//                    _readFFF5CharacteristicMabiao = characteristic;
//                    [self.connectModel.peripheral readValueForCharacteristic:characteristic];
//                }
            }
        }
    }
}
//接收关键字后
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
         [self connectFail:@"接收关键字失败"];
        return;
    }

    NSLog(@"characteristic.value=%@=%@",characteristic.UUID.UUIDString,characteristic.value);

    if ([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]) {

//        if (self.asyncDataCount>0 ) {
//
//
//            NSArray *array = [MTT_deviceDataTools mtt_computeTheTimeDifferenceArray:characteristic.value];
////            NSLog(@"array==%@",array);
//            if (!array) {
//                [self connectFail:@"数据处理失败"];
//                return;
//            }
//           [self.asyncDataArray addObjectsFromArray:array];
//        }
//        if (self.asyncDataCount==self.asyncDataArray.count) {
//
//            NSDictionary *dic = @{@"timeDifference":self.asyncDataArray,@"passNumber":@(self.asyncPassCount)};
//            [self returnDataAndStopConnectPeripheral:dic];
//
//            self.asyncDataCount = 0;
//            self.asyncTimeCount = 0;
//            self.asyncPassCount = 0;
//            [self.asyncDataArray removeAllObjects];
//        }
    }
    if ([characteristic.UUID.UUIDString isEqualToString:@"FFF2"]) {

//       NSDictionary *dic = [MTT_deviceDataTools mtt_receiveEletricDataValue:characteristic.value];
//        [self returnDataAndStopConnectPeripheral:dic];
    }
    if ([characteristic.UUID.UUIDString isEqualToString:@"FFF4"]){

        NSLog(@"characteristic.value==%@",characteristic.value);

        NSDictionary *dic = [MTT_deviceDataTools mtt_getStateWithDataValue:characteristic.value];
        if (!dic) {
            [self connectFail:@"数据处理失败"];
            return;
        }
        //断开
        unsigned char cmd[1] ={0x24};
        NSData *data = [NSData dataWithBytes:cmd length:1];
        [self.connectModel.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];

        NSNumber *state = [dic valueForKey:@"state"];
        if (state.intValue != self.connectModel.dataState ) {

            [self returnDataAndStopConnectPeripheral:dic];

        }else{

            [_centralManager cancelPeripheralConnection:self.connectModel.peripheral];
        }


//        return;
//        NSDictionary *dic = [MTT_deviceDataTools mtt_setAsyncDataBaseInfo:characteristic.value];
//
//        if (!dic) {
//            [self connectFail:@"数据处理失败"];
//            return;
//        }
//
//        self.asyncDataCount  =  [[dic valueForKey:@"dataCount"] integerValue];
//        self.asyncTimeCount  =  [[dic valueForKey:@"timeCount"] integerValue];
//        self.asyncPassCount  =  [[dic valueForKey:@"passCount"] integerValue];
//        [self showlog:[NSString stringWithFormat:@"数据次数%zd",self.asyncDataCount]];
//        NSLog(@"--%zd---%zd----%zd--",self.asyncDataCount,self.asyncTimeCount,self.asyncPassCount );
    }

}
//返回数据并且结束连接
-(void)returnDataAndStopConnectPeripheral:(NSDictionary*)dic{

    if (dic) {
        void (^DATARESPOND)(NSString*,NSInteger,id) = objc_getAssociatedObject(self,MTT_DATARESPONDKEY);
        if (DATARESPOND) {
            DATARESPOND(self.connectModel.macStr,0,dic);
        }
    }
    [_centralManager cancelPeripheralConnection:self.connectModel.peripheral];

}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.connectModel.peripheral ==peripheral) {
        [self.connectModel.peripheral readValueForCharacteristic:_readFFF4CharacteristicMabiao];
    }
}
-(void)connectFail:(NSString*)errorDescriptioin{

    [self showlog:errorDescriptioin];

    if ( self.inConnectionArray.count>0 && self.connectModel) {
        //关联block 返回状态
        void (^block)(id) = objc_getAssociatedObject(self,MTT_DATAESPONDFAILURE);
        if (block) {
            block([NSString stringWithFormat:@"%@-mac:%@",errorDescriptioin,self.connectModel.macStr]);
            //链接失败就去自动链接下一个
//            [self.scanMacStrItemDic removeObjectForKey:self.connectModel.macStr];
            [self.inConnectionArray removeObject:self.connectModel];

            if (self.inConnectionArray.count>0) {
                Mtt_PeripheralModel *model  =self.inConnectionArray.firstObject;
                self.connectModel = model;
                [self connectPeripheral:model.peripheral];
            }
        }
    }
}

*/
-(void)showlog:(NSString*)content{
    if (self.isCanLog &&content.length>0) {
        NSLog(@"%@",content);
    }
}

@end
