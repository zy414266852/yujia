//
//  YJPhotoAddBtnCollectionViewCell.h
//  YuJia
//
//  Created by 万宇 on 2017/5/4.
//  Copyright © 2017年 wylt_ios_1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJPhotoAddBtnCollectionViewCell : UICollectionViewCell
/** block方式监听点击 */
@property (nonatomic, copy) void (^clickBtnBlock)(NSInteger tag);
@end
