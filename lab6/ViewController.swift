import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var randomButton: UIButton!

    private let favorites = Favorite.all
    private var currentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        posterImageView.contentMode = .scaleAspectFit

        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping

        // initial state: the screen is never empty on launch
        showRandomFavorite()
    }

    @IBAction func randomButtonTapped(_ sender: UIButton) {
        showRandomFavorite()
    }

    private func showRandomFavorite() {
        let index = nextIndex()
        currentIndex = index
        show(favorites[index])
    }

    // picks any index except the current one, so the same movie never
    // appears twice in a row
    private func nextIndex() -> Int {
        guard favorites.count > 1 else { return 0 }
        guard let current = currentIndex else {
            return Int.random(in: 0..<favorites.count)
        }
        let offset = Int.random(in: 1..<favorites.count)
        return (current + offset) % favorites.count
    }

    // image, title and description are always updated together
    private func show(_ favorite: Favorite) {
        posterImageView.image = UIImage(named: favorite.imageName)
        titleLabel.text = favorite.title
        descriptionLabel.text = favorite.description
    }
}
