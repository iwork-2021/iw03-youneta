//
//  pageTableViewCell.swift
//  ITSC
//
//  Created by nju on 2021/11/12.
//

import UIKit
typealias didTapBlk = (pageTableViewCell) -> ()

class pageTableViewCell: UITableViewCell {
    //MARK: properties
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        return label
    }()

    lazy var timeLabel: UILabel = {
      var label = UILabel()
        return label
    }()
    var didClickCellBlk : didTapBlk?
    
    
    //MARK: init
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String, title: String, timeString: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.titleLabel.text = title
        self.timeLabel.text = timeString
        self.layer.borderWidth = 0.15
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(_handleTapCell))
        self.addGestureRecognizer(tapGes)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: life cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(self.titleLabel)
        self.addSubview(self.timeLabel)
        self._setupUI()
    }
    
    
    
    //MARK: setupUI
    func _setupUI() {
        self._setupConstraints()
    }
    
    func _setupConstraints() {
        self.titleLabel.autoresizesSubviews = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.titleLabel.rightAnchor.constraint(equalTo: self.timeLabel.leftAnchor).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.timeLabel.autoresizesSubviews = false
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.timeLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    //MARK: private methods
    @objc func _handleTapCell(sender: UIGestureRecognizer) {
        if(self.didClickCellBlk != nil) {
            self.didClickCellBlk!(self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
