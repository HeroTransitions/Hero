//
//  CityGuideCell.swift
//  HeroTransitionExample
//
//  Created by YiLun Zhao on 2016-11-24.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

class CityCell:UICollectionViewCell{
  @IBOutlet weak var imageView: UIImageView!
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  var useShortDescription:Bool = true
  
  var city:City?{
    didSet{
      imageView.image = city?.image
      nameLabel.text = city?.name
      descriptionLabel.text = useShortDescription ? city?.shortDescription : city?.description
      if let name = city?.name{
        heroID = "\(name)_backgroundImage"
        nameLabel.heroID = "\(name)_cityName"
        descriptionLabel.heroID = "\(name)_cityDescription"
      }
    }
  }
}
