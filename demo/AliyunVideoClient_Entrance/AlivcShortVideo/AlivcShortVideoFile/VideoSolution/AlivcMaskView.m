//
//  AlivcMaskView.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/9/4.
//  Copyright © 2018年 Alibaba. All rights reserved.
//
/*
 *事件的传递按照正常的进行，不进行重构
 *事件的处理与响应链进行重写，所有的响应不传到父视图，在本视图就处理完毕
 */

#import "AlivcMaskView.h"

@implementation AlivcMaskView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //不处理，截断响应链，事件不向父视图传递
    NSLog(@"手势测试:touchesBegan");
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //不处理，截断响应链，事件不向父视图传递
    NSLog(@"手势测试:touchesMoved");
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //不处理，截断响应链，事件不向父视图传递
    NSLog(@"手势测试:touchesEnded");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //不处理，截断响应链，事件不向父视图传递
    NSLog(@"手势测试:touchesCancelled");
}



@end
