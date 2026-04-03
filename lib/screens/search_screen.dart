import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
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

  static const int _pageSize = 50;

  void _onSearchTextChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchTextChanged);
    _loadUser();
    _search('');
    _scrollController.addListener(_onScroll);
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
      _userName    = prefs.getString('kc_user_name') ?? '';
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
      if (reset) { _results = []; _offset = 0; }
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
        _total     = data['total'] as int? ?? 0;
        _offset    = _results.length;
        _lastQuery = query;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() { _loading = false; _loadingMore = false; });
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
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
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
                      backgroundImage: _userPicture.isNotEmpty
                          ? NetworkImage(_userPicture)
                          : null,
                      child: _userPicture.isEmpty
                          ? Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
          // Search bar
          Container(
            color: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name, email, phone, KingsChat...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.6)),
                        onPressed: () {
                          _controller.clear();
                          _onQueryChanged('');
                        },
                      )
                    : null,
                fillColor: Colors.white.withValues(alpha: 0.1),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                ),
              ),
            ),
          ),

          // Results count
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

          // Error
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),

          // Results list
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
                          padding: EdgeInsets.fromLTRB(12, 4, 12, MediaQuery.of(context).padding.bottom + 4),
                          itemCount: _results.length + (_loadingMore ? 1 : 0),
                          itemBuilder: (ctx, i) {
                            if (i == _results.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return _ResultCard(
                              item: _results[i],
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

  void _openDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(id: item['id'] as String),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _ResultCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title     = item['title'] as String? ?? '';
    final firstName = item['first_name'] as String? ?? '';
    final lastName  = item['last_name'] as String? ?? '';
    final fullName  = '$title $firstName $lastName'.trim();
    final email     = item['email'] as String? ?? '';
    final phone     = item['phone'] as String? ?? '';
    final kcUser    = item['kingschat_username'] as String? ?? '';
    final zone      = item['zone_name'] as String? ?? '';
    final church    = item['church_name'] as String? ?? '';
    final lang      = item['language_preference'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1A1A2E),
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (email.isNotEmpty)
                      Text(email,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    if (phone.isNotEmpty)
                      Text(phone,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    if (kcUser.isNotEmpty)
                      Text(kcUser,
                          style: const TextStyle(
                              color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.w500)),
                    if (zone.isNotEmpty || church.isNotEmpty)
                      Text(
                        [zone, church].where((s) => s.isNotEmpty).join(' · '),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Language badge + arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (lang.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        lang.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
