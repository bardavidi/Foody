import SwiftUI
import Shared

struct BottomSheetView: View {
    let restaurant: Restaurant
    @Binding var favorites: [Restaurant]
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = RestaurantDetailsViewModel()
    @State private var userReviews: [GoogleReviewUI] = []
    @State private var isAddingReview = false
    @State private var newRating: Double = 5.0
    @State private var newText: String = ""
    @State private var newAuthor: String = ""

    private func toggleFavorite() {
        if let index = favorites.firstIndex(of: restaurant) {
            favorites.remove(at: index)
        } else {
            favorites.append(restaurant)
        }
    }

    var isFavorite: Bool {
        favorites.contains(restaurant)
    }

    var allReviews: [GoogleReviewUI] {
        viewModel.googleReviews.map { GoogleReviewUI(from: $0) } + userReviews
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(restaurant.name)
                .font(.title2)
                .bold()

            AsyncImage(url: URL(string: restaurant.photoUrl)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", restaurant.rating))
                    .font(.subheadline)
            }

            if !restaurant.address.isEmpty {
                Text(restaurant.address)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            HStack(spacing: 40) {
                VStack {
                    Button(action: { toggleFavorite() }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 24))
                            .foregroundColor(.pink)
                    }
                    Text("Favorite").font(.footnote).foregroundColor(.pink)
                }

                VStack {
                    Button(action: { isAddingReview = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    }
                    Text("Add review").font(.footnote).foregroundColor(.green)
                }

                VStack {
                    Button(action: {
                        if let url = URL(string: viewModel.googleMapsURL) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "map")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    Text("Maps").font(.footnote).foregroundColor(.blue)
                }

                VStack {
                    Button(action: {
                        if let url = URL(string: viewModel.websiteURL) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "globe")
                            .font(.system(size: 24))
                            .foregroundColor(.purple)
                    }
                    Text("Website").font(.footnote).foregroundColor(.purple)
                }
            }
            .padding(.top, 10)
            
            if !allReviews.isEmpty {
                Text("Reviews")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(allReviews) { review in
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", review.rating))
                                        .font(.subheadline)
                                }

                                Text("by \(review.author)")
                                    .font(.caption)
                                    .foregroundColor(Color(.darkGray))

                                Text(review.text)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.70)])
        .onAppear {
            Task {
                await viewModel.fetchDetails(for: restaurant.placeId)
            }
        }
        .sheet(isPresented: $isAddingReview) {
            VStack(spacing: 16) {
                Text("Add Your Review")
                    .font(.headline)

                TextField("Your name", text: $newAuthor)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                VStack {
                    Text("Rating: \(Int(newRating))")
                    Slider(value: $newRating, in: 1...5, step: 1)
                }

                TextField("Write your review...", text: $newText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Button("Submit") {
                    let newReview = GoogleReviewUI(
                        rating: newRating,
                        author: newAuthor.isEmpty ? "Anonymous" : newAuthor,
                        text: newText
                    )
                    userReviews.append(newReview)
                    isAddingReview = false
                    newAuthor = ""
                    newText = ""
                    newRating = 5.0
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel", role: .cancel) {
                    isAddingReview = false
                }
            }
            .padding()
        }
    }
}
