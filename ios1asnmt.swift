// Assignment 1 

var firstName: String = "Nurbolat"
var lastName: String = "Tursyn"
var age: Int
var birthYear: Int = 2006
var isStudent: Bool = true
var height: Double = 1.75
var city: String = "Almaty"

let currentYear: Int = 2026
age = currentYear - birthYear


var hobby: String = "Basketball"
var numberOfHobbies: Int = 3
var favoriteNumber: Int = 27
var isHobbyCreative: Bool = false


var 🏀favoriteSport: String = "Basketball"
var favoriteEmoji: String = "🏀"


var futureGoals: String = "I wanna be happy with MY people"


var lifeStory: String = """
My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear). \
I live in \(city). I am currently \(isStudent ? "a student" : "not a student"). \
I am \(String(format: "%.2f", height)) meters tall. \
I enjoy \(hobby), gym, and books. My hobby is \(isHobbyCreative ? "creative" : "not creative"). \
I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber). \
My favorite emoji is \(favoriteEmoji) \(🏀favoriteSport). \(futureGoals).
"""


print(lifeStory)
