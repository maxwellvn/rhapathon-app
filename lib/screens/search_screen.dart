import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/contact_log_store.dart';
import '../widgets/search/attendee_search_bar.dart';
import '../widgets/search/search_result_card.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const SearchScreen({super.key, required this.onLogout});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _total = 0;
  int _offset = 0;
  String _lastQuery = '';
  Timer? _debounce;

  String _userName = '';
  String _userPicture = '';

  Map<String, ContactRecord> _contactById = {};

  static const int _pageSize = 50;

  /// Not reached-out first; any saved outreach ([ContactRecord.hasReachedOut]) at the bottom.
  void _sortResultsByContactStatus() {
    _results.sort((a, b) {
      final idA = a['id'] as String? ?? '';
      final idB = b['id'] as String? ?? '';
      final reachedA = idA.isNotEmpty && (_contactById[idA]?.hasReachedOut == true) ? 1 : 0;
      final reachedB = idB.isNotEmpty && (_contactById[idB]?.hasReachedOut == true) ? 1 : 0;
      return reachedA.compareTo(reachedB);
    });
  }

  void _onSearchTextChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchTextChanged);
    _loadUser();
    _search('');
    _scrollController.addListener(_onScroll);
  }

  Future<void> _refreshOutreachForCurrentResults({required bool reset}) async {
    final ids = _results.map((e) => e['id'] as String?).whereType<String>().toList();
    if (ids.isEmpty) {
      if (mounted && reset) setState(() => _contactById = {});
      return;
    }
    final batch = await ContactLogStore.fetchBatch(ids);
    if (!mounted) return;
    setState(() {
      if (reset) {
        _contactById = Map<String, ContactRecord>.from(batch);
      } else {
        _contactById = {..._contactById, ...batch};
      }
      _sortResultsByContactStatus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onSearchTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('kc_user_name') ?? '';
      _userPicture = prefs.getString('kc_user_picture') ?? '';
    });
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }

  Future<void> _search(String query, {bool reset = true}) async {
    if (_loading) return;
    final offset = reset ? 0 : _offset;

    setState(() {
      _loading = reset;
      _loadingMore = !reset;
      _error = null;
      if (reset) {
        _results = [];
        _offset = 0;
      }
    });

    try {
      final data = await ApiService.search(query, limit: _pageSize, offset: offset);
      final rows = (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      setState(() {
        if (reset) {
          _results = rows;
        } else {
          _results = [..._results, ...rows];
        }
        _total = data['total'] as int? ?? 0;
        _offset = _results.length;
        _lastQuery = query;
      });
      await _refreshOutreachForCurrentResults(reset: reset);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        !_loading &&
        _results.length < _total) {
      _search(_lastQuery, reset: false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      widget.onLogout();
    }
  }

  void _openDetail(Map<String, dynamic> item) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(id: item['id'] as String),
      ),
    ).then((_) => _refreshOutreachForCurrentResults(reset: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Attendee Search', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_userName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: _logout,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFD4AF37),
                      backgroundImage: _userPicture.isNotEmpty ? NetworkImage(_userPicture) : null,
                      child: _userPicture.isEmpty
                          ? Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          AttendeeSearchBar(
            controller: _controller,
            onQueryChanged: _onQueryChanged,
          ),
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _total > 0
                        ? '$_total result${_total == 1 ? '' : 's'}'
                        : (_error == null ? 'No results' : ''),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A1A2E)),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              _controller.text.isEmpty
                                  ? 'No registrations found'
                                  : 'No results for "${_controller.text}"',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFFD4AF37),
                        onRefresh: () => _search(_lastQuery),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(
                            12,
                            4,
                            12,
                            MediaQuery.of(context).padding.bottom + 4,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _results.length + (_loadingMore ? 1 : 0),
                          itemBuilder: (ctx, i) {
                            if (i == _results.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final id = _results[i]['id'] as String? ?? '';
                            return SearchResultCard(
                              item: _results[i],
                              contact: id.isEmpty ? null : _contactById[id],
                              onTap: () => _openDetail(_results[i]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
