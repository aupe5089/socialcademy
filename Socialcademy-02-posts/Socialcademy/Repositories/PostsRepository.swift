//
//  PostsRepository.swift
//  Socialcademy
//
//  Created by Austin Pearman on 12/20/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

//Protocol used so that we can pass either the stub or the full repository into initializers
protocol PostsRepositoryProtocol {
    func fetchPosts() async throws -> [Post]
    func create(_ post: Post) async throws
    func delete(_ post: Post) async throws
}

//For preview use only
#if DEBUG
struct PostsRepositoryStub: PostsRepositoryProtocol {
    func fetchPosts() async throws -> [Post] {
        return []
    }
    
    func delete(_ post: Post) async throws {}
    func create(_ post: Post) async throws {}
}
#endif

//This is the repository actaully used for in app calls to the server
struct PostsRepository: PostsRepositoryProtocol {
    //get a reference to the collection in Firestore
    let postsReference = Firestore.firestore().collection("posts")
    
    //asynchronous function that creates a post
    func create(_ post: Post) async throws {
        //get a reference to the specific document
        let document = postsReference.document(post.id.uuidString)
        //set the data in the form of a post
        try await document.setData(from: post)
    }
    
    func delete(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.delete()
    }
    
    func fetchPosts() async throws -> [Post] {
        //get the querySnapshot of all documents
        let snapshot = try await postsReference.order(by: "timestamp", descending: true).getDocuments()
        
        //convert eachd ocuments data in to the post structure
        //Compact map filters out nil values
        let posts = snapshot.documents.compactMap { document in
            try! document.data(as: Post.self)!
        }
        
        return posts
    }
}

private extension DocumentReference {
    //overriding the setData in order to ensure that it works in the asynchronous environment
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Method only throws if there’s an encoding error, which indicates a problem with our model.
            // We handled this with a force try, while all other errors are passed to the completion handler.
            try! setData(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
