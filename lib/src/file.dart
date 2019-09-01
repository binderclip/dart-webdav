import 'package:xml/xml.dart' as xml;

class FileInfo {
  String path;
  String size;
  String modificationTime;
  String contentType;

  FileInfo(this.path, this.size, this.modificationTime, this.contentType);

  // Returns the decoded name of the file / folder without the whole path
  String get name {
    var path = !this.path.endsWith("/") ? this.path : this.path.substring(0, this.path.length - 1);
    return Uri.decodeFull(path
        .split("/")
        .last);
  }

  bool get isDirectory => this.contentType == "httpd/unix-directory";

  @override
  String toString() {
    return 'FileInfo{name: $name, isDirectory: $isDirectory ,path: $path, size: $size, modificationTime: $modificationTime, contentType: $contentType}';
  }
}

/// get filed [name] from the property node
String prop(dynamic prop, String name, [String defaultVal]) {
  if (prop is Map) {
    final val = prop['d:' + name];
    if (val == null) {
      return defaultVal;
    }
    return val;
  }
  return defaultVal;
}

List<FileInfo> treeFromWevDavXml(String xmlStr) {
  // Initialize a list to store the FileInfo Objects
  var tree = new List<FileInfo>();

  // parse the xml using the xml.parse method
  var xmlDocument = xml.parse(xmlStr);

  // Iterate over the response to find all folders / files and parse the information
  xmlDocument.findAllElements("d:response").forEach((response) {
    var davItemName = response.findElements("d:href").single.text;
    response
        .findElements("d:propstat")
        .single
        .findElements("d:prop")
        .forEach((element) {
      var contentLength =
          element
              .findElements("d:getcontentlength")
              .single
              .text;

      var lastModified = element
          .findElements("d:getlastmodified")
          .single
          .text;
      
      var contentType = element
          .findElements("d:getcontenttype")
          .single
          .text;

      // Add the just found file to the tree
      tree.add(new FileInfo(davItemName, contentLength, lastModified, contentType));
    });
  });

  // Return the tree
  return tree;
}
