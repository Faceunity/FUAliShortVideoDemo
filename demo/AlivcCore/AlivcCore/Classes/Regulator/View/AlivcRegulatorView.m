//
//  AlivcRegulatorView.m
//  AFNetworking
//
//  Created by lileilei on 2020/1/6.
//

#import "AlivcRegulatorView.h"
#import "AlivcRegulatorCell.h"

static NSString *AlivcRegulatorCellIndentifier = @"AlivcRegulatorCellIndentifier";

@interface AlivcRegulatorView ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *dataArray;

@end

@implementation AlivcRegulatorView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews{
    _isSliderEnable = YES;
    [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    [self addSubview:_tableView];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setBackgroundColor:[UIColor clearColor]];
    _tableView.rowHeight = 60.f;
    
    [_tableView registerClass:[AlivcRegulatorCell class] forCellReuseIdentifier:AlivcRegulatorCellIndentifier];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    [_tableView setClipsToBounds:NO];
}


#pragma mark - TableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlivcRegulatorCell *cell = [tableView dequeueReusableCellWithIdentifier:AlivcRegulatorCellIndentifier];
    [cell setModel:[self.dataArray objectAtIndex:indexPath.row] isEnable:self.isSliderEnable];
    cell.didSliderChangeBlock = ^(float value) {
        if (self.didRegulatorViewSliderChangeBlock) {
            __weak typeof(indexPath) weakObj = indexPath;
            __weak typeof(self) weakSelf = self;
            self.didRegulatorViewSliderChangeBlock(weakSelf.dataArray,value, weakObj.row);
        }
    };
    return cell;
}

+ (AlivcRegulatorView*)initUIwithData:(NSArray *)data inView:(UIView*)container{
    NSArray *dataArray = data;
    if (dataArray.count<=0) {
        return nil;
    }
    long maxShowCount = MIN(dataArray.count, 4);
    CGFloat height = maxShowCount * 60.f;
    AlivcRegulatorView *regulatorView = [[AlivcRegulatorView alloc] initWithFrame:CGRectMake(0, -height, CGRectGetWidth(container.frame), height)];
    [container addSubview:regulatorView];
    regulatorView.dataArray = dataArray;
    
    if (maxShowCount>=dataArray.count) {
        regulatorView.tableView.scrollEnabled = NO;
    }
    
    [regulatorView.tableView reloadData];
    return regulatorView;
}


+(NSArray*)getSliderParams:(AliyunEffectConfig*)data{
    NSMutableArray *paramList = @[].mutableCopy;
    if (!data.nodeTree) {
        return nil;
    }
    for (AliyunNode *node in data.nodeTree) {
        for (AliyunParam *param in node.params) {
            if (param.value.type==AliyunValueINT||param.value.type==AliyunValueFLOAT) {
                param.nodeId = node.nodeId;
                [paramList addObject:param];
            }
        }
    }
    return paramList;
}

- (void)setSilderEnable:(BOOL)isEnable{
    self.isSliderEnable = isEnable;
    [self.tableView reloadData];
}

@end
