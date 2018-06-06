//
//  FirstViewController.swift
//  loopDigger
//
//  Created by Shiflet, Wesley (UMSL-Student) on 7/29/17.
//  Copyright © 2017 Shiflet, Wesley (UMSL-Student). All rights reserved.
//

import UIKit
import AVFoundation

struct ReadFile {
    static var arrayFloatValues:[Float] = []
    static var points:[CGFloat] = []
}
var trackOne: Track?
var songs:[Track] = []
//var songs:[String] = []
//var paths:[URL] = []
var audioPlayerOne = AVAudioPlayer()
var justSelectedLoop = false

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var songSelectionView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = songs[indexPath.row].trackName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) //row clicked
    {
        do {
            //            let audioPath = Bundle.main.path(forResource: songs[indexPath.row].0, ofType: ".mp3")
            //            try audioPlayerOne = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath() as URL)) Old method
            trackOne = songs[indexPath.row]
            try audioPlayerOne = AVAudioPlayer(contentsOf: trackOne!.pathToTrack)
            audioPlayerOne.enableRate = true
            audioPlayerOne.numberOfLoops = -1
            audioPlayerOne.play()
        } catch {
            print ("ERROR: File not found")
            return
        }
        tabBarController?.selectedIndex = 1
    }
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getSongNames()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSongNames()
    {
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
        do
        {
            let songPath = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for song in songPath
            {
                var mySong = song.absoluteString
                
                if mySong.contains(".mp3")
                {
                    let foundString = mySong.components(separatedBy: "/")
                    mySong = foundString[foundString.count-1]
                    mySong = mySong.replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: "%3F", with: "?").replacingOccurrences(of: "%21", with: "!").replacingOccurrences(of: ".mp3", with: "")
                    songs.append(Track(name: mySong,path: song))
//                    paths.append(song)
                }
            }
            
            songSelectionView.reloadData()
        }
        catch
        {
            
        }
    }


}

