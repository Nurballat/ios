import UIKit

struct Profile {
    let initials: String
    let name: String
    let role: String
    let posts: String
    let followers: String
    let following: String
    let about: String
}

class ViewController: UIViewController {

    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var postsValueLabel: UILabel!
    @IBOutlet weak var followersValueLabel: UILabel!
    @IBOutlet weak var followingValueLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let profile = Profile(
            initials: "AB",
            name: "Aigerim Bekova",
            // long text test: swap in "Maximilian Alexander von Habsburg"
            role: "iOS Developer · Almaty",
            posts: "128",
            followers: "4.2K",
            following: "312",
            about: "Building banking apps in Swift. I like clean architecture, coffee and long walks in the mountains around Almaty."
        )
        fill(with: profile)
    }

    // only data goes into the views, layout is fully in the storyboard
    private func fill(with profile: Profile) {
        initialsLabel.text = profile.initials
        nameLabel.text = profile.name
        roleLabel.text = profile.role
        postsValueLabel.text = profile.posts
        followersValueLabel.text = profile.followers
        followingValueLabel.text = profile.following
        aboutLabel.text = profile.about
    }
}
