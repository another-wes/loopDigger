//
//  TemporaryViewController.swift
//  loopDigger
//
//  Created by Shiflet, Wesley (UMSL-Student) on 8/1/17.
//  Copyright © 2017 Shiflet, Wesley (UMSL-Student). All rights reserved.
//

import UIKit
import AVFoundation

class TemporaryViewController: UITableViewController
{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return trackOne!.loops.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = trackOne!.loops[indexPath.row].trackName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) //row clicked
    {
        loopNumber = indexPath.row
        justSelectedLoop = true
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        getNames()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func getNames()
//    {
//        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
//        
//        do
//        {
//            let songPath = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
//            
//            for song in songPath
//            {
//                var mySong = song.absoluteString
//                
//                if mySong.contains(".mp3")
//                {
//                    let foundString = mySong.components(separatedBy: "/")
//                    mySong = foundString[foundString.count-1]
//                    mySong = mySong.replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: "%3F", with: "?").replacingOccurrences(of: "%21", with: "!").replacingOccurrences(of: ".mp3", with: "")
//                    songs.append(Track(name: mySong,path: song))
//                    //                    paths.append(song)
//                }
//            }
//            
//            songSelectionView.reloadData()
//        }
//        catch
//        {
//            
//        }
//    }
    
    
}

