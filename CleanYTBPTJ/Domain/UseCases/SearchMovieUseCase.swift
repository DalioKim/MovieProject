
import Foundation

protocol SearchMovieUseCase {
    func execute(requestValue: SearchMovieUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
}


/*
 유스케이스에서 레포짓을 파라미터로 받는 이육가 뭐지?
 */
final class DefaultSearchMovieUseCase: SearchMovieUseCase {
 

    private let moviesRepository: MoviesRepository

    init(moviesRepository: MoviesRepository) {

        self.moviesRepository = moviesRepository
    }
    


    func execute(requestValue: SearchMovieUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
        printIfDebug("networkTask - execute")

        return moviesRepository.fetchMovieList(query: requestValue.query,
                                                page: requestValue.page,
                                                cached: cached,
                                                completion: { result in

//            if case .success = result {
//                self.MoviesQueriesRepository.saveRecentQuery(query: requestValue.query) { _ in }
//            }

            completion(result)
        })
    }
}

struct SearchMovieUseCaseRequestValue {
    let query: MovieQuery
    let page: Int
}