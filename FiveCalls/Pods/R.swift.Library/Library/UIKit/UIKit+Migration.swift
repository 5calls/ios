//
//  UIKit+Migration.swift
//  R.swift.Library
//
//  Created by Tom Lokhorst on 2016-09-08.
//  From: https://github.com/mac-cain13/R.swift.Library
//  License: MIT License
//

import UIKit

// Renames from Swift 2 to Swift 3

public extension NibResourceType {

  @available(*, unavailable, renamed: "instantiate(withOwner:options:)")
  public func instantiateWithOwner(_ ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> [AnyObject] {
    fatalError()
  }
}


public extension StoryboardResourceWithInitialControllerType {

  @available(*, unavailable, renamed: "instantiateInitialViewController")
  public func initialViewController() -> InitialController? {
    fatalError()
  }
}

public extension UICollectionView {

  @available(*, unavailable, renamed: "dequeueReusableCell(withReuseIdentifier:for:)")
  public func dequeueReusableCellWithReuseIdentifier<Identifier: ReuseIdentifierType>(_ identifier: Identifier, forIndexPath indexPath: IndexPath) -> Identifier.ReusableType?
    where Identifier.ReusableType: UICollectionReusableView
  {
    fatalError()
  }


  @available(*, unavailable, renamed: "dequeueReusableSupplementaryView(ofKind:withReuseIdentifier:for:)")
  public func dequeueReusableSupplementaryViewOfKind<Identifier: ReuseIdentifierType>(_ elementKind: String, withReuseIdentifier identifier: Identifier, forIndexPath indexPath: IndexPath) -> Identifier.ReusableType?
    where Identifier.ReusableType: UICollectionReusableView
  {
    fatalError()
  }


  @available(*, unavailable, renamed: "register")
  public func registerNib<Resource: NibResourceType>(_ nibResource: Resource)
    where Resource: ReuseIdentifierType, Resource.ReusableType: UICollectionViewCell
  {
    fatalError()
  }


  @available(*, unavailable, renamed: "register")
  public func registerNib<Resource: NibResourceType>(_ nibResource: Resource, forSupplementaryViewOfKind kind: String)
    where Resource: ReuseIdentifierType, Resource.ReusableType: UICollectionReusableView
  {
    fatalError()
  }
}

public extension UITableView {


  @available(*, unavailable, renamed: "dequeueReusableCell(withIdentifier:for:)")
  public func dequeueReusableCellWithIdentifier<Identifier: ReuseIdentifierType>(_ identifier: Identifier, forIndexPath indexPath: IndexPath) -> Identifier.ReusableType?
    where Identifier.ReusableType: UITableViewCell
  {
    fatalError()
  }


  @available(*, unavailable, renamed: "dequeueReusableCell(withIdentifier:)")
  public func dequeueReusableCellWithIdentifier<Identifier: ReuseIdentifierType>(_ identifier: Identifier) -> Identifier.ReusableType?
    where Identifier.ReusableType: UITableViewCell
  {
    fatalError()
  }


  @available(*, unavailable, renamed: "dequeueReusableHeaderFooterView(withIdentifier:)")
  public func dequeueReusableHeaderFooterViewWithIdentifier<Identifier: ReuseIdentifierType>(_ identifier: Identifier) -> Identifier.ReusableType?
    where Identifier.ReusableType: UITableViewHeaderFooterView
  {
    fatalError()
  }


  @available(*, unavailable, renamed: "register")
  public func registerNib<Resource: NibResourceType>(_ nibResource: Resource) where Resource: ReuseIdentifierType, Resource.ReusableType: UITableViewCell
  {
    fatalError()
  }


  @available(*, unavailable, renamed: "registerHeaderFooterView")
  public func registerNibForHeaderFooterView<Resource: NibResourceType>(_ nibResource: Resource) where Resource: ReuseIdentifierType, Resource.ReusableType: UIView
  {
    fatalError()
  }
}

public extension SeguePerformerType {

  @available(*, unavailable, renamed: "performSegue(withIdentifier:sender:)")
  func performSegueWithIdentifier(_ identifier: String, sender: Any?) {
    fatalError()
  }
}

public extension SeguePerformerType {

  @available(*, unavailable, renamed: "performSegue(withIdentifier:sender:)")
  public func performSegueWithIdentifier<Segue, Destination>(_ identifier: StoryboardSegueIdentifier<Segue, Self, Destination>, sender: Any?) {
    fatalError()
  }
}
