function (doc) {
  if (doc.document_type == "page") {
    emit(doc._id)
  }
}
