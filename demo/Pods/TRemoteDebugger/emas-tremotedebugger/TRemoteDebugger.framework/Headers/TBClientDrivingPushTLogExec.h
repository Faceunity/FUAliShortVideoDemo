//
//  ClientDrivenPushLogExec.h
//  AliHACore
//
//  Created by hansong.lhs on 2017/12/21.
//

#import <Foundation/Foundation.h>

@interface TBClientDrivingPushTLogExec : NSObject


/**
 *  在某些场景或异常流程下，业务方主动调用，能够直接上传TLog日志，默认上传当天的日志，如果当时客户端的网站环境是非wifi,
 *  会把上传指令存成离线任务。等待切换到wifi再上传。
 *
 *  appendParamDict 上传成功后附带的业务参数，由调用方自定义传入：
 *
 *  @param appendParamDict   @{@"反馈标题":,@"反馈内容":,@"分类名称":,@"昵称":,@"utdid":}
 */
+ (void)uploadTLogAction:(NSDictionary*)appendParamDict;

@end
