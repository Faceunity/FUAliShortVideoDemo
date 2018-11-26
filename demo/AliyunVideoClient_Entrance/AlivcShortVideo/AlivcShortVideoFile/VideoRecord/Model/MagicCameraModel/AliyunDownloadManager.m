//
//  AliyunDownloadManager.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunDownloadManager.h"
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "ZipArchive.h"

@implementation AliyunDownloadTask

- (id)initWithInfo:(AliyunPasterInfo *)pasterInfo
{
    if (self = [super init]) {
        _pasterInfo = pasterInfo;
    }
    return self;
}

@end

@interface AliyunDownloadManager()

/**
 任务数组
 */
@property (nonatomic , strong)NSMutableDictionary *tasks;
@end

@implementation AliyunDownloadManager

- (void)addTask:(AliyunDownloadTask *)task
{
    [self addTask:task progress:nil completionHandler:nil];
}

- (void)addTask:(AliyunDownloadTask *)task progress:(void (^)(NSProgress*downloadProgress))progressBlock completionHandler:(void(^)(NSString *filePath, NSError *error))completionHandler
{
    AliyunPasterInfo *pasterInfo = task.pasterInfo;
    task.progressBlock = progressBlock;
    task.completionHandler = completionHandler;
    
    AliyunHttpClient *httpClient = [[AliyunHttpClient alloc] initWithBaseUrl:pasterInfo.url];
    NSString *name = [NSString stringWithFormat:@"%@-%ld-tmp.%@", pasterInfo.name, (long)pasterInfo.eid, [pasterInfo.url pathExtension]];
    NSString *destination = [[pasterInfo directoryPath] stringByAppendingPathComponent:name];
    
    if (_tasks == nil) {
        _tasks = [[NSMutableDictionary alloc] init];
    }
    NSLog(@"~~~~~destination:%@", destination);
    [_tasks setObject:task forKey:destination];
    
    [httpClient download:pasterInfo.url destination:destination progress:^(NSProgress *downloadProgress) {
        if (task.progressBlock) {
            task.progressBlock(downloadProgress);
        }
    } completionHandler:^(NSURL *filePath, NSError *error) {
        NSLog(@" download error:%@", error);
        
        NSString *unzipName = [NSString stringWithFormat:@"%@-%ld", pasterInfo.name, (long)pasterInfo.eid];
        NSString *unzipPath = [[[pasterInfo directoryPath] stringByAppendingPathComponent:unzipName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self upzip:filePath to:[NSURL URLWithString:unzipPath]];
        });
        if(error){
            task.completionHandler(nil, error);
        }
    }];
}


/**
 解压文件

 @param filePath 被解压文件的路径
 @param toDestination 解压后存放的路径
 */
- (void)upzip:(NSURL *)filePath to:(NSURL *)toDestination
{
    
    ZipArchive *_zipArchive = [[ZipArchive alloc] init];
    [_zipArchive UnzipOpenFile:filePath.path];
    BOOL finish = [_zipArchive UnzipFileTo:toDestination.path overWrite:YES];
    [_zipArchive UnzipCloseFile];
    NSString *destination = toDestination.path;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:destination];
    for (NSString *file in enumerator) {
        NSString *path = [destination stringByAppendingPathComponent:file];
        NSDictionary *attribute = [fm attributesOfItemAtPath:path error:nil];
        NSString * fileType = attribute[NSFileType];
        
        if ([fileType isEqualToString:NSFileTypeDirectory]) {
            NSError *error = nil;
            NSArray *files = [fm contentsOfDirectoryAtPath:path error:&error];
            
            for (NSString *fileItem in files) {
                NSString *atPath = [path stringByAppendingPathComponent:fileItem];
                NSString *toPath = [destination stringByAppendingPathComponent:fileItem];
                NSError *mvErr = nil;
                [fm moveItemAtPath:atPath toPath:toPath error:&mvErr];
                if (mvErr) {
                    NSLog(@"~~~~mv error:%@", mvErr);
                }
            }
            NSError *rmErr = nil;
            [fm removeItemAtPath:path error:&rmErr];
            if (rmErr) {
                NSLog(@"~~~~~~rm error:%@", rmErr);
            }
            
            [fm removeItemAtPath:path error:nil];
        }
    }
    
    if (finish) {
        
        NSError *fError = nil;
        [fm removeItemAtPath:filePath.path error:&fError];
        if (fError) {
            NSLog(@"~~~~~~f error:%@", fError);
        }
        
        NSLog(@"~~~~~~filepath.path:%@", filePath.path);
        
        AliyunDownloadTask *task = [_tasks objectForKey:filePath.path];
        [_tasks removeObjectForKey:filePath.path];
        if (task) {
            task.completionHandler(toDestination.path, nil);
        }
        
    }
}

@end
