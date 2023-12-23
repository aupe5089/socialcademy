//
//  PostsViewModel.swift
//  Socialcademy
//
//  Created by Austin Pearman on 12/20/23.
//

import Foundation

@MainActor
class PostsViewModel: ObservableObject {
    
    //Declare an instance of the loadable enum with passed in type [Post]
    //Set the state to .loading by default
    @Published var posts: Loadable<[Post]> = .loading
    //Give the viewModel a repository instance to use
    private let postsRepository: PostsRepositoryProtocol
    
    //The post repository can be anything that conforms to the protocol
    //Set to a normal repository by default (e.g. not the preview stub)
    init(postsRepository: PostsRepositoryProtocol = PostsRepository()) {
        self.postsRepository = postsRepository
    }
    
    //This is needed because viewModel is isolated to Main Actor
    //Therefore we cannot just make a createAction(_:) method
    func makeCreateAction() -> NewPostForm.CreateAction {
        return { [weak self] post in
            //create the posts and post them to Firestore (can throw and is done asynchronously using await)
            try await self?.postsRepository.create(post)
            //Accessing the optional computed property of the Loadable enum through value
            self?.posts.value?.insert(post, at: 0)
        }
    }
    
    func makeDeleteAction(for post: Post) -> PostRow.DeleteAction {
        return { [weak self] in
            try await self?.postsRepository.delete(post)
            self?.posts.value?.removeAll { $0.id == post.id }
        }
    }
    
    func fetchPosts() {
        Task {
            do {
                //Set the loadable enum to .loaded
                //passing in a value of type [Posts] through the fetchPosts() repository function
                posts = .loaded(try await postsRepository.fetchPosts())
            } catch {
                //if this fails change the Loadable value of posts to .error with the associated error given through the catch block
                print("[PostsViewModel]: Could not fetch posts: \(error)")
                posts = .error(error)
            }
        }
    }
}
