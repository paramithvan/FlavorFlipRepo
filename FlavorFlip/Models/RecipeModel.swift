//
//  RecipeModel.swift
//  FlavorFlip
//
//  Created by Yonathan Handoyo on 07/12/23.
//

import Foundation

struct recipeModel {
    var documentID: String
    var imagePotrait: String?
    var name: String?
    var creator: String?
    var level: String?
    var time: String?
    var description: String?
    var ingredients: [String]?
    var steps: [String]?
}
