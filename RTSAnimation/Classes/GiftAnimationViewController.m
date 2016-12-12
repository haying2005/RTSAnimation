//
//  GiftAnimationViewController.m
//  iShow
//
//  Created by fangwenyu on 16/7/8.
//  Copyright © 2016年 godfather. All rights reserved.
//

#import "GiftAnimationViewController.h"

@interface GiftAnimationViewController ()

@property (nonatomic, strong)NSArray *animationsArr; //礼物数组

@property (nonatomic, copy)NSString *currentAnimation;

@property (nonatomic, assign)NSInteger elementCount; //元素个数

@property (nonatomic, strong)NSMutableArray *animationsToShowArr; //待展示礼物动画数组

@end

@implementation GiftAnimationViewController

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentAnimation = nil;
    self.elementCount = 0;
}

#pragma mark - Utility

- (NSArray *)animationsArr {
    if (!_animationsArr) {
        _animationsArr = [self loadAnimations:@"animationData"];
    }
    return _animationsArr;
}

- (NSMutableArray *)animationsToShowArr {
    if (!_animationsToShowArr) {
        _animationsToShowArr = [NSMutableArray array];
    }
    return _animationsToShowArr;
}

//往数组中添加一个待播放动画
- (void)addAnimationWithGiftModel:(GiftModel *)giftModel {
    
    [self.animationsToShowArr addObject:giftModel];
    
    if (!self.currentAnimation) {
        [self loadAnimationWithName:[self getNextPlayGiftModel].animation];
    }
}

- (NSArray *)loadAnimations:(NSString *)fileStr {
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"gift" ofType:@"bundle"];
    NSString *path = [[NSBundle bundleWithPath:bundlePath] pathForResource:fileStr ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    //NSArray *animationArr = [jsonData objectFromJSONData];
    NSArray *animationArr = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    return animationArr;
}

- (GiftModel *)getNextPlayGiftModel
{
    if (self.animationsToShowArr.count) {
        [self.animationsToShowArr sortUsingComparator:^NSComparisonResult(GiftModel *obj1, GiftModel *obj2) {
            return obj1.price < obj2.price;
        }];
                
        return [self.animationsToShowArr firstObject];
    }
    else {
        return nil;
    }
}

- (BOOL)loadAnimationWithName:(NSString *)animationName {
    if (self.currentAnimation) {
        NSLog(@"当前已经在运行动画:%@", self.currentAnimation);
        return NO;
    }
    
    if (![self.animationsArr count]) {
        NSLog(@"animationsArr为空");
        return NO;
    }
    
    CGFloat selfWidth = self.view.bounds.size.width;
    CGFloat selfHeight = self.view.bounds.size.height;
    
    for (NSDictionary *dic in self.animationsArr) {
        if ([dic[@"animationName"] isEqualToString:animationName]) {
            
            for (NSDictionary *dic1 in dic[@"elements"]) {
                
                NSString *elementName = dic1[@"elementName"];
                
                NSString *imageName = dic1[@"textureName"];
                
                NSArray *colorValues = dic1[@"colorValues"];
                NSArray *pathValues = dic1[@"pathValues"];
                NSArray *rotateValues = dic1[@"rotateValues"];
                NSArray *scaleValues = dic1[@"scaleValues"];
                
                NSArray *position = dic1[@"position"];
                NSArray *size = dic1[@"size"];
                CGFloat rotate = [dic1[@"rotate"] doubleValue];
                
                double startTime = [dic1[@"startTime"] doubleValue];
                double stopTime = [dic1[@"stopTime"] doubleValue];
                
                UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [size[0] floatValue] * selfWidth, [size[1] floatValue] * selfHeight)];
                imgV.layer.position = CGPointMake([position[0] floatValue] * selfWidth, [position[1] floatValue] * selfHeight);
                imgV.layer.transform = CATransform3DMakeRotation(-rotate / 180. * M_PI, 0, 0, 1.);
                
                NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"gift" ofType:@"bundle"];
                NSString *path = [[NSBundle bundleWithPath:bundlePath]pathForResource:[NSString stringWithFormat:@"anim/%@/%@", animationName, imageName] ofType:@"png"];
                imgV.image = [UIImage imageWithContentsOfFile:path];
                [self.view addSubview:imgV];
                
                NSMutableArray *valueArr = [NSMutableArray array];
                NSMutableArray *timesArr = [NSMutableArray array];
                
                CAAnimationGroup *group = [CAAnimationGroup animation];
                NSMutableArray *aniArr = [NSMutableArray array];
                
                //颜色变化动画(暂时只考虑alpha)
                if (!colorValues.count || (colorValues.count % 3)) {
                    if (colorValues.count)
                        NSLog(@"colorValues 元素个数不对");
                }
                else {
                    for (int i = 0; i < colorValues.count; i++) {
                        if ((i % 3) == 0) {
                            [valueArr addObject:[colorValues objectAtIndex:i]];
                        }
                        else if ((i % 3) == 2) {
                            [timesArr addObject:[colorValues objectAtIndex:i]];
                        }
                    }
                    
                    CAKeyframeAnimation *ani = [self createAnimation:@"opacity" Values:valueArr andKeyTimes:timesArr];
                    [aniArr addObject:ani];
                }
                
                //位移动画
                [valueArr removeAllObjects];
                [timesArr removeAllObjects];
                
                if (!pathValues.count || (pathValues.count % 3)) {
                    if (pathValues.count)
                        NSLog(@"pathValues 元素个数不对");
                }
                else {
                    for (int i = 0; i < pathValues.count; i++) {
                        if (i % 3 == 0) {
                            NSValue *value = [NSValue valueWithCGPoint:CGPointMake(selfWidth * [pathValues[i] floatValue], selfHeight * [pathValues[i + 1]floatValue])];
                            [valueArr addObject:value];
                        }
                        else if ((i % 3) == 2) {
                            [timesArr addObject:[pathValues objectAtIndex:i]];
                        }
                    }
                    
                    CAKeyframeAnimation *ani = [self createAnimation:@"position" Values:valueArr andKeyTimes:timesArr];
                    [aniArr addObject:ani];
                }
                
                //旋转动画
                [valueArr removeAllObjects];
                [timesArr removeAllObjects];
                
                if (!rotateValues.count || (rotateValues.count % 3)) {
                    if (rotateValues.count)
                        NSLog(@"rotateValues 元素个数不对");
                }
                else {
                    for (int i = 0; i < rotateValues.count; i++) {
                        if (i % 3 == 0) {
                            [valueArr addObject:[NSNumber numberWithDouble:[[rotateValues objectAtIndex:i] doubleValue] / 180 * M_PI]];
                        }
                        else if ((i % 3) == 2) {
                            [timesArr addObject:[rotateValues objectAtIndex:i]];
                        }
                    }
                    
                    CAKeyframeAnimation *ani = [self createAnimation:@"transform.rotation" Values:valueArr andKeyTimes:timesArr];
                    [aniArr addObject:ani];
                }
                
                //缩放动画x轴
                [valueArr removeAllObjects];
                [timesArr removeAllObjects];
                
                if (!scaleValues.count || (scaleValues.count % 3)) {
                    if (scaleValues.count)
                        NSLog(@"scaleXValues 元素个数不对");
                }
                else {
                    for (int i = 0; i < scaleValues.count; i++) {
                        if (i % 3 == 0) {
                            [valueArr addObject:[scaleValues objectAtIndex:i]];
                        }
                        else if ((i % 3) == 2) {
                            [timesArr addObject:[scaleValues objectAtIndex:i]];
                        }
                    }
                    
                    CAKeyframeAnimation *ani = [self createAnimation:@"transform.scale.x" Values:valueArr andKeyTimes:timesArr];
                    [aniArr addObject:ani];
                }
                
                //缩放动画y轴
                [valueArr removeAllObjects];
                [timesArr removeAllObjects];
                
                if (!scaleValues.count || (scaleValues.count % 3)) {
                    if (scaleValues.count)
                        NSLog(@"scaleYValues 元素个数不对");
                }
                else {
                    for (int i = 0; i < scaleValues.count; i++) {
                        if (i % 3 == 0) {
                            [valueArr addObject:[scaleValues objectAtIndex:i + 1]];
                        }
                        else if ((i % 3) == 2) {
                            [timesArr addObject:[scaleValues objectAtIndex:i]];
                        }
                    }
                    
                    CAKeyframeAnimation *ani = [self createAnimation:@"transform.scale.y" Values:valueArr andKeyTimes:timesArr];
                    [aniArr addObject:ani];
                }
                
                group.animations = aniArr;
                group.duration = stopTime - startTime;
                group.beginTime = CACurrentMediaTime() + startTime;
                group.fillMode = kCAFillModeForwards;
                group.removedOnCompletion = NO;
                group.delegate = self;//必须先设置代理再addAnimation,所有的设置都必须在addAnimation之前，因为addAnimation操作复制了一个新的动画对象
                
                [imgV.layer addAnimation:group forKey:elementName];
                
                self.elementCount ++;
            }
            
            self.currentAnimation = animationName;
            return YES;
        }
    }
    return NO;
}

- (CAKeyframeAnimation *)createAnimation:(NSString *)keyPath Values:(NSArray *)values andKeyTimes:(NSArray *)times  {
    
    CAKeyframeAnimation *ani = [CAKeyframeAnimation animation];
    ani.keyPath = keyPath;
    ani.duration = [[times lastObject] doubleValue] - [[times firstObject] doubleValue];
    ani.fillMode = kCAFillModeForwards;
    ani.removedOnCompletion = NO;
    
    NSMutableArray *keyTimes = [NSMutableArray arrayWithCapacity:times.count];
    for (NSNumber *time in times) {
        [keyTimes addObject:[NSNumber numberWithDouble:([time doubleValue] - [[times firstObject] doubleValue]) / ani.duration]];
    }
    ani.keyTimes = keyTimes;
    
    ani.values = values;
    
    ani.beginTime = [[times firstObject] doubleValue];
    
    return ani;
}

#pragma mark - CAAnimation Delegate

- (void)animationDidStart:(CAAnimation *)anim {
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    self.elementCount --;
    
    if (self.elementCount == 0) {
        self.currentAnimation = nil;
        //[self.view removeAllSubviews];
        [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        
        [self.animationsToShowArr removeObjectAtIndex:0];
        
        if (self.animationsToShowArr.count == 0) {
            NSLog(@"所有礼物动画展示完毕");
            [self.view removeFromSuperview];
        }
        else {
            [self loadAnimationWithName:[self getNextPlayGiftModel].animation];
        }
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    NSLog(@">>>>>>>>>>[%@] Dealloc...", self);
}

@end
