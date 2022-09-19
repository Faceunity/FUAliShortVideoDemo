//
//  AlivcTemplateManager.m
//  AlivcEdit
//
//  Created by Bingo on 2021/11/22.
//

#import "AlivcTemplateManager.h"
#import "AlivcTemplateResourceManager.h"

@implementation AlivcTemplateManager

+ (void)setupHardcodeTemplates:(void(^)(void))completed {
    // 内置的模板首次需要进行加载初始化
    NSString *templateDir = [AlivcTemplateResourceManager hardcodeTemplatePath];
    NSString *localTemplateDir = [AlivcTemplateResourceManager localTemplatePath];
    
    // 内置的模板名字
    NSMutableArray *tempDirNames = [NSMutableArray array];
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray *paths = [myFileManager contentsOfDirectoryAtPath:templateDir error:nil];
    for (NSString *path in paths) {
        NSString *taskPath = [NSString stringWithFormat:@"%@/%@", templateDir, path];
        BOOL isDir = NO;
        [myFileManager fileExistsAtPath:taskPath isDirectory:&isDir];
        if (isDir) {
            [tempDirNames addObject:path];
        }
    }

    // 本地已存在内置模板，则不需要重新加载
    NSMutableArray *needLoadNames = [NSMutableArray array];
    for (NSString *name in tempDirNames) {
        NSString *taskPath = [localTemplateDir stringByAppendingPathComponent:name];
        if (![[NSFileManager defaultManager] fileExistsAtPath:taskPath]) {
            // 本地不存在该模板，则需要进行加载初始化
            [needLoadNames addObject:name];
        }
    }
    
    if (needLoadNames.count > 0) {
        // 内置模板初始化
        __block NSInteger count = needLoadNames.count;
        for (NSString *name in needLoadNames) {
            NSString *tempTaskPath = [templateDir stringByAppendingPathComponent:name];
            NSString *taskPath = [localTemplateDir stringByAppendingPathComponent:name];
            
            [AliyunTemplateImporter import:taskPath templateTaskPath:tempTaskPath resourceImport:[AlivcTemplateResourceManager templateResourceImport:tempTaskPath reset:YES] completed:^(NSError *error) {
                if (error) {
                    // 出错，删除本地模板文件
                    [[NSFileManager defaultManager] removeItemAtPath:taskPath error:nil];
                }
                count--;
                if (count == 0) {
                    if (completed) {
                        completed();
                    }
                }
            }];
        }
    }
    else {
        if (completed) {
            completed();
        }
    }
}

+ (void)loadAllTemplates:(void (^)(NSArray<AliyunTemplateLoader *> *))completed {

    [self setupHardcodeTemplates:^{
        NSMutableArray<AliyunTemplateLoader *> *templateLoaders = [NSMutableArray array];
        [templateLoaders addObjectsFromArray:[self loadLocalTemplates]];
        [templateLoaders addObjectsFromArray:[self loadBuiltTemplates]];
        if (completed) {
            completed(templateLoaders);
        }
    }];
}

+ (NSArray *)loadLocalTemplates {
    // 添加内置保存到本地模板，直接加载添加即可
    // 添加本地生成的模板，直接加载添加即可
    NSMutableArray *templateLoaders = [NSMutableArray array];
    NSString *BASE_PATH = [AlivcTemplateResourceManager localTemplatePath];
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray *paths = [myFileManager contentsOfDirectoryAtPath:BASE_PATH error:nil];
    for (NSString *path in paths) {
        NSString *taskPath = [NSString stringWithFormat:@"%@/%@", BASE_PATH, path];
        BOOL isDir = NO;
        [myFileManager fileExistsAtPath:taskPath isDirectory:&isDir];
        if (isDir) {
            AliyunTemplateLoader *loader = [[AliyunTemplateLoader alloc] initWithTaskPath:taskPath];
            if (loader) {
                [templateLoaders addObject:loader];
            }
        }
    }
    return [templateLoaders copy];
}

+ (NSArray *)loadBuiltTemplates {
    // 添加本地生成的模板，直接加载添加即可
    NSMutableArray *templateLoaders = [NSMutableArray array];
    NSString *BASE_PATH = [AlivcTemplateResourceManager builtTemplatePath];
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray *paths = [myFileManager contentsOfDirectoryAtPath:BASE_PATH error:nil];
    for (NSString *path in paths) {
        NSString *taskPath = [NSString stringWithFormat:@"%@/%@", BASE_PATH, path];
        BOOL isDir = NO;
        [myFileManager fileExistsAtPath:taskPath isDirectory:&isDir];
        if (isDir) {
            AliyunTemplateLoader *loader = [[AliyunTemplateLoader alloc] initWithTaskPath:taskPath];
            if (loader) {
                [templateLoaders addObject:loader];
            }
        }
    }
    return [templateLoaders copy];
}

@end
