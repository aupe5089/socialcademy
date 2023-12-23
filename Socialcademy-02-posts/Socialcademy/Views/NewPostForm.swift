//
//  NewPostForm.swift
//  Socialcademy
//
//  Created by Austin Pearman on 12/20/23.
//

import SwiftUI

struct NewPostForm: View {
    
    @State private var post = Post(title: "", content: "", authorName: "")
    typealias CreateAction = (Post) async throws -> Void
    let createAction: CreateAction
    
    @State private var state = FormState.idle
    
    //used to dismiss the sheet
    @Environment (\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $post.title)
                    TextField("Author Name", text: $post.authorName)
                }
                Section("Content") {
                    TextEditor(text: $post.content)
                        .multilineTextAlignment(.leading)
                }
                Button(action: createPost) {
                    if state == .working {
                        ProgressView()
                    } else {
                        Text("Create Post")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .listRowBackground(Color.accentColor)
            }
            .navigationTitle("New Post")
            .onSubmit(createPost) //allows users to use the return key on the keyboard instead of just relying on the button
        }
        .disabled(state == .working) //disable input fields when the state is .working
        .alert("Cannot Create Post", isPresented: $state.isError, actions: {}) {
            Text("Sorry, something went wrong")
        }
    }
    
    private func createPost() {
        Task {
            do {
                try await createAction(post)
                dismiss()
            } catch {
                print("[NewPostForm] Cannot create post: \(error)")
                state = .error
            }
        }
    }
}

private extension NewPostForm {
    enum FormState {
        case idle, working, error
        
        var isError: Bool {
            get {
                self == .error
            }
            set {
                guard !newValue else { return }
                self = .idle
            }
        }
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(createAction: { _ in })
    }
}
