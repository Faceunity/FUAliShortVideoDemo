//
//  AlivcSplicingRequestParameter.m
//  AliyunVideoClient_Entrance
//
//  Created by 王凯 on 2018/5/19.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcSplicingRequestParameter.h"
#import "NSString+AlivcHelper.h"


@implementation AlivcSplicingRequestParameter

@end

@implementation AlivcSplicingRequestParameter(videoPlay)

/*
 https://help.aliyun.com/document_detail/52838.html?spm=a2c4g.11186623.2.22.H90tv5
 
 http://vod.cn-shanghai.aliyuncs.com/?Action=GetVideoList&Status=Normal&Format=JSON&<公共参数>
 CateId = olympic
 */
- (NSString*)appendPlayListWithAccessKeyId:(NSString *)accessKeyId accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken{
    NSString *defaultCateId = @"472183517";//方便演示的推荐视频
    return [self appendPlayListWithAccessKeyId:accessKeyId accessKeySecret:accessKeySecret securityToken:securityToken cateId:defaultCateId pageNo:1 pageCount:10];
}

- (NSString *)appendPlayListWithAccessKeyId:(NSString *)accessKeyId accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken cateId:(NSString *)cateId pageNo:(NSInteger)pageNo pageCount:(NSInteger)pageCount{
    @try {
        NSString* sep = @"&";
        NSMutableString* url = [[NSMutableString alloc] initWithString:@"AccessKeyId="];
        [url appendString: [NSString aliyun_encodeToPercentEscapeString:accessKeyId]];
        [url appendString:@"&Action=GetVideoList"];
        
        if (cateId) {
            NSString *cateString = [NSString stringWithFormat:@"&CateId=%@",cateId];
            [url appendString:cateString];
        }

        
        [url appendString:@"&Format=JSON"];
        
        [url appendString:[NSString stringWithFormat:@"&PageNo=%ld",(long)pageNo]];
        [url appendString:[NSString stringWithFormat:@"&PageSize=%ld",(long)pageCount]];
        //
        [url appendString:@"&SecurityToken="];
        [url appendString: [NSString aliyun_encodeToPercentEscapeString:securityToken]];
        [url appendString:@"&SignatureMethod="];
        [url appendString: [NSString aliyun_encodeToPercentEscapeString:@"HMAC-SHA1"]];
        [url appendString:@"&SignatureNonce="];
        [url appendString: [NSString aliyun_encodeToPercentEscapeString:[NSString aliyun_generateUUID]]];
        [url appendString:@"&SignatureVersion="];
        [url appendString: [NSString aliyun_encodeToPercentEscapeString:@"1.0"]];
        [url appendString:@"&Status=Normal"];
       
        //        [url appendString:@"&Timestamp="];
        //        [url appendString:[NSString aliyun_encodeToPercentEscapeString:[AliyunPlayerUtil getIosDateUTCTime]]];
        [url appendString:@"&Version="];
        [url appendString: [NSString aliyun_encodeToPercentEscapeString:@"2017-03-21"]];
        
        NSString *hmacKey = [NSString stringWithFormat:@"%@&",accessKeySecret];
        NSMutableString* getStr = [[NSMutableString alloc] initWithString:@"GET&"];
        [getStr appendString:[NSString aliyun_encodeToPercentEscapeString:@"/"]];
        [getStr appendString:sep];
        [getStr appendString:[NSString aliyun_encodeToPercentEscapeString:url]];
        
        NSString *base_digest = [NSString HmacSha1:hmacKey input:getStr];
        NSString *signature = [NSString aliyun_encodeToPercentEscapeString:base_digest];
        
        NSMutableString* resStr = [[NSMutableString alloc] initWithString:@"https://vod.cn-shanghai.aliyuncs.com/?"];
        [resStr appendString:@"Signature="];
        [resStr appendString:signature];
        [resStr appendString:sep];
        [resStr appendString:url];
        
        return resStr;
    } @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
        return nil;
    }
}




@end
