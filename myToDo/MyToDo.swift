//
//  MyToDo.swift
//  myToDo
//
//  Created by Chalam, Naga Rani on 4/8/19.
//  Copyright © 2019 Naga Rani, Chalam. All rights reserved.
//

import Foundation

class ToDoItem: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.title,forKey: "title")
        aCoder.encode(self.done, forKey: "done")
    }
    
    required init?(coder aDecoder: NSCoder) {
        //try to unserialize the "title" variable
        if let title =  aDecoder.decodeObject(forKey: "title") as? String{
            self.title = title
        }
        else{
            //there were no objects encoded with the key "title",
            //so thats an error
            return nil
        }
        
        //check if the key "done" exists, since decodeBool() always succeed
        if aDecoder.containsValue(forKey: "done"){
            self.done = aDecoder.decodeBool(forKey: "done")
        }
        else{
            //error
            return nil
        }
    }
    
    var title: String
    var done: Bool
    public init(title:String){
        self.title = title
        self.done = false
    }
}

extension ToDoItem{
    public class func getMockData()->[ToDoItem]{
        return[
        ToDoItem(title: "File Tax"),
        ToDoItem(title: "Book tickets"),
        ToDoItem(title: "Fix Sink"),
        ToDoItem(title: "Monthly checkin")
        ]
    }
}

//creates an extension of Collection type,
//but only if it is an array of TodoItem Objects.
extension Collection where Iterator.Element == ToDoItem
{
    //Builds the persitence URL. This is a location inside
    //the "Application Support" directory for the app
    private static func persistencePath() -> URL? {
        let url = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return url?.appendingPathComponent("todoitems.bin")
        
    }
    
    //write the array to the persistence
    func writeToPersistence() throws{
        if let url = Self.persistencePath(), let array = self as? NSArray{
            let data = NSKeyedArchiver.archivedData(withRootObject: array)
            try data.write(to:url)
        }
        else{
            throw NSError(domain: "com.example.MyToDo", code: 10, userInfo: nil)
        }
    }
    
    //read the array from persistence
    static func readFromPersistence() throws -> [ToDoItem]{
        if let url = persistencePath(), let data = (try Data(contentsOf: url) as Data?)
        {
            if let array = NSKeyedUnarchiver.unarchiveObject(with: data)as?[ToDoItem]
            {
                return array
            }
            else{
                throw NSError(domain: "com.example.MyToDo",code:11, userInfo:nil)
            }
        }
        else{
            throw NSError(domain: "com.example.MyToDo", code: 12, userInfo: nil)
        }
        
    }
}
