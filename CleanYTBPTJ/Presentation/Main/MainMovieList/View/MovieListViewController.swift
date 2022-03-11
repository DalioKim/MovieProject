
import UIKit
import SnapKit

class MovieListViewController: UIViewController {
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }
    
    private let movieListView: UICollectionView = {
        let cellSize = CGSize(width: 330 , height: 300)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.itemSize = cellSize
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let movieListView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        movieListView.register(MovieListItemCell.self, forCellWithReuseIdentifier: MovieListItemCell.reuseIdentifier)

        return movieListView
    }()
    
    private var viewModel: MovieListViewModel!
    private var thumbnailRepository: ThumbnailRepository?
    
    static func create(with viewModel: MovieListViewModel, thumbnailRepository: ThumbnailRepository) -> MovieListViewController {
        let view = MovieListViewController()
        view.viewModel = viewModel
        view.thumbnailRepository = thumbnailRepository
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBehaviours()
        bind(to: viewModel)
    }
    
    private func bind(to viewModel: MovieListViewModel) {
        debugPrint("viewModel: \(viewModel)")
        (viewModel as? DefaultMovieListViewModel).flatMap { $0.delegate = self }
    }
    
    private func setupViews() {
        movieListView.delegate = self
        movieListView.dataSource = self
        view.addSubview(movieListView)
        movieListView.snp.makeConstraints {
            $0.width.height.equalToSuperview()
        }
        
    }
    
    private func setupBehaviours() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }
}

// MARK: -  ViewModel 대리자 패턴

extension MovieListViewController: MovieListViewModelDelegate {
    
    func didLoadData() {
        print("모델 카운트: \(viewModel.movies.count)")
        movieListView.reloadData()
    }
}

// MARK: -  CollectionViewDelegate

extension MovieListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListItemCell.reuseIdentifier, for: indexPath) as? MovieListItemCell else { fatalError() }
        cell.bind(with: viewModel.movies[safe:indexPath.item], thumbnailRepository: thumbnailRepository)
        return cell
    }
}

