//
//  DependencyContainer.swift
//  SpaceF
//
//  Created by Mariano Perugini on 10/06/2025.
//

import Foundation

protocol DependencyContainerProtocol {
    func resolve<T>() -> T
}

class DependencyContainer: DependencyContainerProtocol {
    static let shared = DependencyContainer()
    
    private var dependencies: [String: Any] = [:]
    
    private init() {
        registerDependencies()
    }
    
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let dependency = dependencies[key] as? T else {
            fatalError("Dependency \(key) not registered")
        }
        return dependency
    }
    
    private func register<T>(_ dependency: T) {
        let key = String(describing: T.self)
        dependencies[key] = dependency
    }
    
    private func registerDependencies() {

        register(RemoteDataSource() as RemoteDataSourceProtocol)
        register(LocalDataSource() as LocalDataSourceProtocol)

        let remoteDataSource: RemoteDataSourceProtocol = resolve()
        let localDataSource: LocalDataSourceProtocol = resolve()
        register(ArticleRepository(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource
        ) as ArticleRepositoryProtocol)
        
        let repository: ArticleRepositoryProtocol = resolve()
        register(FetchArticlesUseCase(repository: repository) as FetchArticlesUseCaseProtocol)
        register(SearchArticlesUseCase(repository: repository) as SearchArticlesUseCaseProtocol)
    }
}
