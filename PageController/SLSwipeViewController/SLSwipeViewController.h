//
//  SLSwipeViewController.h
//  PageController
//
//  Created by SuperJJ on 2017/6/27.
//  Copyright © 2017年 SuperJJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLSegmentBarView;
@class SLSwipeViewController;

@protocol SLSwipeViewControllerDataSource <NSObject>
@required
- (NSUInteger)numberOfControllers;
- (UIViewController *)swipeViewController:(SLSwipeViewController *)swipeViewController controllerForIndex:(NSUInteger)index;
@end


@protocol SLSwipeViewControllerDelegate <NSObject>
@optional
- (void)swipeViewController:(SLSwipeViewController *)swipeViewController fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;
@end


@interface SLSwipeViewController : UIViewController
@property (nonatomic, weak) id<SLSwipeViewControllerDataSource> dataSource;             // 数据源
@property (nonatomic, weak) id<SLSwipeViewControllerDelegate> delegate;                 // 代理
@property (nonatomic, weak) SLSegmentBarView *segmentBarView;                           // SLSegmentBarView
@property (nonatomic, assign, readonly) NSUInteger currentIndex;                        // 当前索引
@property (nonatomic, assign, readonly) NSUInteger controllerCount;                     // 控制器数量
@property (nonatomic, weak, readonly) UIViewController *currentViewController;          // 当前控制器
@property (nonatomic, weak, readonly) UIScrollView *contentView;                        // 内容视图
@property (nonatomic, assign) CGFloat changeIndexWhenScrollProgress;                    // 索引改变参考值, 默认0.5


/**
 创建控制器
 @param frame 视图大小位置
 @param dataSource 数据源
 @return 返回控制器
 */
- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<SLSwipeViewControllerDataSource>)dataSource;


/**
 移动到页面
 @param index 页面索引
 @param animated 是否动画
 */
- (void)moveToPage:(NSInteger)index animated:(BOOL)animated;

@end
