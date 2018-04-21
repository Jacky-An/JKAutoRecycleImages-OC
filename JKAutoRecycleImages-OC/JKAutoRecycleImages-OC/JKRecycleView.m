//
//  JKRecycleView.m
//  JKAutoRecycleImages-OC
//
//  Created by albert on 16/9/5.
//  Copyright © 2016年 albert. All rights reserved.
//  自动无限轮播

#import "JKRecycleView.h"

static NSString * const JKIndexKey = @"JKIndexKey";

@interface JKRecycleView () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    UIView *_contentView;
    UIPageControl *_pageControl;
    NSInteger _pagesCount;
}

/** collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;

/** timer */
@property (nonatomic, strong) NSTimer *timer;

/** dataSourceArr */
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@end

@implementation JKRecycleView

+ (instancetype)recycleViewWithFrame:(CGRect)frame{
    
    JKRecycleView *recycleView = [[JKRecycleView alloc] initWithFrame:frame];
    
    recycleView.flowlayout.itemSize = frame.size;
    
    return recycleView;
}

/**
 * 设置数据
 * 数组中每个元素应是NSDictionary类型
 * NSDictionary必须有一个图片urlkey JKRecycleImageUrlKey
 * JKRecycleTitleKey和JKRecycleOtherDictKey可有可无
 */
- (void)setDataSource:(NSArray <NSDictionary *> *)dataSource{
    
    _pagesCount = dataSource.count;
    self.pageControl.numberOfPages = _pagesCount;
    
    [self.dataSourceArr addObjectsFromArray:dataSource];
    
    if (_pagesCount <= 1) {
        
        self.collectionView.scrollEnabled = NO;
        
        [self.collectionView reloadData];
        
        return;
    }
    
    [self.dataSourceArr addObject:[dataSource.firstObject copy]];
    
    [self.dataSourceArr insertObject:[dataSource.lastObject copy] atIndex:0];
    
    [self.collectionView performBatchUpdates:^{
        
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        
    } completion:^(BOOL finished) {
        
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width, 0)];
        [self addTimer];
    }];
}

#pragma mark - 懒加载

- (UIView *)contentView{
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self insertSubview:contentView atIndex:0];
        
        //        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        //        NSArray *contentViewCons1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:@{@"contentView" : contentView}];
        //        [self addConstraints:contentViewCons1];
        //
        //        NSArray *contentViewCons2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:@{@"contentView" : contentView}];
        //        [self addConstraints:contentViewCons2];
        
        _contentView = contentView;
    }
    return _contentView;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        _flowlayout = [[UICollectionViewFlowLayout alloc] init];
        _flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowlayout.minimumLineSpacing = 0;
        _flowlayout.minimumInteritemSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowlayout];
        collectionView.backgroundColor = nil;
        collectionView.scrollsToTop = NO;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.pagingEnabled = YES;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self.contentView insertSubview:collectionView atIndex:0];
        
        [collectionView registerClass:[JKRecycleCell class] forCellWithReuseIdentifier:NSStringFromClass([JKRecycleCell class])];
        
        //        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        //        NSArray *collectionViewCons1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|" options:0 metrics:nil views:@{@"collectionView" : collectionView}];
        //        [self addConstraints:collectionViewCons1];
        //
        //        NSArray *collectionViewCons2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|" options:0 metrics:nil views:@{@"collectionView" : collectionView}];
        //        [self addConstraints:collectionViewCons2];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.userInteractionEnabled = NO;
        //        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        //        pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        [self.contentView addSubview:pageControl];
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}

#pragma mark - 初始化
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self initialization];
    }
    return self;
}

- (void)initialization {
    
    self.backgroundColor = [UIColor lightGrayColor];
    
    // 初始化数据
    _autoRecycleInterval = 3;
    _autoRecycle = YES;
    
    // 初始化scrollView
    [self collectionView];
    
    // 初始化pageControl
    [self pageControl];
    
    //    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    //    tipLabel.text = @"此处应有图片";
    //    tipLabel.textColor = [UIColor whiteColor];
    //    tipLabel.textAlignment = NSTextAlignmentCenter;
    //    [self insertSubview:tipLabel belowSubview:self.scrollView];
    //    self.tipLabel = tipLabel;
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

//- (void)willResignActive{
//    [self removeTimer];
//}
//
//- (void)didBecomeActive{
//    [self addTimer];
//}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    self.collectionView.frame = self.contentView.bounds;
    self.flowlayout.itemSize = self.bounds.size;
    _pageControl.frame = CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 20);
}

#pragma mark - 添加定时器
- (void)addTimer {
    
    if (!_autoRecycle ||
        _pagesCount <= 1 ||
        self.timer != nil ||
        _autoRecycleInterval <= 1) return;
    
    __weak typeof(self) weakSelf = self;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_autoRecycleInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        [weakSelf startAutoRecycle];
    }];
}

#pragma mark - 移除定时器
- (void)removeTimer {
    
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - 循环滚动的方法
- (void)startAutoRecycle {
    
    if (!self.timer) {
        return;
    }
    
    CGPoint newOffset = CGPointMake(_collectionView.contentOffset.x + _collectionView.bounds.size.width, 0);
    [_collectionView setContentOffset:newOffset animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JKRecycleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JKRecycleCell class]) forIndexPath:indexPath];
    
    [cell bindDict:self.dataSourceArr[indexPath.item]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    !self.imageClickBlock ? : self.imageClickBlock(self.dataSourceArr[indexPath.item]);
    
    if ([self.delegate respondsToSelector:@selector(recycleView:didClickImageWithDict:)]) {
        
        [self.delegate recycleView:self didClickImageWithDict:self.dataSourceArr[indexPath.item]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_scaleAnimated) {
        
        cell.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!_scaleAnimated) {
        return;
    }
    
    NSIndexPath *index = [collectionView indexPathsForVisibleItems].lastObject;
    
    UICollectionViewCell *cell1 = [collectionView cellForItemAtIndexPath:index];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        cell1.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
}

// 减速完毕 重新设置scrollView的x偏移
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self adjustContentOffset:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    [self adjustContentOffset:scrollView];
}

- (void)adjustContentOffset:(UIScrollView *)scrollView{
    
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    if (page == 0) { // 滚动到左边，自动调整到倒数第二
        
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width * (_pagesCount), 0);
        _pageControl.currentPage = _pagesCount;
        
        if (_scaleAnimated) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_pagesCount inSection:0]];
                
                [UIView animateWithDuration:0.25 animations:^{
                    
                    cell.transform = CGAffineTransformIdentity;
                }];
            });
        }
        
    }else if (page == _pagesCount + 1){ // 滚动到右边，自动调整到第二个
        
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        _pageControl.currentPage = 0;
        
        if (_scaleAnimated) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
                
                [UIView animateWithDuration:0.25 animations:^{
                    
                    cell.transform = CGAffineTransformIdentity;
                }];
            });
        }
        
    }else{
        
        _pageControl.currentPage = page - 1;
    }
}

// 手指拖动 移除定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self removeTimer];
}

// 手指松开 添加定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self addTimer];
}

#pragma mark - setter方法

- (void)setAutoRecycle:(BOOL)autoRecycle{
    _autoRecycle = autoRecycle;
    
    [self removeTimer];
    [self addTimer];
}

- (void)setAutoRecycleInterval:(NSTimeInterval)autoRecycleInterval{
    
    if (autoRecycleInterval < 1) return;
    
    _autoRecycleInterval = autoRecycleInterval;
    
    [self removeTimer];
    [self addTimer];
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTimer];
    NSLog(@"%d, %s",__LINE__, __func__);
}

@end

#pragma mark - -------------cell-------------

@interface JKRecycleCell ()

/** containerView */
@property (nonatomic, weak) UIView *containerView;

/** imageView */
@property (nonatomic, weak) UIImageView *imageView;

/** titleLabel */
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation JKRecycleCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
    }
    return self;
}

- (UIView *)containerView{
    if (!_containerView) {
        UIView *containerView = [[UIView alloc] init];
        [self.contentView addSubview:containerView];
        
        containerView.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *containerViewCons1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containerView]-0-|" options:0 metrics:nil views:@{@"containerView" : containerView}];
        [self addConstraints:containerViewCons1];
        
        NSArray *containerViewCons2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containerView]-0-|" options:0 metrics:nil views:@{@"containerView" : containerView}];
        [self addConstraints:containerViewCons2];
        
        _containerView = containerView;
    }
    return _containerView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.containerView addSubview:imageView];
        
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *imageViewCons1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|" options:0 metrics:nil views:@{@"imageView" : imageView}];
        [self addConstraints:imageViewCons1];
        
        NSArray *imageViewCons2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-|" options:0 metrics:nil views:@{@"imageView" : imageView}];
        [self addConstraints:imageViewCons2];
        _imageView = imageView;
    }
    return _imageView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(100, 20, 100, 30);
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.shadowColor = [UIColor darkGrayColor];
        titleLabel.shadowOffset = CGSizeMake(1, 0);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.containerView addSubview:titleLabel];
        
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (void)initialization{
    
}

- (void)bindDict:(NSDictionary *)dict{
    _dict = [dict copy];
    
    self.imageView.image = [UIImage imageNamed:_dict[JKRecycleImageUrlKey]];
    
    if (_dict[JKRecycleTitleKey] == nil) {
        
        _titleLabel.hidden = YES;
        
        return;
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@", _dict[JKRecycleTitleKey]];
    
    self.titleLabel.hidden = NO;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!_titleLabel) { return; }
    
    CGSize labelSize = [_titleLabel sizeThatFits:CGSizeMake(self.contentView.bounds.size.width - 30, INFINITY)];
    _titleLabel.frame = CGRectMake(15, self.contentView.bounds.size.height - 20 - labelSize.height, self.contentView.bounds.size.width - 30, labelSize.height);
}
@end
