//
//  BWBeanTableViewCell.h
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import <UIKit/UIKit.h>
#import <PTDBeanManager.h>

@interface BWBlueBeanTableViewCell : UITableViewCell

@property (nonatomic, strong) PTDBean *bean;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
