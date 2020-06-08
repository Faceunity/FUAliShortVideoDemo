//
//  _AlivcLiveBeautifyDetailView.h
//  BeautifySettingsPanel
//
//  Created by 汪潇翔 on 2018/5/29.
//  Copyright © 2018 汪潇翔. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlivcRaceLiveBeautifyNavigationView, AlivcRaceLiveBeautifyDetailView;

@protocol AlivcRaceLiveBeautifyDetailViewDelegate <NSObject>
- (void)detailView:(AlivcRaceLiveBeautifyDetailView *)detailView didSelectItemAtIndex:(NSUInteger)index;
@end

@protocol AlivcRaceLiveBeautifyDetailViewDataSource <NSObject>
@required

/**
 get list of detailView
 @code
     @[
         @{
            @"title":@"磨皮",
            @"identifier" : @"mopi"
          },
         @{
            @"title":@"美白",
            @"identifier" : @"mopi"
         }
     ]
 @param detailView current detailView
 @return items of detailView
 */
- (NSArray<NSDictionary *> *)itemsOfDetailView:(AlivcRaceLiveBeautifyDetailView *)detailView;
@end

@interface AlivcRaceLiveBeautifyDetailView : UIView

@property (nonatomic, readonly) AlivcRaceLiveBeautifyNavigationView *navigationView;

@property (nonatomic, weak) id<AlivcRaceLiveBeautifyDetailViewDelegate> delegate;

@property (nonatomic, weak) id<AlivcRaceLiveBeautifyDetailViewDataSource> dataSource;

- (void)setDefaultValue;

- (void)reloadData;

@end
