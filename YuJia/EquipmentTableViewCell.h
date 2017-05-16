//
//  EquipmentTableViewCell.h
//  YuJia
//
//  Created by wylt_ios_1 on 2017/5/3.
//  Copyright © 2017年 wylt_ios_1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EquipmentModel.h"

@interface EquipmentTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconV;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *nextImageV;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, weak) UIImageView *imageV;
@property (nonatomic, weak) UISwitch *switch0;

@property (nonatomic, strong) EquipmentModel *equipmentModel;

- (void)cellMode:(BOOL)isSwitch;

@end
