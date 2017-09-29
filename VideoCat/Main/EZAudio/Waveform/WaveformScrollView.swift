//
//  WaveformScrollView.swift
//  VideoCat
//
//  Created by Vito on 28/09/2017.
//  Copyright © 2017 Vito. All rights reserved.
//

import UIKit

private var audioFile: EZAudioFile?

extension WaveformScrollView {
    func loadVoice(from url: URL, secondsWidth: CGFloat) {
        audioFile = EZAudioFile(url: url)
        let width = secondsWidth * CGFloat(audioFile?.duration ?? 0)
        audioFile?.getWaveformData(withNumberOfPoints: UInt32(width), completion: { [weak self] (buffers, bufferSize) in
            guard let strongSelf = self else { return }
            if let points = buffers?[0] {
                var wavefromPoints = [Float]()
                for index in 0..<bufferSize {
                    wavefromPoints.append(points[Int(index)])
                }
                strongSelf.updatePoints(wavefromPoints)
            }
        })
    }
}

private let WaveFormCellIdentifier = "WaveFormCellIdentifier"

class WaveformScrollView: UIView {

    fileprivate(set) var viewModel = WaveformScrollViewModel()
    fileprivate var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let frame = bounds
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(WaveformCell.self, forCellWithReuseIdentifier: WaveFormCellIdentifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func updatePoints(_ points: [Float]) {
        viewModel.points = points
        collectionView.reloadData()
    }
    
}

extension WaveformScrollView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WaveFormCellIdentifier, for: indexPath)
        if let cell = cell as? WaveformCell {
            let item = viewModel.items[indexPath.item]
            cell.configure(points: item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize.zero
        let item = viewModel.items[indexPath.item]
        size.width = CGFloat(item.count)
        size.height = collectionView.frame.height
        return size
    }
    
}

class WaveformCell: UICollectionViewCell {
    
    var waveformView: WaveformView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        waveformView = WaveformView()
        contentView.addSubview(waveformView)
        
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        waveformView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        waveformView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        waveformView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func configure(points: [Float]) {
        waveformView.updateSampleData(data: points)
        waveformView.layoutIfNeeded()
    }
    
}

class WaveformScrollViewModel {
    
    var points = [Float]() {
        didSet {
            var items = [[Float]]()
            
            let itemCount = { () -> Int in
                if points.count == 0 {
                    return 0
                }
                return ((points.count - 1) / itemPointCount) + 1
            }()
            
            for index in 0..<itemCount {
                var item = [Float]()
                let startPosition = index * itemPointCount
                for i in startPosition..<(startPosition + itemPointCount) {
                    if i >= points.count {
                        item.append(0)
                        break
                    }
                    
                    if i == 0 {
                        item.append(0)
                    }
                    
                    let value = points[i]
                    item.append(value)
                }
                items.append(item)
            }
            
            self.items = items
        }
    }
    
    var itemPointCount = 50
    var items: [[Float]] = []
}