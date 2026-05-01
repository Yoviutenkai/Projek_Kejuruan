import 'package:flutter/material.dart';

void main() {
  runApp(const ReservationApp());
}

final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

enum UserRole { admin, user }
enum ReservationStatus { pending, diterima, dibatalkan }

class AppUser {
  AppUser({
    required this.username,
    required this.password,
    required this.role,
    required this.displayName,
  });
  final String username, password, displayName;
  final UserRole role;
}

class Reservation {
  Reservation({
    required this.id,
    required this.customerName,
    required this.sportField,
    required this.notes,
    required this.createdBy,
    required this.startTime,
    required this.endTime,
    this.status = ReservationStatus.pending,
  });
  final String id;
  String customerName;
  String sportField;
  List<String> notes;
  final String createdBy;
  TimeOfDay startTime;
  TimeOfDay endTime;
  ReservationStatus status;
}

class ReservationApp extends StatefulWidget {
  const ReservationApp({super.key});
  @override
  State<ReservationApp> createState() => _ReservationAppState();
}

class _ReservationAppState extends State<ReservationApp> {
  final List<AppUser> _users = [
    AppUser(username: 'admin', password: '123', role: UserRole.admin, displayName: 'Admin Lapangan'),
    AppUser(username: 'user', password: '123', role: UserRole.user, displayName: 'Eko (Pelanggan)'),
  ];

  final List<String> _availableFields = ['Futsal A', 'Futsal B', 'Basket 1'];
  final List<Reservation> _reservations = [];
  AppUser? _activeUser;

  void _login(String user, String pass) {
    final found = _users.where((u) => u.username == user && u.password == pass);
    if (found.isEmpty) {
      messengerKey.currentState?.showSnackBar(const SnackBar(content: Text("Login Gagal!")));
    } else {
      setState(() => _activeUser = found.first);
    }
  }

  void _add(Reservation r) => setState(() => _reservations.add(r));
  void _delete(String id) => setState(() => _reservations.removeWhere((r) => r.id == id));
  
  void _update(String id, String name, String field, TimeOfDay start, TimeOfDay end) {
    final i = _reservations.indexWhere((r) => r.id == id);
    if (i != -1) {
      setState(() {
        _reservations[i].customerName = name;
        _reservations[i].sportField = field;
        _reservations[i].startTime = start;
        _reservations[i].endTime = end;
      });
    }
  }

  void _addNote(String id, String sender, String message) {
    final i = _reservations.indexWhere((r) => r.id == id);
    if (i != -1) setState(() => _reservations[i].notes.add("$sender: $message"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: _activeUser == null
          ? LoginPage(
            onLogin: _login,
            onSignUp: (u) => setState(() => _users.add(u)),)
          : DashboardPage(
              user: _activeUser!,
              data: _reservations,
              availableFields: _availableFields,
              allUsers: _users,
              onLogout: () => setState(() => _activeUser = null),
              onAdd: _add,
              onDelete: _delete,
              onUpdate: _update,
              onUpdateStatus: (id, status) => setState(() => _reservations.firstWhere((r) => r.id == id).status = status),
              onAddNote: _addNote,
              onAddField: (f) => setState(() => _availableFields.add(f)),
              onAddUser: (u) => setState(() => _users.add(u)),
              onDeleteUser: (uname) => setState(() => _users.removeWhere((u) => u.username == uname)),
            ),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.onLogin, required this.onSignUp});
  final Function(String, String) onLogin;
  final Function(AppUser) onSignUp;
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sports_tennis, size: 50, color: Colors.green),
                const Text("Login Reservasi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "Username")),
                TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () => onLogin(userCtrl.text, passCtrl.text), child: const Text("Masuk")),
                TextButton(
                  onPressed: () => _showSignUpDialog(context), // Sekarang bisa memanggil fungsi di bawah
                  child: const Text("Belum punya akun? Daftar Sekarang"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // PINDAHKAN FUNGSI INI KE DALAM CLASS LoginPage (Sebelum kurung penutup terakhir)
  void _showSignUpDialog(BuildContext context) {
    final u = TextEditingController();
    final p = TextEditingController();
    final d = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Daftar Akun Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: u, decoration: const InputDecoration(labelText: "Username (untuk login)")),
            TextField(controller: d, decoration: const InputDecoration(labelText: "Nama Lengkap")),
            TextField(controller: p, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (u.text.isNotEmpty && p.text.isNotEmpty) {
                // Sekarang onSignUp bisa diakses karena berada di class yang sama
                onSignUp(AppUser(
                  username: u.text,
                  password: p.text,
                  role: UserRole.user,
                  displayName: d.text.isEmpty ? u.text : d.text,
                ));
                Navigator.pop(ctx);
                messengerKey.currentState?.showSnackBar(
                  const SnackBar(content: Text("Pendaftaran Berhasil! Silakan Login."))
                );
              }
            },
            child: const Text("Daftar"),
          ),
        ],
      ),
    );
  }
} // Penutup class LoginPage

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key, required this.user, required this.data, required this.availableFields,
    required this.allUsers, required this.onLogout, required this.onAdd, required this.onDelete,
    required this.onUpdate, required this.onUpdateStatus, required this.onAddNote,
    required this.onAddField, required this.onAddUser, required this.onDeleteUser,
  });

  final AppUser user;
  final List<Reservation> data;
  final List<String> availableFields;
  final List<AppUser> allUsers;
  final VoidCallback onLogout;
  final Function(Reservation) onAdd;
  final Function(String) onDelete;
  final Function(String, String, String, TimeOfDay, TimeOfDay) onUpdate;
  final Function(String, ReservationStatus) onUpdateStatus;
  final Function(String, String, String) onAddNote;
  final Function(String) onAddField;
  final Function(AppUser) onAddUser;
  final Function(String) onDeleteUser;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: user.role == UserRole.admin ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Halo, ${user.displayName}"),
          actions: [IconButton(onPressed: onLogout, icon: const Icon(Icons.logout))],
          bottom: user.role == UserRole.admin 
            ? const TabBar(tabs: [Tab(text: "Reservasi"), Tab(text: "Kelola Sistem")]) 
            : null,
        ),
        body: TabBarView(
          children: [
            _buildReservationList(context),
            if (user.role == UserRole.admin) _buildAdminPanel(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildReservationList(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (ctx, i) {
        final r = data[i];
        final bool isOwner = user.role == UserRole.admin || r.createdBy == user.username;
        if (!isOwner) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                title: Text(r.sportField, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Pemesan: ${r.customerName}\nWaktu: ${r.startTime.format(ctx)} - ${r.endTime.format(ctx)}"),
                trailing: Chip(label: Text(r.status.name.toUpperCase())),
              ),
              const Divider(),
              ...r.notes.map((n) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Align(
                  alignment: n.startsWith("Admin") ? Alignment.centerLeft : Alignment.centerRight,
                  child: Text(n, style: TextStyle(fontStyle: FontStyle.italic, color: n.startsWith("Admin") ? Colors.blue : Colors.green)),
                ),
              )),
              ButtonBar(
                children: [
                  if (user.role == UserRole.admin)
                    IconButton(onPressed: () => _showEditFormDialog(context, r), icon: const Icon(Icons.edit, color: Colors.orange)),
                  
                  TextButton(onPressed: () => _showReplyNoteDialog(context, r.id), child: const Text("Balas Catatan")),
                  if (user.role == UserRole.admin && r.status == ReservationStatus.pending) ...[
                    IconButton(onPressed: () => onUpdateStatus(r.id, ReservationStatus.diterima), icon: const Icon(Icons.check, color: Colors.green)),
                    IconButton(onPressed: () => onUpdateStatus(r.id, ReservationStatus.dibatalkan), icon: const Icon(Icons.close, color: Colors.red)),
                  ],
                  IconButton(onPressed: () => onDelete(r.id), icon: const Icon(Icons.delete, color: Colors.grey)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminPanel(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("1. Kelola Lapangan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(spacing: 8, children: availableFields.map((f) => Chip(label: Text(f))).toList()),
          ElevatedButton(onPressed: () => _showAddFieldDialog(context), child: const Text("Tambah Lapangan")),
          const Divider(height: 40),
          const Text("2. Kelola User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...allUsers.map((u) => ListTile(
            title: Text(u.displayName),
            subtitle: Text("${u.username} (${u.role.name})"),
            trailing: u.username == 'admin' ? null : IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: () => onDeleteUser(u.username)),
          )),
          ElevatedButton(onPressed: () => _showAddUserDialog(context), child: const Text("Tambah User")),
        ],
      ),
    );
  }

  void _showEditFormDialog(BuildContext context, Reservation r) {
    final nameCtrl = TextEditingController(text: r.customerName);
    String selectedField = r.sportField;
    TimeOfDay start = r.startTime;
    TimeOfDay end = r.endTime;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setDS) => AlertDialog(
      title: const Text("Admin: Edit Reservasi"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nama Pelanggan")),
        DropdownButtonFormField<String>(
          value: selectedField,
          items: availableFields.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
          onChanged: (v) => setDS(() => selectedField = v!),
        ),
        ListTile(
          title: Text("Mulai: ${start.format(context)}"),
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: start);
            if (t != null) setDS(() => start = t);
          },
        ),
        ListTile(
          title: Text("Selesai: ${end.format(context)}"),
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: end);
            if (t != null) setDS(() => end = t);
          },
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
        ElevatedButton(onPressed: () {
          onUpdate(r.id, nameCtrl.text, selectedField, start, end);
          Navigator.pop(ctx);
        }, child: const Text("Update Data")),
      ],
    )));
  }

  void _showAddDialog(BuildContext context) {
    final g = TextEditingController();
    final n = TextEditingController();
    String selected = availableFields[0];
    TimeOfDay start = const TimeOfDay(hour: 08, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 09, minute: 0);
    
    // Default target adalah diri sendiri, tapi admin bisa mengetik username lain
    String targetUser = user.username; 

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setDS) => AlertDialog(
      title: const Text("Buat Reservasi"),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (user.role == UserRole.admin) 
            TextField(
              decoration: const InputDecoration(labelText: "Username Tujuan (Pelanggan)"),
              onChanged: (v) => targetUser = v,
            ),
          TextField(controller: g, decoration: const InputDecoration(labelText: "Nama Pelanggan")),
          DropdownButtonFormField<String>(
            value: selected,
            items: availableFields.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (v) => setDS(() => selected = v!),
          ),
          ListTile(
            title: Text("Jam Mulai: ${start.format(context)}"),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: start);
              if (t != null) setDS(() => start = t);
            },
          ),
          ListTile(
            title: Text("Jam Selesai: ${end.format(context)}"),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: end);
              if (t != null) setDS(() => end = t);
            },
          ),
          TextField(controller: n, decoration: const InputDecoration(labelText: "Catatan Awal")),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
        ElevatedButton(onPressed: () {
          onAdd(Reservation(
            id: DateTime.now().toString(),
            customerName: g.text.isEmpty ? user.displayName : g.text,
            sportField: selected,
            notes: [n.text.isEmpty ? "Belum ada catatan" : "${user.displayName}: ${n.text}"],
            createdBy: user.role == UserRole.admin ? targetUser : user.username,
            startTime: start,
            endTime: end,
          ));
          Navigator.pop(ctx);
        }, child: const Text("Kirim")),
      ],
    )));
  }

  void _showReplyNoteDialog(BuildContext context, String resId) {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Balas Catatan"),
      content: TextField(controller: c, decoration: const InputDecoration(hintText: "Tulis pesan...")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
        TextButton(onPressed: () {
          onAddNote(resId, user.role == UserRole.admin ? "Admin" : user.displayName, c.text);
          Navigator.pop(ctx);
        }, child: const Text("Balas")),
      ],
    ));
  }

  void _showAddFieldDialog(BuildContext context) {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Tambah Lapangan Baru"),
      content: TextField(controller: c, decoration: const InputDecoration(hintText: "Contoh: Lapangan Voli")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
        ElevatedButton(onPressed: () { onAddField(c.text); Navigator.pop(ctx); }, child: const Text("Simpan"))
      ],
    ));
  }

  void _showAddUserDialog(BuildContext context) {
    final u = TextEditingController();
    final p = TextEditingController();
    final d = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Tambah User Baru"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: u, decoration: const InputDecoration(labelText: "Username")),
        TextField(controller: d, decoration: const InputDecoration(labelText: "Display Name")),
        TextField(controller: p, decoration: const InputDecoration(labelText: "Password")),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
        ElevatedButton(onPressed: () {
          onAddUser(AppUser(username: u.text, password: p.text, role: UserRole.user, displayName: d.text));
          Navigator.pop(ctx);
        }, child: const Text("Simpan"))
      ],
    ));
  }
}