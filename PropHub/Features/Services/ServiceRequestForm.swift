import SwiftUI
import PhotosUI

/// Form for creating a new service request with category, description, photo, and preferred date.
struct ServiceRequestForm: View {
    let unitId: String
    @ObservedObject var viewModel: ServiceViewModel
    @SwiftUI.Environment(\.dismiss) private var dismiss

    @State private var category = "General"
    @State private var subject = ""
    @State private var description = ""
    @State private var preferredDate = Date()
    @State private var usePreferredDate = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoImage: UIImage?

    private let categories = ["Plumbing", "Electrical", "HVAC", "General", "Maintenance"]

    var body: some View {
        NavigationStack {
            Form {
                // Category
                Section(NSLocalizedString("category_section", comment: "")) {
                    Picker(
                        NSLocalizedString("category_label", comment: ""),
                        selection: $category
                    ) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .accessibilityLabel(NSLocalizedString("category_label", comment: ""))
                }

                // Details
                Section(NSLocalizedString("details_section", comment: "")) {
                    TextField(
                        NSLocalizedString("subject_placeholder", comment: ""),
                        text: $subject
                    )
                    .accessibilityLabel(NSLocalizedString("subject_label", comment: ""))

                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .accessibilityLabel(NSLocalizedString("description_label", comment: ""))
                }

                // Photo
                Section(NSLocalizedString("photo_section", comment: "")) {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text(photoImage == nil
                                 ? NSLocalizedString("add_photo", comment: "")
                                 : NSLocalizedString("change_photo", comment: ""))
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                photoImage = UIImage(data: data)
                            }
                        }
                    }

                    if let image = photoImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .accessibilityLabel(NSLocalizedString("attached_photo", comment: ""))
                    }
                }

                // Preferred Date
                Section(NSLocalizedString("preferred_date_section", comment: "")) {
                    Toggle(
                        NSLocalizedString("set_preferred_date", comment: ""),
                        isOn: $usePreferredDate
                    )
                    if usePreferredDate {
                        DatePicker(
                            NSLocalizedString("date_label", comment: ""),
                            selection: $preferredDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle(NSLocalizedString("new_request", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("submit", comment: "")) {
                        Task { await submitRequest() }
                    }
                    .disabled(subject.isEmpty || viewModel.isSubmitting)
                    .fontWeight(.semibold)
                }
            }
            .loading(viewModel.isSubmitting)
            .alert(
                NSLocalizedString("success_title", comment: ""),
                isPresented: Binding(
                    get: { viewModel.successMessage != nil },
                    set: { if !$0 { viewModel.successMessage = nil; dismiss() } }
                )
            ) {
                Button(NSLocalizedString("ok", comment: "")) {
                    dismiss()
                }
            } message: {
                if let message = viewModel.successMessage {
                    Text(message)
                }
            }
        }
    }

    private func submitRequest() async {
        await viewModel.createServiceRequest(
            unitId: unitId,
            category: category,
            subject: subject,
            description: description,
            preferredDate: usePreferredDate ? preferredDate : nil,
            assetId: nil,
            photo: photoImage
        )
    }
}
