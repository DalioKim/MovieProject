/*
메인목록
 1.하단탭바
 2.영상메뉴 목록(테이블뷰로 구성)
 3.썸네일 + 영상은 각 커스텀 셀로 구성
 
 화면 작업 플로우
 1.각 셀을 구성한다.
 2.셀을 구성할때 유튜브 api로부터 썸네일을 받아온다.
 3.
 
 
 
 */

import UIKit
import SnapKit
import Alamofire





class MovieListViewController: UIViewController {
    
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }

    
    
    private var movieListTableViewController  = MovieListTableViewController()

    private let vIdeosListTableView: UITableView = {
        let vIdeosListTableView = UITableView()
        return vIdeosListTableView
    }()
    
    private var viewModel: MovieListViewModel!
    private var thumbnailRepository: ThumbnailRepository?


//싱글턴으로 뷰모델을 하나만 만든다.
    static func create(with viewModel: MovieListViewModel, thumbnailRepository : ThumbnailRepository) -> MovieListViewController {
        
        printIfDebug("ThumbnailListViewController create")
        
        let view = MovieListViewController()
        view.viewModel = viewModel
        view.thumbnailRepository = thumbnailRepository


        return view
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    
       
        

        debugPrint("ThumbnailListViewController viewDidLoad")
        debugPrint("viewDidLoad viewModel : \(viewModel)")

        setupBehaviours()


        setupViews()
        setupBehaviours()
        bind(to: viewModel)
        viewModel.didSetDefaultList()
        

      
    }
    


    
    private func bind(to viewModel: MovieListViewModel) {
        debugPrint("viewModel : \(viewModel)")

        viewModel.items.observe(on: self) { [weak self] _ in self?.updateItems() }
        viewModel.loading.observe(on: self) { [weak self] in self?.updateLoading($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
    }

    
    private func setupViews() {
        debugPrint("setupViews Model : \(viewModel)")
        
        movieListTableViewController.viewModel = viewModel
        movieListTableViewController.thumbnailRepository = thumbnailRepository

        vIdeosListTableView.rowHeight = MovieListItemCell.height
        vIdeosListTableView.register(MovieListItemCell.self, forCellReuseIdentifier: MovieListItemCell.reuseIdentifier)
        vIdeosListTableView.dataSource = movieListTableViewController
        vIdeosListTableView.delegate = movieListTableViewController
            self.view.addSubview(vIdeosListTableView)
        self.vIdeosListTableView.snp.makeConstraints { (make) -> Void in
            make.width.height.equalToSuperview() // 임의의 사이즈를 지정한다.
            
                   //make.center.equalTo(self.view) // Constraints의 중앙을 view에 맞춘다.
                }

        printIfDebug("setupViews viewmodel \(movieListTableViewController.viewModel.items.value.count)")

    }
    
    private func setupBehaviours() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }

    
    
    private func updateItems() {
        printIfDebug("updateItems")
        printIfDebug("update viewmodel \(movieListTableViewController.viewModel.items.value.count)")
        self.vIdeosListTableView.reloadData()

    }

    private func updateLoading(_ loading: MovieListItemViewModelLoading?) {

    }



    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
       // showAlert(title: viewModel.errorTitle, message: error)
    }
}
