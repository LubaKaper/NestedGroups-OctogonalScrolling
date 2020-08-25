//
//  ViewController.swift
//  NestedGroups-OctogonalScrolling
//
//  Created by Liubov Kaper  on 8/24/20.
//  Copyright © 2020 Luba Kaper. All rights reserved.
//

import UIKit

enum SectionKind: Int, CaseIterable {
    case first
    case second
    case third
    
    var itemCount: Int {
        switch self { // sectionKind
        case .first :
            return 1
        case .second:
            return 3
        case .third:
            return 2
        }
    }
    var nestedGroupHeight: NSCollectionLayoutDimension {
        switch self {
        case .first:
            return .fractionalWidth(0.7)
        case .second:
            return.fractionalWidth(0.7)
        case .third:
            return .fractionalWidth(0.7)
        }
    }
    var sectionTitle: String {
        switch self {
        case .first:
            return "Featured"
        case .second:
            return "New to iPhone?"
        case .third:
            return "Made for Kids"
        }
    }
}

class ViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Int>
    private var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Online App Store"
        configureCollectionView()
        configureDataSource()
    }
    
    private func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
        
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        }

    private func createLayout() -> UICollectionViewLayout {
      // item -> group -> section-> layoit
        
        // 2 ways to create layout
        // 1. use a given section
        // 2. use section provider which takes a closure
        // - section provider closure gets called
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // figure out what section we are deali ng with
            guard let sectionKind = SectionKind(rawValue: sectionIndex) else {
                fatalError()
            }
            
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let itemSpacing: CGFloat = 5
            item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)
            // group
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: sectionKind.itemCount) // 2 or 1
            
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.98), heightDimension: sectionKind.nestedGroupHeight)
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innerGroup])
            
            // section
            let section = NSCollectionLayoutSection(group: nestedGroup)
            
            // thi line makes each section scroll horizontally
            section.orthogonalScrollingBehavior = .continuous
            
            // adding header to section
            //1. define the size and add to the section
            // 2. register suppli mantary view
            // 3. dequeue supplimentary view
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            return section
        }
        return layout
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
                fatalError("could not dequeue a LabelCell")
            }
            cell.textLabel.text = "\(item)"
            cell.backgroundColor = .systemOrange
            cell.layer.cornerRadius = 10
            return cell
        })
        
        // dequeue the header view
        dataSource.supplementaryViewProvider = {
            (collectionView, kind, indexPath) in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView, let sectionKind = SectionKind(rawValue: indexPath.section) else {
                fatalError("")
            }
            headerView.textLabel.text = sectionKind.sectionTitle
            headerView.textLabel.textAlignment = .left
            headerView.textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            return headerView
        }
        
        // create initioal snapshot
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, Int>()
        // populate sections
        snapshot.appendSections([.first, .second, .third])
        snapshot.appendItems(Array(1...20), toSection: .first)
        snapshot.appendItems(Array(21...40), toSection: .second)
        snapshot.appendItems(Array(41...60), toSection: .third)
        dataSource.apply(snapshot,animatingDifferences: false)
    }
}

