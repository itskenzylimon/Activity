import 'dart:convert';

List<int> encodePart(String boundary, HttpBodyPart part) {
  /// The format of a multipart request body is:
  /// --boundary\r\n
  final header = '--$boundary\r\n'
      'content-type: ${part.mimeType}\r\n'
      'content-disposition: ${part.contentDispositionValue}\r\n\r\n';
  /// header + body + \r\n
  final headerBytes = utf8.encode(header);
  final partBytes = part.bodyBytes;
  final footerBytes = utf8.encode('\r\n');
  /// return the encoded part
  return [...headerBytes, ...partBytes, ...footerBytes];
}

class HttpBodyPart {
  final List<int> bodyBytes;
  final String mimeType;
  final String contentDispositionValue;

  /// Creates a new [HttpBodyPart] with the given [bodyBytes], [mimeType]
  /// and [contentDispositionValue].
  HttpBodyPart(this.bodyBytes, {this.mimeType = 'application/octet-stream',
    required this.contentDispositionValue});

  /// Creates a new [HttpBodyPart] from the given [value] and [name].
  /// The [mimeType] will be set to `text/plain` and the
  /// [contentDispositionValue] will be set to `form-data; name="$name"`.
  static HttpBodyPart fromString(String value, String name) {
    final bytes = utf8.encode(value);
    final disposition = 'form-data; name="$name"';
    return HttpBodyPart(bytes, mimeType: 'text/plain', contentDispositionValue: disposition);
  }
}