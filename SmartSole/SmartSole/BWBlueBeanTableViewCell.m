//
//  BWBeanTableViewCell.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "BWBlueBeanTableViewCell.h"

@implementation BWBlueBeanTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLabel.text = self.bean.name;
    
    NSString* state;
    
    // Set the state based on bean's state.
    switch (self.bean.state) {
        case BeanState_Unknown:
            state = @"Unknown";
            break;
        case BeanState_AttemptingConnection:
            state = @"Connecting...";
            break;
        case BeanState_AttemptingDisconnection:
            state = @"Disconnecting...";
            break;
        case BeanState_AttemptingValidation:
            state = @"Connecting...";
            break;
        case BeanState_ConnectedAndValidated:
            state = @"Connected";
            break;
        default:
            state = @"Disconnected";
            break;
    }
    self.statusLabel.text = state;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
