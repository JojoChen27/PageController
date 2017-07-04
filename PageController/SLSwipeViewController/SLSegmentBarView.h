//
//  SLSegmentBarView.h
//  PageController
//
//  Created by SuperJJ on 2017/6/27.
//  Copyright © 2017年 SuperJJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLSegmentBarView;
@class SLSwipeViewController;

typedef NS_ENUM(NSUInteger, SLSegmentBarStyle) {
    SLSegmentBarStyleNoneView,
    SLSegmentBarStyleProgressView,          //
    SLSegmentBarStyleProgressBounceView,    // 没有实现
    SLSegmentBarStyleProgressElasticView,   // 没有实现
};

@protocol SLSegmentBarViewDelegate <NSObject>
@optional
- (void)segmentBarView:(SLSegmentBarView *)segmentBarView didSelectItemAtIndex:(NSInteger)index;
@end


@interface SLSegmentBarView : UIView
@property (nonatomic, weak) SLSwipeViewController *swipeViewController; // 分页控制器
@property (nonatomic, weak) id<SLSegmentBarViewDelegate> delegate;      // 代理
@property (nonatomic, strong) NSArray <NSString *> *titleArray;         // 数组
@property (nonatomic, assign) SLSegmentBarStyle barStyle;               // 默认SLSegmentBarStyleProgressView
@property (nonatomic, assign) CGFloat itemWidth;                        // item的宽度,默认自动计算, 设置了就不会自动计算宽度了, 自动计算宽度根据字体+左右间距
@property (nonatomic, assign) CGFloat itemEdge;                         // 左右间距, 默认0, 如果设置了item的宽度这个则无效
@property (nonatomic, strong) UIFont *normalTextFont;                   // 默认15
@property (nonatomic, strong) UIFont *selectedTextFont;                 // 默认18
@property (nonatomic, strong) UIColor *normalTextColor;                 // 默认灰色
@property (nonatomic, strong) UIColor *selectedTextColor;               // 默认黑色
@property (nonatomic, strong) UIColor *indicatorLeftColor;              // 指示符左边颜色,默认黑色                         // 没有实现
@property (nonatomic, strong) UIColor *indicatorRightColor;             // 指示器右边颜色,默认黑色, 左右颜色一样就不会变化     // 没有实现
@property (nonatomic, assign) CGFloat indicatorHeight;                  // 指示器高度,默认2
@property (nonatomic, assign) CGFloat indicatorBottomEdge;              // 指示器底部间距,默认0
@property (nonatomic, assign) CGFloat indicatorEdge;                    // 指示器左右间距,默认0
@property (nonatomic, assign) CGFloat indicatorWidth;                   // 指示器宽度, 要小于等于item的最小宽度, 设置后指示器左右间距无效
@property (nonatomic, assign) CGFloat animateDuration;                  // 动画时长
@property (nonatomic, assign, readonly) NSInteger currentIndex;         // 当前选中索引
- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray;
- (void)reloadData;
- (void)moveWithFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;
@end
