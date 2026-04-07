import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/contact_log_store.dart';
import '../widgets/detail/attendee_detail_body.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  final _notesController = TextEditingController();
  final _notesFocusNode = FocusNode();
  ContactRecord _outreach = ContactRecord(updatedAt: DateTime.now());
  bool _outreachSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadOutreach();
  }

  @override
  void dispose() {
    _notesFocusNode.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadOutreach() async {
    final r = await ContactLogStore.fetch(widget.id);
    if (!mounted) return;
    if (r != null) {
      setState(() {
        _outreach = r;
        _notesController.text = r.notes;
      });
    }
  }

  String? _safeOutcomeKey(String? key) {
    if (key == null || key.isEmpty) return null;
    return ContactOutcomes.labels.containsKey(key) ? key : null;
  }

  Future<void> _showOutreachResultDialog({required bool success, String? message}) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(success ? 'Saved' : 'Not saved'),
        content: Text(
          success
              ? 'Outreach details were saved.'
              : (message ?? 'Something went wrong. Try again.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _setContacted(bool value) {
    if (_outreachSaving) return;
    setState(() {
      _outreach = ContactRecord(
        contacted: value,
        outcome: _outreach.outcome,
        notes: _notesController.text.trim(),
        updatedAt: _outreach.updatedAt,
      );
    });
  }

  void _setOutcome(String? value) {
    if (_outreachSaving) return;
    setState(() {
      _outreach = ContactRecord(
        contacted: _outreach.contacted,
        outcome: value,
        notes: _notesController.text.trim(),
        updatedAt: _outreach.updatedAt,
      );
    });
  }

  Future<void> _saveOutreachNow() async {
    if (_outreachSaving) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final next = ContactRecord(
      contacted: _outreach.contacted,
      outcome: _outreach.outcome,
      notes: _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    setState(() => _outreachSaving = true);
    try {
      await ContactLogStore.save(widget.id, next);
      if (!mounted) return;
      setState(() => _outreach = next);
      await _showOutreachResultDialog(success: true);
    } catch (e) {
      if (!mounted) return;
      var msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
      if (msg.length > 400) msg = '${msg.substring(0, 400)}…';
      await _showOutreachResultDialog(success: false, message: msg.isEmpty ? null : msg);
    } finally {
      if (mounted) setState(() => _outreachSaving = false);
    }
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getDetail(widget.id);
      if (!mounted) return;
      if (res['success'] == true) {
        setState(() {
          _data = res['data'] as Map<String, dynamic>;
          _loading = false;
        });
      } else {
        setState(() {
          _error = res['message'] ?? 'Not found';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Attendee Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A1A2E)))
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : AttendeeDetailBody(
                    data: _data!,
                    outreachSaving: _outreachSaving,
                    contacted: _outreach.contacted,
                    outcomeValue: _safeOutcomeKey(_outreach.outcome),
                    notesController: _notesController,
                    notesFocusNode: _notesFocusNode,
                    onContactedChanged: _setContacted,
                    onOutcomeChanged: _setOutcome,
                    onSave: _saveOutreachNow,
                  ),
      ),
    );
  }
}
