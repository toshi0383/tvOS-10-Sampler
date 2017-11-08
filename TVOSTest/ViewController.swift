//
//  ViewController.swift
//  TVOSTest
//
//  Created by toshi0383 on 7/14/16.
//  Copyright © 2016 Toshihiro Suzuki. All rights reserved.
//

import UIKit
import AVKit

class ViewController: AVPlayerViewController {

    @IBInspectable var customedUI: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let urlstr = "http://eastasias.blob.core.windows.net/video/hlstest/BBB/BBB_3/BBB_3.m3u8"
        DispatchQueue.global().async {
            let url = URL(string: urlstr)!
            let asset = AVURLAsset(url: url)
            asset.loadValuesAsynchronously(forKeys: ["tracks", "playable"]) {
                guard asset.isPlayable else {fatalError()}
                let item = AVPlayerItem(asset: asset)
                self.player = AVPlayer(playerItem: item)
                self.player?.play()
                self.setProposal()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.replaceCurrentItem(with: nil)
        (contentProposalViewController as? ContentProposalViewController)?.shouldDismiss = true
    }

    func setProposal() {
        let image = UIImage(named: "368.jpeg")!
        let proposal = AVContentProposal(contentTimeForTransition: CMTime(seconds: 1.0, preferredTimescale: 1), title: "hello", previewImage: image)
        let str = "http://devstreaming.apple.com/videos/wwdc/2016/506ms2tv71tcduwp3dm/506/hls_vod_mvp.m3u8"
        proposal.url = URL(string: str)!
        player?.currentItem?.nextContentProposal = proposal
        if customedUI {
            self.delegate = self
        }
    }
}

extension ViewController: AVPlayerViewControllerDelegate {
    @objc(playerViewController:didAcceptContentProposal:)
    internal func playerViewController(_ playerViewController: AVPlayerViewController, didAccept proposal: AVContentProposal) {
        guard let player = playerViewController.player, let nextURL = proposal.url else {return}
        let next = AVPlayerItem(url: nextURL)
        player.replaceCurrentItem(with: next)
    }
}

extension ViewController {
    @objc(playerViewController:shouldPresentContentProposal:)
    func playerViewController(_ playerViewController: AVPlayerViewController, shouldPresent proposal: AVContentProposal) -> Bool {
        let bundle = Bundle.main
        let sb = UIStoryboard(name: "ContentProposal", bundle: bundle)
        playerViewController.contentProposalViewController = sb.instantiateInitialViewController() as! ContentProposalViewController
        return true
    }
}

class ContentProposalViewController: AVContentProposalViewController {
    var shouldDismiss: Bool = false {
        didSet { dismissIfNeeded() }
    }
    @IBOutlet private var button: UIButton! {
        didSet { button.alpha = 0.0 }
    }
    @IBOutlet private var textView: UITextView! {
        didSet { textView.alpha = 0.0 }
    }
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [button]
    }
    override var preferredPlayerViewFrame: CGRect {
        return CGRect(x: 432, y: 20, width: 1056, height: 594)
    }
    @IBAction private func button(sender: UIButton!) {
        dismissContentProposal(for: .accept, animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
        if !shouldDismiss {
            UIView.animate(withDuration: 0.2) {
                self.button.alpha = 1.0
                self.textView.alpha = 1.0
            }
        } else {
            dismissIfNeeded()
        }
    }
    private func dismissIfNeeded() {
        if shouldDismiss {
            DispatchQueue.main.async { [weak self] in
                self?.button?.alpha = 0.0
                self?.textView?.alpha = 0.0
                self?.dismissContentProposal(for: .reject, animated: false, completion: nil)
            }
        }
    }
    deinit {
        print(#function)
    }
}
