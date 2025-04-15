import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../api/pocketbase.dart';

Future<List<RecordModel>> getTeacherSearchResults(String q) async {
  final resultList = await pb
      .collection('teachers')
      .getList(
        page: 1,
        perPage: 20,
        filter: pb.filter(
          "email ~ {:search} || krz ~ {:search} || firstName ~ {:search} || secondName ~ {:search}",
          <String, String>{"search": q},
        ),
      );
  return resultList.items;
}

Future<RecordModel?> showTeacherSelector(
  BuildContext context, {
  List<String> excludeIds = const [],
}) async {
  RecordModel? finalResult;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: TeacherSelectorView(
          onTeacherSelected: (teacher) {
            Navigator.of(context).pop();
            finalResult = teacher;
          },
          excludeIds: excludeIds,
        ),
      );
    },
  );

  return finalResult;
}

class TeacherSelectorView extends StatefulWidget {
  const TeacherSelectorView({
    super.key,
    required this.onTeacherSelected,
    this.excludeIds = const [],
  });

  final Function(RecordModel) onTeacherSelected;
  final List<String> excludeIds;

  @override
  State<TeacherSelectorView> createState() => _TeacherSelectorViewState();
}

class _TeacherSelectorViewState extends State<TeacherSelectorView> {
  final TextEditingController _searchController = TextEditingController();
  List<RecordModel>? _searchResults;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final results = await getTeacherSearchResults(query);
      if (mounted) {
        setState(() {
          _searchResults =
              results
                  .where((teacher) => !widget.excludeIds.contains(teacher.id))
                  .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Fehler beim Suchen')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            'Lehrer auswählen',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Suche',
              hintText: 'Nach Name, Email oder Kürzel suchen',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                      : null,
            ),
            onChanged: (value) {
              _performSearch(value);
            },
          ),
        ),
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_searchResults == null || _searchResults!.isEmpty)
                  ? const Center(child: Text('Keine Ergebnisse'))
                  : ListView.builder(
                    itemCount: _searchResults!.length,
                    itemBuilder: (context, index) {
                      final teacher = _searchResults![index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          '${teacher.data['firstName']} ${teacher.data['secondName']}',
                        ),
                        subtitle: Text(
                          '${teacher.data['krz']} - ${teacher.data['email'] ?? 'Keine E-Mail'}',
                        ),
                        onTap: () => widget.onTeacherSelected(teacher),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
