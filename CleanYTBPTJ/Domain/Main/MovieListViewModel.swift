
import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay

protocol MovieListViewModelInput {
    func refresh(query: String)
    func loadMore()
    func didCancelSearch()
    func didSelectItem(at index: Int)
}

protocol MovieListViewModel: MovieListViewModelInput {  // 삭제 예정
    var cellModels: [MovieListItemCellModel] { get }
    var cellModelsObs: Observable<[MovieListItemCellModel]> { get }
}

final class DefaultMovieListViewModel: MovieListViewModel {
    
    enum ViewAction {
        case popViewController
        case showDetail(viewModel: DefaultMovieListViewModel)
        case showFeature(itemNo: Int)
    }
    
    // MARK: - private
    
    private var moviesLoadTask: CancelDelegate? {
        willSet {
            moviesLoadTask?.cancel()
        }
    }
    
    // MARK: - Relay & Observer
    
    private let cellModelsRelay = BehaviorRelay<[MovieListItemCellModel]?>(value: nil)
    private let viewActionRelay = PublishRelay<ViewAction>() // 사용 예정
    private let disposeBag = DisposeBag()
    private let fetchStatusTypeRelay = BehaviorRelay<FetchStatusType>(value: .none(.initial))
    private let fetch = PublishRelay<FetchType>()
    private let queryRelay = BehaviorRelay<String>(value: "마블")
    
    var cellModelsObs: Observable<[MovieListItemCellModel]> {
        cellModelsRelay.map { $0 ?? [] }
    }
    var cellModels: [MovieListItemCellModel] {
        cellModelsRelay.value ?? []
    }
    var viewActionObs: Observable<ViewAction> {  // 사용 예정
        viewActionRelay.asObservable()
    }
    var fetchStatusTypeObs: Observable<FetchStatusType> {
        fetchStatusTypeRelay.asObservable()
    }
    
    // MARK: - paging
    
    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var nextPage: Int { (cellModels.count > 10) ? currentPage + 1 : currentPage }
    
    // MARK: - Init
    
    init() {
        bindFetch()
        fetch.accept(.initial)
    }
    
    // MARK: - Private
    
    private func bindFetch() {
        Observable.combineLatest(fetch, queryRelay)
            .flatMapLatest { [weak self] (fetchType, query) -> Observable<(Result<[MovieListItemCellModel], Error>)> in
                self?.fetchStatusTypeRelay.accept(.success(fetchType))
                return API.fetchMovieList(APITarget.search(query: query))
                    .asObservable()
                    .map {
                        $0.items.map { MovieListItemCellModel(movie: Movie(title: $0.title, path: $0.image)) }
                    }
                    .map { (.success($0)) }
                    .catch { .just((.failure($0))) }
            }
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let result):
                    let list = self.fetchStatusTypeRelay.value.type == .more ? (self.cellModelsRelay.value ?? []) + result : result
                    self.cellModelsRelay.accept(list)
                case .failure(_):
                    break
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - INPUT. View event methods

extension DefaultMovieListViewModel {
    func refresh(query: String) {
        guard !query.isEmpty else { return }
        fetch.accept(.refresh)
        queryRelay.accept(query)
    }
    
    func loadMore() {
        fetch.accept(.more)
    }
    
    func didCancelSearch() {
        moviesLoadTask?.cancel()
        moviesLoadTask = nil
    }
    
    //didSelectItem 기능 추가 예정
    func didSelectItem(at index: Int) {
        print("\(index)번 아이템")
    }
}
