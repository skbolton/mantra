function (doc) {
  if (doc.document_type == "block") {
    emit(doc.positions.slice().reverse().join(''))
  }
}
