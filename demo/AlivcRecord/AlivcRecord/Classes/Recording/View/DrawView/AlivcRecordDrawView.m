//
//  AlivcRecordDrawView.m
//  AlivcRecord
//
//  Created by coder.pi on 2021/5/17.
//

#import "AlivcRecordDrawView.h"

@interface __AlivcDrawPath : UIView
@property (nonatomic, strong) UIBezierPath *path;
@end

@interface AlivcRecordDrawView ()
@property (nonatomic, strong) __AlivcDrawPath *pathView;
@end

@implementation AlivcRecordDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        _pathView = [[__AlivcDrawPath alloc] initWithFrame:self.bounds];
        [self addSubview:_pathView];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    _pathView.frame = self.bounds;
    [_pathView setNeedsDisplay];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_pathView.path moveToPoint:[touches.anyObject locationInView:self]];
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_pathView.path addLineToPoint:[touches.anyObject locationInView:self]];
    [_pathView setNeedsDisplay];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_pathView.path addLineToPoint:[touches.anyObject locationInView:self]];
    [_pathView setNeedsDisplay];
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
}

@end

@implementation __AlivcDrawPath

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = UIColor.grayColor;
        
        _path = [UIBezierPath bezierPath];
        _path.lineWidth = 2.0;
        _path.lineJoinStyle = kCGLineJoinRound;
        _path.lineCapStyle = kCGLineCapRound;
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [UIColor.redColor set];
    [_path stroke];
}
@end
