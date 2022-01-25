
import Foundation

protocol EnterMainUseCase {
    func execute(requestValue: EnterMainUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
}


final class DefaultEnterMainUseCase: EnterMainUseCase {
    
    
    func execute(requestValue: EnterMainUseCaseRequestValue, cached: @escaping (MoviesPage) -> Void, completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
        printIfDebug("networkTask - execute")

                return moviesRepository.fetchMovieList(query: requestValue.query,
                                                        page: requestValue.page,
                                                        cached: cached,
                                                        completion: { result in
        
        
                    completion(result)
                })
    }
    
 
    

    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {

        self.moviesRepository = moviesRepository
    }
    


}

struct EnterMainUseCaseRequestValue {
    //let query: VideoQuery
    let query: MovieQuery
    let page: Int
}