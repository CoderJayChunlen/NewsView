//
//  LTNewsView.m
//  CustomerAlert
//
//  Created by chunlen on 2016/12/13.
//  Copyright © 2016年 lt. All rights reserved.
//
/***屏幕宽度*/
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
/***屏幕高度*/
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define RGBA_COLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


#import "CJNewsView.h"
#import "UIView+MJ.h"
#import "UIView+WebCache.h"

@interface CJNewsView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) NSArray *images;
@property (nonatomic, assign) LTNewsViewScrollDirection scrollDirection;//0代表横向，1，代表纵向
@property(nonatomic,copy) NewsClosedBlock complete;
@property(nonatomic, strong) NSTimer *timer;
@end
@implementation CJNewsView
{
    UIScrollView *_baseScrollView;
    UIPageControl *_pageControl;
    
    UIButton *skipButton;
    BOOL isLastPage;
    __block int count;
}
- (instancetype)initWithFrame:(CGRect)frame inVIew:(UIView *)sview news:(NSArray *)news newsComplete:(NewsClosedBlock)complete
{
    self = [super initWithFrame:frame];
    if (self) {
        count = 5;
        UIViewController *vc = [UIViewController new];
        self.rootViewController = vc;
        [self initViews];
        _images = news;
        _complete = complete;
        [self setImages:news];
        self.windowLevel = UIWindowLevelStatusBar+1;
        [self makeKeyAndVisible];
//        [sview addSubview:self];
//        [sview bringSubviewToFront:self];
    }
    return self;
}

+ (CJNewsView *)showNews:(NSArray *)news inView:(UIView *)sView newsComplete:(void(^)())complete{
    return [[self alloc] initWithFrame:[UIScreen mainScreen].bounds inVIew:sView news:news newsComplete:complete];
}
- (void)initViews{
    _baseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _baseScrollView.bounces = NO;
    _baseScrollView.delegate = self;
    _baseScrollView.pagingEnabled = YES;
    _baseScrollView.showsHorizontalScrollIndicator = NO;
    _baseScrollView.showsVerticalScrollIndicator = NO;
    
    [self.rootViewController.view addSubview:_baseScrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 30)];
    [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    //    _pageControl.tintColor = BUTTON_COLOR;
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    //    _pageControl.currentPageIndicatorTintColor = [UIImage imageNamed:@""].CGImage
    [self.rootViewController.view addSubview:_pageControl];
}
- (void)setImages:(NSArray *)images{
    _images = images;
    if (!_baseScrollView) {
        [self initViews];
    }
    if (_scrollDirection == 0) {
        _baseScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * images.count, 0);
    }else{
        _baseScrollView.contentSize = CGSizeMake(0 , SCREEN_HEIGHT * images.count);
    }
    _pageControl.numberOfPages = images.count;
    if (images.count>1) {
        _pageControl.hidden = _scrollDirection == 0?NO:YES;
    }else{
        _pageControl.hidden = YES;
    }
    for (int i = 0; i<images.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_scrollDirection == 0?SCREEN_WIDTH*i:0, _scrollDirection == 0?0:SCREEN_HEIGHT*i, SCREEN_WIDTH, SCREEN_HEIGHT)];
        if ([images[i] isKindOfClass:[NSString class]]) {
            if ([images[i] containsString:@"http"]) {
                UIImage *placeHolderImage = nil;
                if (SCREEN_HEIGHT == 480) {
                    placeHolderImage = [UIImage imageNamed:@"place_holder_640x960"];
                }else{
                    placeHolderImage = [UIImage imageNamed:@"default640x1136"];
                }
                [imageView sd_internalSetImageWithURL:[NSURL URLWithString:images[i]] placeholderImage:placeHolderImage options:SDWebImageRetryFailed operationKey:@"" setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
                    
                } progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                }];
//                [imageView sd_setImageWithURL:[NSURL URLWithString:images[i]] placeholderImage:placeHolderImage options:SDWebImageRetryFailed];
            }else{
                imageView.image = [UIImage imageNamed:images[i]];
            }
        }else{
            imageView.image = images[i];
        }
        imageView.userInteractionEnabled = YES;
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nextBtn.frame = CGRectMake(0, SCREEN_HEIGHT - 95, SCREEN_WIDTH, 60);
        //        nextBtn.backgroundColor = RGBA_COLOR(255, 255, 255, 0.5);
        [nextBtn addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
        nextBtn.tag = 100 + i;
        [imageView addSubview:nextBtn];
        [_baseScrollView addSubview:imageView];
    }
    
    skipButton = [UIButton buttonWithType:UIButtonTypeCustom ];
    if (_scrollDirection == 1) {
        skipButton.frame  = CGRectMake(SCREEN_WIDTH - 70, SCREEN_HEIGHT - 75, 60, 30);
    }else{
        skipButton.frame  = CGRectMake(SCREEN_WIDTH - 70, 30, 60, 30);
    }
    skipButton.layer.cornerRadius = 15;
    skipButton.clipsToBounds = YES;
    skipButton.backgroundColor = RGBA_COLOR(255, 255, 255, 0.4);
    [skipButton setTitle:[NSString stringWithFormat:@"跳过%dS",count] forState:UIControlStateNormal];
    skipButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [skipButton addTarget:self action:@selector(goInButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.rootViewController.view addSubview:skipButton];
    
    _timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(timeChanged:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
  
    
}

- (void)timeChanged:(NSTimer *)timer{
    count-= 1;
    if (count == 0) {
        [self goInButtonClick];
        [_timer invalidate];
        _timer = nil;
    }else{
        [skipButton setTitle:[NSString stringWithFormat:@"跳过%dS",count] forState:UIControlStateNormal];
    }
}

- (void)nextPage:(UIButton *)sender{
    _pageControl.currentPage = sender.tag - 100 + 1;
    if (sender.tag - _images.count + 1 == 100) {//最后一页，隐藏引导页
        NSLog(@"最后一页");
        [self goInButtonClick];
    }else{//切换到一页
        NSLog(@"第%ld页",(long)sender.tag - 100);
        if (sender.tag - 100 + 1 == _images.count) {
            isLastPage = YES;
        }else{
            isLastPage = NO;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            _baseScrollView.contentOffset = CGPointMake(_scrollDirection == 0?(sender.tag - 100 + 1)*SCREEN_WIDTH:0, _scrollDirection == 0?0:(sender.tag - 100 + 1)*SCREEN_HEIGHT);
            
        }];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    NSInteger currentPage = (_scrollDirection == LTNewsViewScrollDirectionHorizon?point.x:point.y)/(_scrollDirection == LTNewsViewScrollDirectionHorizon?SCREEN_WIDTH:SCREEN_HEIGHT);
    _pageControl.currentPage = currentPage;

}

- (void)pageChanged:(UIPageControl *)pageControl{
    _baseScrollView.contentOffset = CGPointMake(pageControl.currentPage*SCREEN_WIDTH, 0);
}

- (void)goInButtonClick{
    [_timer invalidate];
    _timer = nil;
    if (self.complete) {
        self.complete();
    }
    
    [self resignKeyWindow];

    

        [UIView animateWithDuration:1 animations:^{
            if (_scrollDirection == 0) {
                _baseScrollView.x = - SCREEN_WIDTH;
            }else{
                _baseScrollView.y = - SCREEN_HEIGHT;
            }
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self resignKeyWindow];

//            [self removeFromSuperview];
        }];
}


@end
