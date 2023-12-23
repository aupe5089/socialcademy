//
//  PostsList.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import SwiftUI

struct PostsList: View {
    @StateObject var viewModel = PostsViewModel()
    
    @State private var searchText = ""
    @State private var showNewPostForm = false
    
    var body: some View {
        NavigationView {
            Group {
                //Switch on the case of the Lodable enum passed into posts
                switch viewModel.posts {
                //if the posts are still loading
                case .loading:
                    ProgressView()
                //if fetchPosts threw an error
                case let .error(error):
                    EmptyListView(
                        title: "Cannot Load Posts",
                        message: error.localizedDescription,
                        retryAction: {
                            viewModel.fetchPosts()
                        })
                //if there are no posts in the database
                case .empty:
                    EmptyListView(
                        title: "No Posts",
                        message: "There aren't an posts yet"
                    )
                //if posts have been successfully loaded
                case let .loaded(posts):
                    List(posts) { post in
                        if searchText.isEmpty || post.contains(searchText) {
                            PostRow(
                                post: post,
                                deleteAction: viewModel.makeDeleteAction(for: post)
                            )
                        }
                    }
                    .searchable(text: $searchText)
                    .animation(.default, value: posts)
                }
            }
            .navigationTitle("Posts")
            .toolbar {
                Button {
                    showNewPostForm = true
                } label: {
                    Label("New Post", systemImage: "square.and.pencil")
                }
            }
            .sheet(isPresented: $showNewPostForm) {
                //Show the form and set the action to post the form
                NewPostForm(createAction: viewModel.makeCreateAction())
            }
        }
        .onAppear {
            //Get the posts as the view appears
            viewModel.fetchPosts()
        }
    }
}

#if DEBUG
struct PostsList_Previews: PreviewProvider {
    
    static var previews: some View {
        ListPreview(state: .loaded([Post.testPost]))
        ListPreview(state: .empty)
        ListPreview(state: .error)
        ListPreview(state: .loading)
    }
    
    @MainActor
    private struct ListPreview: View {
        let state: Loadable<[Post]>
        
        var body: some View {
            let postsRepository = PostsRepositoryStub()
            let viewModel = PostsViewModel(postsRepository: postsRepository)
            PostsList(viewModel: viewModel)
        }
    }
}
#endif
