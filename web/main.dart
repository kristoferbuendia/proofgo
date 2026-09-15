import 'dart:async';
import 'dart:convert';
import 'dart:html';

const _profileKey = 'verifyit.dart.profile';
const _eventsKey = 'verifyit.dart.events';
const _doneKey = 'verifyit.dart.done';
const _themeKey = 'verifyit.dart.theme';

const departments = <String>[
  'Infirmary',
  'Library',
  'Guidance',
  'Department/DSC',
  'SSC/Supreme Student Council',
  'Program Director',
  'Sports',
  'Registrar',
  'Finance',
];

final defaultEvents = <Map<String, dynamic>>[
  {
    'id': 'innovation',
    'title': 'Campus General Assembly',
    'tag': 'GENERAL EVENT',
    'date': 'Sep 15, 2026',
    'time': '9:00 AM – 11:00 AM',
    'location': 'Main Auditorium',
    'requirement': 'Department/DSC',
  },
  {
    'id': 'pe-signature',
    'title': 'Student Leadership Forum',
    'tag': 'GENERAL EVENT',
    'date': 'Sep 16, 2026',
    'time': '1:00 PM – 3:00 PM',
    'location': 'Campus Activity Center',
    'requirement': 'SSC/Supreme Student Council',
  },
  {
    'id': 'library',
    'title': 'Career and Wellness Fair',
    'tag': 'GENERAL EVENT',
    'date': 'Sep 17, 2026',
    'time': '10:00 AM – 3:00 PM',
    'location': 'Open Grounds',
    'requirement': 'Guidance',
  },
  {
    'id': 'finance',
    'title': 'Community Engagement Day',
    'tag': 'GENERAL EVENT',
    'date': 'Sep 18, 2026',
    'time': '8:00 AM – 12:00 PM',
    'location': 'Campus Quadrangle',
    'requirement': 'Program Director',
  },
];

Element get app => querySelector('#app')!;
Map<String, dynamic>? profile;
List<Map<String, dynamic>> events = [];
Set<String> completed = {};
String page = 'dashboard';
String? proofDataUrl;
String? selectedEventId;
String? freshlyCompleted;
bool proofSubmitted = false;

void main() {
  _loadState();
  _applyTheme(window.localStorage[_themeKey] ?? 'light');
  if (profile == null) {
    _showProfileForm(firstRun: true);
  } else {
    render();
  }
}

void _loadState() {
  profile = _mapFromStorage(_profileKey);
  final savedEvents = _listFromStorage(_eventsKey);
  events = savedEvents.isEmpty
      ? defaultEvents.map((e) => Map<String, dynamic>.from(e)).toList()
      : savedEvents;
  _upgradeBuiltInEvents();
  final savedDone =
      jsonDecode(window.localStorage[_doneKey] ?? '[]') as List<dynamic>;
  completed = savedDone.map((e) => e.toString()).toSet();
}

void _upgradeBuiltInEvents() {
  final replacements = {for (final event in defaultEvents) event['id']: event};
  events = events.map((event) {
    final replacement = replacements[event['id']];
    return replacement == null ? event : Map<String, dynamic>.from(replacement);
  }).toList();
}

Map<String, dynamic>? _mapFromStorage(String key) {
  final raw = window.localStorage[key];
  if (raw == null) return null;
  try {
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  } catch (_) {
    return null;
  }
}

List<Map<String, dynamic>> _listFromStorage(String key) {
  final raw = window.localStorage[key];
  if (raw == null) return [];
  try {
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  } catch (_) {
    return [];
  }
}

String _e(Object? value) =>
    const HtmlEscape(HtmlEscapeMode.element).convert(value?.toString() ?? '');
String _initials() => (profile?['name'] ?? 'Student')
    .toString()
    .trim()
    .split(RegExp(r'\s+'))
    .take(2)
    .map((e) => e.isEmpty ? '' : e[0].toUpperCase())
    .join();
String _firstName() => (profile?['name'] ?? 'Student')
    .toString()
    .trim()
    .split(RegExp(r'\s+'))
    .first;

String _icon(String name, {String size = '20'}) {
  const paths = <String, String>{
    'check': '<path d="m5 12 4.2 4L19 6"/>',
    'grid':
        '<rect x="4" y="4" width="6" height="6" rx="1"/><rect x="14" y="4" width="6" height="6" rx="1"/><rect x="4" y="14" width="6" height="6" rx="1"/><rect x="14" y="14" width="6" height="6" rx="1"/>',
    'calendar':
        '<rect x="4" y="5" width="16" height="15" rx="2"/><path d="M8 3v4m8-4v4M4 10h16"/>',
    'upload': '<path d="M12 16V4m0 0L7.5 8.5M12 4l4.5 4.5M5 20h14"/>',
    'user':
        '<circle cx="12" cy="8" r="3.5"/><path d="M5 20c.7-3.5 3.2-5.5 7-5.5s6.3 2 7 5.5"/>',
    'search': '<circle cx="10.8" cy="10.8" r="5.8"/><path d="m16 16 3.6 3.6"/>',
    'plus': '<path d="M12 5v14M5 12h14"/>',
    'clock': '<circle cx="12" cy="12" r="8"/><path d="M12 7.5V12l3 2"/>',
    'pin':
        '<path d="M19 10c0 5-7 10-7 10S5 15 5 10a7 7 0 1 1 14 0Z"/><circle cx="12" cy="10" r="2"/>',
    'medical':
        '<path d="M12 20s-7-4.4-7-10a3.7 3.7 0 0 1 6.5-2.4L12 8l.5-.4A3.7 3.7 0 0 1 19 10c0 5.6-7 10-7 10Z"/><path d="M12 7v6m-3-3h6"/>',
    'book':
        '<path d="M5 4.5A2.5 2.5 0 0 1 7.5 4H20v15H7.5A2.5 2.5 0 0 0 5 21.5v-17Z"/><path d="M5 19.5A2.5 2.5 0 0 1 7.5 17H20"/>',
    'compass':
        '<circle cx="12" cy="12" r="8"/><path d="m14.8 9.2-1.7 3.9-3.9 1.7 1.7-3.9 3.9-1.7Z"/>',
    'trophy':
        '<path d="M8 4h8v5a4 4 0 0 1-8 0V4Z"/><path d="M8 6H5v1a4 4 0 0 0 4 4m7-5h3v1a4 4 0 0 1-4 4M12 13v4m-3 3h6"/>',
    'wallet':
        '<path d="M5 7.5V6a2 2 0 0 1 2-2h11v16H7a2 2 0 0 1-2-2V7.5Z"/><path d="M5 8h14v5H5"/><circle cx="15" cy="10.5" r=".7"/>',
    'file':
        '<path d="M7 3h7l4 4v14H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z"/><path d="M14 3v5h5M8.5 13h7m-7 3h7"/>',
    'users':
        '<circle cx="9" cy="9" r="3"/><path d="M3.5 20c.5-3.2 2.4-5 5.5-5s5 1.8 5.5 5M16 7.5a3 3 0 0 1 0 5.8m1.2 2.1c2 .4 3.2 2 3.5 4.6"/>',
    'trash': '<path d="M4 7h16M10 11v5m4-5v5M9 7l1-3h4l1 3m3 0-1 13H7L6 7"/>',
    'shield':
        '<path d="M12 3 19 6v5c0 4.7-3 8.2-7 10-4-1.8-7-5.3-7-10V6l7-3Z"/><path d="m9 12 2 2 4-4"/>',
    'alert': '<path d="M12 4 3.8 19h16.4L12 4Z"/><path d="M12 9v4m0 3h.01"/>',
    'x': '<path d="m7 7 10 10M17 7 7 17"/>',
  };
  return '<svg class="ui-icon" width="$size" height="$size" viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">${paths[name] ?? paths['check']}</svg>';
}

void render() {
  app.setInnerHtml('''
    <div class="app-shell">
      ${_topbar()}
      <main class="content" id="page-content"></main>
      ${_nav()}
    </div>
  ''', treeSanitizer: NodeTreeSanitizer.trusted);
  switch (page) {
    case 'events':
      _renderEvents();
      break;
    case 'upload':
      _renderUpload();
      break;
    case 'profile':
      _renderProfile();
      break;
    default:
      _renderDashboard();
  }
  querySelectorAll('[data-page]').forEach((element) {
    element.onClick.listen((_) {
      page = element.dataset['page']!;
      render();
    });
  });
  querySelector('[data-avatar]')?.onClick.listen((_) {
    page = 'profile';
    render();
  });
}

String _topbar() => '''
  <header class="topbar">
    <div class="brand"><div class="brand-icon">${_icon('check', size: '25')}</div><div><small>Student clearance</small><strong>Verify IT</strong></div></div>
    <button class="avatar" data-avatar aria-label="Open profile">${profile?['photo'] == null ? _e(_initials()) : '<img src="${_e(profile!['photo'])}" alt="Profile photo">'}</button>
  </header>''';

String _nav() => '''
  <nav class="bottom-nav" aria-label="Primary navigation">
    ${_navItem('dashboard', 'grid', 'Dashboard')}${_navItem('events', 'calendar', 'Events')}${_navItem('upload', 'upload', 'Upload')}${_navItem('profile', 'user', 'Profile')}
  </nav>''';

String _navItem(String id, String icon, String label) =>
    '<button class="nav-item ${page == id ? 'active' : ''}" data-page="$id">${_icon(icon, size: '22')}<span>$label</span></button>';

void _renderDashboard() {
  final total = departments.length;
  final done = departments.where(completed.contains).length;
  final percent = total == 0 ? 0 : ((done / total) * 100).round();
  querySelector('#page-content')!.setInnerHtml('''
    <section class="hero">
      <div class="hero-copy"><span class="eyebrow" style="color:#bcd1ed">Student clearance portal</span><h1>Hi, ${_e(_firstName())}</h1><p>${total - done} clearance tasks remaining. ${completed.length} completed.</p>
        <div class="hero-actions"><button class="btn btn-light" data-page="upload">${_icon('upload', size: '18')} Submit proof</button><button class="btn btn-outline" style="color:white;border-color:#7290b4" data-page="events">${_icon('calendar', size: '18')} View events</button></div>
      </div>
      <div class="progress-ring" style="--p:$percent"><div><strong>$percent%</strong><span>Complete</span></div></div>
    </section>
    <section class="stats"><div class="stat"><span>Events</span><strong>${events.length} total</strong></div><div class="stat"><span>Progress</span><strong>$done of $total</strong></div><div class="stat"><span>Remaining</span><strong>${total - done} tasks</strong></div></section>
    <div class="section-head"><div><span class="eyebrow">Office requirements</span><h2>Clearance checklist</h2></div><button class="btn btn-outline btn-small" id="mark-all">${_icon('check', size: '16')} Mark all complete</button></div>
    <section class="checklist">${departments.map(_requirementCard).join()}</section>
  ''', treeSanitizer: NodeTreeSanitizer.trusted);
  _bindPageButtons();
  querySelectorAll('[data-requirement]').forEach((element) {
    void toggle() {
      final name = element.dataset['requirement']!;
      if (completed.contains(name)) {
        completed.remove(name);
      } else {
        completed.add(name);
        freshlyCompleted = name;
        Timer(const Duration(milliseconds: 600), () => freshlyCompleted = null);
      }
      _saveCompleted();
      render();
    }

    element.onClick.listen((_) => toggle());
    element.onKeyDown.listen((event) {
      if (event.key == 'Enter' || event.key == ' ') {
        event.preventDefault();
        toggle();
      }
    });
  });
  querySelector('#mark-all')?.onClick.listen((_) {
    completed = departments.toSet();
    _saveCompleted();
    render();
  });
}

String _requirementCard(String name) {
  final done = completed.contains(name);
  final icons = {
    'Infirmary': 'medical',
    'Library': 'book',
    'Guidance': 'compass',
    'Sports': 'trophy',
    'Finance': 'wallet',
    'Registrar': 'file',
  };
  return '''<article class="requirement ${freshlyCompleted == name ? 'is-completing' : ''}" data-requirement="${_e(name)}" tabindex="0" role="button" aria-pressed="$done"><div class="requirement-icon">${_icon(icons[name] ?? 'check', size: '23')}</div><div><h3>${_e(name)}</h3><p>${done ? 'Requirement completed' : 'Tap to mark as cleared'}</p></div><span class="status ${done ? 'done' : ''}">${done ? 'Cleared' : 'Pending'}</span></article>''';
}

void _renderEvents([String filter = '']) {
  final matching = events
      .where(
        (event) =>
            event.values.join(' ').toLowerCase().contains(filter.toLowerCase()),
      )
      .toList();
  matching.sort((a, b) => _eventDate(a).compareTo(_eventDate(b)));
  final groups = <String, List<Map<String, dynamic>>>{};
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  for (final event in matching) {
    final difference = _eventDate(event).difference(startOfToday).inDays;
    final label = difference == 0
        ? 'Today'
        : difference == 1
            ? 'Tomorrow'
            : difference > 1 && difference <= 7
                ? 'This week'
                : difference < 0
                    ? 'Past events'
                    : 'Later';
    groups.putIfAbsent(label, () => []).add(event);
  }
  querySelector('#page-content')!.setInnerHtml('''
    <div class="page-heading"><div><span class="eyebrow">Attendance &amp; clearance</span><h1>School events</h1><p>Choose an activity and submit your proof of attendance.</p></div><div class="event-toolbar"><label class="search">${_icon('search', size: '18')}<input id="event-search" type="search" value="${_e(filter)}" placeholder="Search events" aria-label="Search events"></label><button class="btn btn-primary" id="add-event">${_icon('plus', size: '18')} Add event</button></div></div>
    ${matching.isEmpty ? '<section class="events-grid"><div class="empty"><div class="empty-icon">${_icon('calendar', size: '42')}</div><h3>No events found</h3><p>Try another search or create a school event.</p></div></section>' : groups.entries.map((group) => '<section class="event-section"><div class="event-section-head"><h2>${group.key}</h2><span>${group.value.length} ${group.value.length == 1 ? 'event' : 'events'}</span></div><div class="events-grid">${group.value.map(_eventCard).join()}</div></section>').join()}
  ''', treeSanitizer: NodeTreeSanitizer.trusted);
  final search = querySelector('#event-search') as InputElement;
  search.onInput.listen((_) {
    _renderEvents(search.value ?? '');
    (querySelector('#event-search') as InputElement?)?.focus();
  });
  querySelector('#add-event')?.onClick.listen((_) => _showEventForm());
  querySelectorAll('[data-open-event]').forEach(
    (el) => el.onClick.listen((_) {
      selectedEventId = el.dataset['openEvent'];
      page = 'upload';
      render();
    }),
  );
  querySelectorAll('[data-delete-event]').forEach(
    (el) => el.onClick.listen((_) {
      _showDeleteConfirmation(el.dataset['deleteEvent']!, filter);
    }),
  );
}

DateTime _eventDate(Map<String, dynamic> event) {
  final raw = event['date']?.toString() ?? '';
  final iso = DateTime.tryParse(raw);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day);
  const months = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };
  final match = RegExp(r'^(\w{3})\s+(\d{1,2}),\s+(\d{4})$').firstMatch(raw);
  if (match == null) return DateTime(9999);
  return DateTime(
    int.parse(match.group(3)!),
    months[match.group(1)] ?? 12,
    int.parse(match.group(2)!),
  );
}

void _showDeleteConfirmation(String eventId, String filter) {
  final event = events.where((item) => item['id'] == eventId).firstOrNull;
  if (event == null) return;
  document.body!.appendHtml(
    '''<div class="confirm-layer" id="delete-confirmation" role="dialog" aria-modal="true" aria-labelledby="delete-title"><section class="confirm-card"><div class="confirm-content"><div class="confirm-symbol">${_icon('x', size: '26')}</div><span class="eyebrow">Remove event</span><h2 id="delete-title">Delete this event?</h2><p><strong>${_e(event['title'])}</strong> will be permanently removed from your event list.</p><div class="confirm-actions"><button class="btn btn-outline" id="cancel-delete">Keep event</button><button class="btn btn-danger confirm-delete" id="confirm-delete">Delete</button></div></div><div class="delete-sequence" aria-live="polite"><div class="delete-document"><span></span><span></span><span></span></div><div class="delete-bin">${_icon('trash', size: '72')}</div><p>Deleting event…</p></div></section></div>''',
    treeSanitizer: NodeTreeSanitizer.trusted,
  );
  final layer = querySelector('#delete-confirmation')!;
  void close() {
    layer.classes.add('is-closing');
    Timer(const Duration(milliseconds: 180), () => layer.remove());
  }

  querySelector('#cancel-delete')?.onClick.listen((_) => close());
  querySelector('#confirm-delete')?.onClick.listen((_) {
    layer.classes.add('is-deleting');
    Timer(const Duration(milliseconds: 1800), () {
      events.removeWhere((item) => item['id'] == eventId);
      _saveEvents();
      layer.remove();
      _renderEvents(filter);
      _showDeleteToast();
    });
  });
  document.onKeyDown.firstWhere((event) => event.key == 'Escape').then((_) {
    if (layer.isConnected == true) close();
  });
}

void _showDeleteToast() {
  document.body!.appendHtml(
    '''<div class="success-toast" id="delete-toast" role="status">${_icon('check', size: '19')}<span><strong>Deleted successfully</strong><small>The event was removed from your list.</small></span></div>''',
    treeSanitizer: NodeTreeSanitizer.trusted,
  );
  Timer(const Duration(milliseconds: 3200), () {
    final toast = querySelector('#delete-toast');
    if (toast == null) return;
    toast.classes.add('is-leaving');
    Timer(const Duration(milliseconds: 220), () => toast.remove());
  });
}

String _eventCard(Map<String, dynamic> event) {
  final done = completed.contains(event['requirement']);
  return '''<article class="event-card"><div class="event-top"><div class="event-meta"><span>${_e(event['tag'])}</span><span>${done ? 'VERIFIED' : 'PROOF NEEDED'}</span></div><div class="event-date-badge"><strong>${_e(event['date'])}</strong><span>${_e(event['time'])}</span></div><h3>${_e(event['title'])}</h3><p>${_e(event['requirement'])} clearance</p></div><div class="event-body"><div class="event-row"><span>${_icon('clock', size: '16')}${_e(event['time'])}</span><span>${_icon('pin', size: '16')}${_e(event['location'])}</span></div><div class="event-actions"><button class="btn btn-primary btn-small" data-open-event="${_e(event['id'])}">${done ? 'View / replace proof' : 'Submit proof'}</button><button class="btn btn-danger btn-small" data-delete-event="${_e(event['id'])}">${_icon('trash', size: '16')} Delete</button></div></div></article>''';
}

void _renderUpload() {
  selectedEventId ??= events.isEmpty ? null : events.first['id'].toString();
  final selected = events.where((e) => e['id'] == selectedEventId).firstOrNull;
  final hasEvidence = proofDataUrl != null;
  querySelector('#page-content')!.setInnerHtml('''
    <div class="page-heading"><div><span class="eyebrow">Attendance record</span><h1>Submit proof</h1><p>Select an event and attach a clear proof image.</p></div></div>
    ${events.isEmpty ? '<div class="empty"><div class="empty-icon">${_icon('upload', size: '42')}</div><h3>No event available</h3><p>Add an event before submitting proof.</p><button class="btn btn-primary" data-page="events">Go to events</button></div>' : '''<div class="upload-stepper" aria-label="Upload progress"><span class="active"><b>${_icon('check', size: '14')}</b> Choose event</span><span class="${hasEvidence || proofSubmitted ? 'active' : ''}"><b>${hasEvidence || proofSubmitted ? _icon('check', size: '14') : '2'}</b> Add evidence</span><span class="${proofSubmitted ? 'active' : ''}" ${proofSubmitted ? 'aria-current="step"' : ''}><b>${proofSubmitted ? _icon('check', size: '14') : '3'}</b> Complete</span></div><div class="upload-layout"><section class="panel"><h2>Choose event</h2><div class="event-select">${events.map((event) => '<button class="event-choice ${event['id'] == selectedEventId ? 'selected' : ''}" data-select-event="${_e(event['id'])}"><strong>${_e(event['title'])}</strong><span>${_e(event['date'])} &middot; ${_e(event['requirement'])}</span></button>').join()}</div></section><section class="panel upload-panel ${proofSubmitted ? 'is-complete' : ''}"><h2>${proofSubmitted ? 'Submission complete' : 'Add evidence'}</h2>${proofSubmitted ? '<div class="upload-success">${_icon('shield', size: '48')}<strong>Proof submitted successfully</strong><span>${_e(selected?['requirement'])} is now cleared.</span><button class="btn btn-outline" id="upload-another">Submit another proof</button></div>' : '<label class="dropzone" for="proof-file"><input id="proof-file" type="file" accept="image/*"><span class="dropzone-icon">${_icon('upload', size: '48')}</span><strong>${hasEvidence ? 'Proof image selected' : 'Choose a proof image'}</strong><span>${hasEvidence ? 'Review the preview, then submit it.' : 'JPG, PNG or a photo from your device'}</span>${hasEvidence ? '<img class="preview" src="${_e(proofDataUrl)}" alt="Proof preview">' : ''}</label><button class="btn btn-primary btn-block" id="submit-proof" style="margin-top:16px" ${hasEvidence ? '' : 'disabled'}>${_icon('upload', size: '18')} Submit attendance proof</button>'}</section></div>'''}
  ''', treeSanitizer: NodeTreeSanitizer.trusted);
  _bindPageButtons();
  querySelectorAll('[data-select-event]').forEach(
    (el) => el.onClick.listen((_) {
      selectedEventId = el.dataset['selectEvent'];
      proofDataUrl = null;
      proofSubmitted = false;
      _renderUpload();
    }),
  );
  (querySelector('#proof-file') as FileUploadInputElement?)?.onChange.listen((
    _,
  ) {
    final input = querySelector('#proof-file') as FileUploadInputElement;
    if (input.files?.isEmpty ?? true) return;
    final reader = FileReader();
    reader.onLoad.listen((_) {
      proofDataUrl = reader.result as String?;
      _renderUpload();
    });
    reader.readAsDataUrl(input.files!.first);
  });
  querySelector('#submit-proof')?.onClick.listen((_) {
    if (selected == null || proofDataUrl == null) return;
    final button = querySelector('#submit-proof') as ButtonElement;
    final panel = querySelector('.upload-panel')!;
    button.disabled = true;
    button.setInnerHtml(
      '<span class="upload-spinner"></span> Uploading proof…',
      treeSanitizer: NodeTreeSanitizer.trusted,
    );
    panel.classes.add('is-uploading');
    Timer(const Duration(milliseconds: 850), () {
      completed.add(selected['requirement'].toString());
      proofSubmitted = true;
      _saveCompleted();
      _renderUpload();
    });
  });
  querySelector('#upload-another')?.onClick.listen((_) {
    proofDataUrl = null;
    proofSubmitted = false;
    _renderUpload();
  });
}

void _renderProfile() {
  final theme = window.localStorage[_themeKey] ?? 'light';
  querySelector('#page-content')!.setInnerHtml('''
    <div class="page-heading"><div><span class="eyebrow">Student account</span><h1>My profile</h1><p>Your student information and application preferences.</p></div></div>
    <div class="profile-grid"><section class="panel profile-card"><div class="profile-photo">${profile?['photo'] == null ? _e(_initials()) : '<img src="${_e(profile!['photo'])}" alt="Profile photo">'}</div><h2>${_e(profile?['name'])}</h2><p>${_e(profile?['id'])}</p><button class="btn btn-outline btn-block" id="edit-profile">${_icon('user', size: '18')} Edit profile</button></section>
    <div class="profile-sections"><section class="panel"><h2>Student information</h2><div class="details"><div class="detail"><span>Department</span><strong>${_e(profile?['department'])}</strong></div><div class="detail"><span>Year level</span><strong>${_e(profile?['year'])}</strong></div><div class="detail"><span>Program</span><strong>${_e(profile?['program'])}</strong></div><div class="detail"><span>Student ID</span><strong>${_e(profile?['id'])}</strong></div></div></section>
    <section class="panel preference-panel"><div class="setting"><div><strong>Display mode</strong><div class="setting-copy">Choose your preferred appearance</div></div><div class="theme-options">${[
    'light',
    'dark',
    'amoled'
  ].map((t) => '<button class="theme-button ${theme == t ? 'active' : ''}" data-theme="$t">${t[0].toUpperCase()}${t.substring(1)}</button>').join()}</div></div>
    </section><section class="panel danger-panel"><div class="danger-icon">${_icon('alert', size: '22')}</div><div><span class="eyebrow">Danger zone</span><h3>Clear local data</h3><p>Remove your profile, events, progress, and preferences from this browser.</p></div><button class="btn btn-danger" id="reset-data">${_icon('trash', size: '17')} Clear data</button></section></div></div>
  ''', treeSanitizer: NodeTreeSanitizer.trusted);
  querySelector('#edit-profile')?.onClick.listen((_) => _showProfileForm());
  querySelectorAll('[data-theme]').forEach(
    (el) => el.onClick.listen((_) {
      final value = el.dataset['theme']!;
      window.localStorage[_themeKey] = value;
      _applyTheme(value);
      _renderProfile();
    }),
  );
  querySelector('#reset-data')?.onClick.listen((_) => _showResetConfirmation());
}

void _showResetConfirmation() {
  document.body!.appendHtml(
    '''<div class="confirm-layer" id="reset-confirmation" role="dialog" aria-modal="true" aria-labelledby="reset-title"><section class="confirm-card"><div class="confirm-symbol">${_icon('alert', size: '26')}</div><span class="eyebrow">Danger zone</span><h2 id="reset-title">Clear local data?</h2><p>Your profile, events, attendance progress, and preferences will be removed from this browser.</p><div class="confirm-actions"><button class="btn btn-outline" id="cancel-reset">Keep my data</button><button class="btn btn-danger confirm-delete" id="confirm-reset">Clear data</button></div></section></div>''',
    treeSanitizer: NodeTreeSanitizer.trusted,
  );
  final layer = querySelector('#reset-confirmation')!;
  void close() {
    layer.classes.add('is-closing');
    Timer(const Duration(milliseconds: 180), () => layer.remove());
  }

  querySelector('#cancel-reset')?.onClick.listen((_) => close());
  querySelector('#confirm-reset')?.onClick.listen((_) {
    window.localStorage.clear();
    profile = null;
    events = defaultEvents.map((e) => Map<String, dynamic>.from(e)).toList();
    completed.clear();
    proofDataUrl = null;
    proofSubmitted = false;
    _applyTheme('light');
    layer.remove();
    _showProfileForm(firstRun: true);
  });
  document.onKeyDown.firstWhere((event) => event.key == 'Escape').then((_) {
    if (layer.isConnected == true) close();
  });
}

void _showProfileForm({bool firstRun = false}) {
  app.setInnerHtml(
    '''<div class="modal-layer"><section class="modal"><div class="modal-head"><div><span class="eyebrow">${firstRun ? 'Welcome to Verify IT' : 'Student account'}</span><h2>${firstRun ? 'Create your profile' : 'Edit profile'}</h2></div>${firstRun ? '' : '<button class="icon-button" id="close-modal" aria-label="Close profile form">${_icon('x', size: '20')}</button>'}</div><form id="profile-form"><div class="form-grid"><div class="field full"><label>Full name</label><input name="name" required maxlength="80" value="${_e(profile?['name'])}" placeholder="Juan Dela Cruz"></div><div class="field"><label>Student ID</label><input name="id" required maxlength="30" value="${_e(profile?['id'])}" placeholder="2026-0012"></div><div class="field"><label>Year level</label><select name="year">${[
      'First year',
      'Second year',
      'Third year',
      'Fourth year'
    ].map((v) => '<option ${profile?['year'] == v ? 'selected' : ''}>$v</option>').join()}</select></div><div class="field full"><label>Department</label><select name="department">${[
      'College of Information Technology',
      'College of Education',
      'College of Business',
      'Senior High School'
    ].map((v) => '<option ${profile?['department'] == v ? 'selected' : ''}>$v</option>').join()}</select></div><div class="field full"><label>Program</label><input name="program" required value="${_e(profile?['program'] ?? 'Bachelor of Science in Information Technology')}"></div><div class="field full"><label>Profile photo (optional)</label><input id="profile-photo-input" type="file" accept="image/*"></div></div><div class="error" id="form-error"></div><div class="modal-actions">${firstRun ? '' : '<button type="button" class="btn btn-outline" id="cancel-profile">Cancel</button>'}<button class="btn btn-primary" type="submit">Save profile</button></div></form></section></div>''',
    treeSanitizer: NodeTreeSanitizer.trusted,
  );
  String? newPhoto = profile?['photo']?.toString();
  (querySelector('#profile-photo-input') as FileUploadInputElement)
      .onChange
      .listen((_) {
    final input =
        querySelector('#profile-photo-input') as FileUploadInputElement;
    if (input.files?.isEmpty ?? true) return;
    final reader = FileReader();
    reader.onLoad.listen((_) {
      newPhoto = reader.result as String?;
    });
    reader.readAsDataUrl(input.files!.first);
  });
  void close(_) => render();
  querySelector('#close-modal')?.onClick.listen(close);
  querySelector('#cancel-profile')?.onClick.listen(close);
  (querySelector('#profile-form') as FormElement).onSubmit.listen((event) {
    event.preventDefault();
    final form = event.currentTarget as FormElement;
    final name =
        (form.querySelector('[name="name"]') as InputElement).value?.trim() ??
            '';
    final id =
        (form.querySelector('[name="id"]') as InputElement).value?.trim() ?? '';
    final program = (form.querySelector('[name="program"]') as InputElement)
            .value
            ?.trim() ??
        '';
    if (name.isEmpty || id.isEmpty || program.isEmpty) {
      querySelector('#form-error')!.text =
          'Please complete all required fields.';
      return;
    }
    profile = {
      'name': name,
      'id': id,
      'program': program,
      'year': (form.querySelector('[name="year"]') as SelectElement).value,
      'department':
          (form.querySelector('[name="department"]') as SelectElement).value,
      'photo': newPhoto,
    };
    window.localStorage[_profileKey] = jsonEncode(profile);
    page = 'dashboard';
    render();
  });
}

void _showEventForm() {
  document.body!.appendHtml(
    '''<div class="modal-layer" id="event-modal"><section class="modal"><div class="modal-head"><div><span class="eyebrow">School activity</span><h2>Add an event</h2></div><button class="icon-button" id="close-event" aria-label="Close event form">${_icon('x', size: '20')}</button></div><form id="event-form"><div class="form-grid"><div class="field full"><label>Event title</label><input name="title" required placeholder="Foundation Day"></div><div class="field"><label>Date</label><input name="date" required type="date"></div><div class="field"><label>Time</label><input name="time" required type="time"></div><div class="field full"><label>Location</label><input name="location" required placeholder="Main campus"></div><div class="field"><label>Tag</label><input name="tag" value="SCHOOL EVENT"></div><div class="field"><label>Clearance office</label><select name="requirement">${departments.map((v) => '<option>${_e(v)}</option>').join()}</select></div></div><div class="modal-actions"><button type="button" class="btn btn-outline" id="cancel-event">Cancel</button><button type="submit" class="btn btn-primary">${_icon('plus', size: '18')} Add event</button></div></form></section></div>''',
    treeSanitizer: NodeTreeSanitizer.trusted,
  );
  void close(_) => querySelector('#event-modal')?.remove();
  querySelector('#close-event')?.onClick.listen(close);
  querySelector('#cancel-event')?.onClick.listen(close);
  (querySelector('#event-form') as FormElement).onSubmit.listen((event) {
    event.preventDefault();
    final form = event.currentTarget as FormElement;
    String val(String n) =>
        (form.querySelector('[name="$n"]') as InputElement).value?.trim() ?? '';
    final title = val('title');
    if (title.isEmpty) return;
    events.add({
      'id': 'custom-${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'tag': val('tag').isEmpty ? 'SCHOOL EVENT' : val('tag'),
      'date': val('date'),
      'time': val('time'),
      'location': val('location'),
      'requirement':
          (form.querySelector('[name="requirement"]') as SelectElement).value,
    });
    _saveEvents();
    close(null);
    _renderEvents();
  });
}

void _bindPageButtons() {
  querySelectorAll('#page-content [data-page]').forEach(
    (el) => el.onClick.listen((_) {
      page = el.dataset['page']!;
      render();
    }),
  );
}

void _saveEvents() => window.localStorage[_eventsKey] = jsonEncode(events);
void _saveCompleted() =>
    window.localStorage[_doneKey] = jsonEncode(completed.toList());
void _applyTheme(String theme) {
  document.body!.classes.removeAll(['dark', 'amoled']);
  if (theme != 'light') document.body!.classes.add(theme);
}

extension FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
