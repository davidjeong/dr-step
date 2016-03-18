//
//  DSProfileCell.m
//  DrStep
//
//  Created by Juhwan Jeong on 3/18/16.
//
//

#import "DSProfileCell.h"

@interface DSProfileCell()


@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation DSProfileCell

#pragma mark - Lifecycle

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}*/


- (void)layoutSubviews {
    [super layoutSubviews];
    self.nameLabel.text = self.name;
    self.emailLabel.text = self.email;
    if (self.profileImage != nil) {
        self.profileImageView.image = self.profileImage;
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.layer.borderWidth = 5.0f;
        self.profileImageView.layer.borderColor = [[UIColor grayColor] CGColor];
        self.profileImageView.layer.masksToBounds = YES;
    }
}

@end
