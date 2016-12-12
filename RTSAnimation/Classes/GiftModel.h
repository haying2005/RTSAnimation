//
//  GiftModel.h
//  iShow
//
//  Created by fangwenyu on 16/6/4.
//  Copyright © 2016年 godfather. All rights reserved.
//


@interface GiftModel : NSObject

@property (nonatomic, copy)NSString *giftId;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *icon;
@property (nonatomic, assign)NSInteger price;
@property (nonatomic, assign)NSInteger exp; //获得经验
@property (nonatomic, assign)NSInteger type;
@property (nonatomic, assign)BOOL combo;    //是否有连击
@property (nonatomic, copy)NSString *combo_effect;  //连击效果
@property (nonatomic, copy)NSString *animation;     //动画名称ID

@end
