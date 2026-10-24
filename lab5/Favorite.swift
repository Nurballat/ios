import Foundation

struct Favorite {
    let title: String
    let description: String
    let imageName: String
}

extension Favorite {
    static let all: [Favorite] = [
        Favorite(
            title: "A Beautiful Mind",
            description: "The story of mathematician John Nash, a brilliant mind who struggles with schizophrenia while changing economics forever.",
            imageName: "beautiful_mind"
        ),
        Favorite(
            title: "Interstellar",
            description: "Astronauts travel through a wormhole to find a new home for humanity as Earth runs out of time.",
            imageName: "interstellar"
        ),
        Favorite(
            title: "The Gentlemen",
            description: "A British drug lord tries to sell his marijuana empire, and chaos begins as everyone wants a piece of it.",
            imageName: "the_gentlemen"
        ),
        Favorite(
            title: "The Godfather",
            description: "The saga of the Corleone mafia family as aging Vito hands his empire to his reluctant son Michael.",
            imageName: "the_godfather"
        ),
        Favorite(
            title: "Captain Fantastic",
            description: "A father raises his six children off the grid in the forest until a family tragedy forces them back into society.",
            imageName: "captain_fantastic"
        ),
        Favorite(
            title: "Fight Club",
            description: "An office worker and a charismatic soap salesman start an underground fight club that spirals out of control.",
            imageName: "fight_club"
        ),
        Favorite(
            title: "The Matrix",
            description: "A hacker learns that his reality is a simulation and joins a rebellion against the machines.",
            imageName: "the_matrix"
        ),
        Favorite(
            title: "Harry Potter",
            description: "A boy discovers he is a wizard and starts at Hogwarts, where he finds friends, magic and a dark enemy.",
            imageName: "harry_potter"
        ),
        Favorite(
            title: "Iron Man",
            description: "Billionaire inventor Tony Stark builds a high-tech suit to escape captivity and becomes the hero Iron Man.",
            imageName: "iron_man"
        ),
        Favorite(
            title: "The Shawshank Redemption",
            description: "A banker wrongly sent to prison befriends a fellow inmate and never loses hope over decades behind bars.",
            imageName: "shawshank"
        )
    ]
}
