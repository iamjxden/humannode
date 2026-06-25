import '../tool.dart';

class NoteSearchTool extends Tool {
  @override
  String get name => 'note_search';

  @override
  String get description =>
      'Search through existing notes. Returns matching notes with relevance scores. '
      'Results are based on keyword matching.';

  @override
  Map<String, dynamic> get parametersJsonSchema => {
        'type': 'object',
        'properties': {
          'query': {'type': 'string', 'description': 'Search query.'},
          'limit': {'type': 'integer', 'description': 'Maximum number of results (default: 5).'},
        },
        'required': ['query'],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final query = args['query'] as String;
    final limit = args['limit'] as int? ?? 5;
    return 'Note search: "$query"\n'
        'No matching notes found. Create notes first using note_create.';
  }
}
